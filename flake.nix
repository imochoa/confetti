{
  description = "Neovim Nix flake CI template for GitHub Actions"; # TODO: Set description

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # flake-parts.url = "github:hercules-ci/flake-parts";
    # pre-commit-hooks = {
    #   url = "github:cachix/pre-commit-hooks.nix";
    # };
    # neorocks = {
    #   url = "github:nvim-neorocks/neorocks";
    # };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      # system = "x86_64-linux";
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          fzf
          lua
          stylua
          luarocks
          lua-language-server
          # emmylua-ls
          # luacheck
        ];
        # inputsFrom = [
        #   # pkgs.hello
        #   # pkgs.gnutar
        # ];
        # shellHook = ''
        #   export DEBUG=1
        # '';
      };

      # packages.${system} = {
      #   inherit (self.devShells.${system}) default;
      # };
    };
}
