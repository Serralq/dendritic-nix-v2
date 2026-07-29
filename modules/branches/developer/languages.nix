{ ... }:
{
  den.aspects.languages =
    { ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            # Rust
            rustc
            # jetbrains.rust-rover
            cargo
            # Go
            # jetbrains.goland
            go
            # Java
            # jetbrains.idea # For 25.11
            jre25_minimal
            # Python
            python-latest # Never install on the global, only on local venv
            # jetbrains.pycharm
            # Javascript
            nodejs_24 # For javascript deployments
            yarn # Js package manager
            # c/c++
            # jetbrains.clion # For c/c++
            libgcc # For compiling c/c++, use the below to start gcc
            # gcc # Also for gcc # Only use with direnv
            cmake-language-server
            gdb # c/c++ debugger
            # ida-free # Binary dissassmebly
            # Requires a pre install into the nix store
            valgrind # Chcek for memory leaks
            cmake # Compiling c programs
            gnumake # Getting the make command
            clang # Compiling c programs?
            libtool # To compile vterm
          ];
        };
    };
}
