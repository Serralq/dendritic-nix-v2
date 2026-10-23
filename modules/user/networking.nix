{ ... }:
{
  den.aspects.networking = {
    nixos = {
      time.timeZone = "America/New_York";
      networking.firewall.enable = true;
      services.fail2ban.enable = true;
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          wireshark # Better network inspection
          termshark
        ];
      };
  };
}

# Credits to Brian Batista for being my rubber duck ❤️ 🚀
