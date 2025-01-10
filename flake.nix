{
  description = "Development environment";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            # See https://github.com/NixOS/nixpkgs/issues/59209.
            bashInteractive
          ];
          buildInputs = with pkgs; [
            live-server
            mustache-go
            watchman
            alacritty
          ];
          shellHook = ''
            function build-site() {
                mustache ./raw/data.yaml ./raw/index.html.mustache > index.html
            }

            function watch-mustache() {
                watchman watch ./raw &
                watchman -- trigger ./raw buildsite '*.*' -- build-site &
            }
            function launch-server() {
                alacritty -e live-server &
            }
            function launch-nvim() {
                alacritty -e nvim &
            }
            watch-mustache
            launch-server 
            launch-nvim
          '';
        };
      }
    );
}
