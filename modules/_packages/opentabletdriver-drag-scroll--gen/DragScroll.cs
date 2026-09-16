using System.Runtime.CompilerServices;
using OpenTabletDriver.Plugin;
using OpenTabletDriver.Plugin.Attributes;
using OpenTabletDriver.Plugin.DependencyInjection;
using OpenTabletDriver.Plugin.Output;
using OpenTabletDriver.Plugin.Platform.Pointer;
using OpenTabletDriver.Plugin.Tablet;

namespace OpenTabletDriver.DragScroll;

internal sealed class DragScrollState
{
    public readonly object Sync = new();
    public bool Active;
    public bool Scrolling;
    public float StartY;
    public float LastY;
    public double Remainder;
    public double Sensitivity;
    public double ActivationDistance;
    public bool NaturalScrolling;
    public IMouseScrollHandler? Pointer;
}

internal static class DragScrollCoordinator
{
    public static readonly ConditionalWeakTable<TabletReference, DragScrollState> States = new();

    public static float GetYMillimeters(TabletReference tablet, IAbsolutePositionReport report)
    {
        var digitizer = tablet.Properties.Specifications.Digitizer;
        return report.Position.Y * digitizer.Height / digitizer.MaxY;
    }
}

[PluginName("Drag Scroll")]
public sealed class DragScrollBinding : IStateBinding
{
    [Resolved]
    public IMouseScrollHandler? Pointer { get; set; }

    [Property("Sensitivity")]
    [DefaultPropertyValue(40.0)]
    [Unit("units/mm")]
    [ToolTip("Wheel units emitted per millimeter. One wheel tick is 120 units.")]
    public double Sensitivity { get; set; } = 40.0;

    [Property("Activation distance")]
    [DefaultPropertyValue(0.5)]
    [Unit("mm")]
    [ToolTip("Pen movement required before scrolling begins.")]
    public double ActivationDistance { get; set; } = 0.5;

    [Property("Natural scrolling")]
    [DefaultPropertyValue(true)]
    [ToolTip("Move content in the same direction as the pen.")]
    public bool NaturalScrolling { get; set; } = true;

    public void Press(TabletReference tablet, IDeviceReport report)
    {
        if (report is not IAbsolutePositionReport positionReport)
            return;

        var state = DragScrollCoordinator.States.GetValue(tablet, _ => new DragScrollState());
        var y = DragScrollCoordinator.GetYMillimeters(tablet, positionReport);

        lock (state.Sync)
        {
            state.Active = true;
            state.Scrolling = false;
            state.StartY = y;
            state.LastY = y;
            state.Remainder = 0;
            state.Sensitivity = Math.Max(1, Sensitivity);
            state.ActivationDistance = Math.Max(0, ActivationDistance);
            state.NaturalScrolling = NaturalScrolling;
            state.Pointer = Pointer;
        }
    }

    public void Release(TabletReference tablet, IDeviceReport report)
    {
        var state = DragScrollCoordinator.States.GetValue(tablet, _ => new DragScrollState());

        lock (state.Sync)
        {
            state.Active = false;
            state.Scrolling = false;
            state.Remainder = 0;
        }
    }

    public override string ToString() => $"Drag Scroll: {Sensitivity:0.##} units/mm";
}

[PluginName("Drag Scroll Tracker")]
public sealed class DragScrollTracker : IPositionedPipelineElement<IDeviceReport>
{
    [TabletReference]
    public TabletReference? Tablet { get; set; }

    public PipelinePosition Position => PipelinePosition.PreTransform;

    public event Action<IDeviceReport?>? Emit;

    public void Consume(IDeviceReport? report)
    {
        if (Tablet is not null && report is IAbsolutePositionReport positionReport)
            ProcessPosition(Tablet, positionReport);

        Emit?.Invoke(report);
    }

    private static void ProcessPosition(TabletReference tablet, IAbsolutePositionReport report)
    {
        var state = DragScrollCoordinator.States.GetValue(tablet, _ => new DragScrollState());
        var y = DragScrollCoordinator.GetYMillimeters(tablet, report);

        lock (state.Sync)
        {
            if (!state.Active)
                return;

            if (!state.Scrolling)
            {
                if (Math.Abs(y - state.StartY) < state.ActivationDistance)
                {
                    state.LastY = y;
                    return;
                }

                state.Scrolling = true;
                state.LastY = y;
                return;
            }

            var direction = state.NaturalScrolling ? 1.0 : -1.0;
            var exactAmount = state.Remainder + (y - state.LastY) * state.Sensitivity * direction;
            var amount = (int)Math.Truncate(exactAmount);

            state.LastY = y;
            state.Remainder = exactAmount - amount;

            if (amount == 0 || state.Pointer is null)
                return;

            state.Pointer.ScrollVertically(amount);

            if (state.Pointer is ISynchronousPointer synchronousPointer)
                synchronousPointer.Flush();
        }
    }
}
