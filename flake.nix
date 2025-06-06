{
  description = "Demo of regression in WINTRUST";

  outputs = inputs@{ flake-parts, nixpkgs, systems, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = import systems;
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          wineStock = pkgs.winePackages.unstable;
          wineReverted = self'.packages.wineStock.overrideAttrs (attrs: {
            patches = attrs.patches or [] ++ [
              ./0001-Revert-wintrust-Use-CRT-allocation-functions.patch
            ];
          } );
          winePatched = self'.packages.wineStock.overrideAttrs (attrs: {
            patches = attrs.patches or [] ++ [
              ./0001-wintrust-Initialize-all-cert-fields-in-WINTRUST_AddC.patch
            ];
          } );
          test = pkgs.pkgsCross.mingw32.callPackage (
            { stdenv, cmake }:
            stdenv.mkDerivation {
              name = "wineovrissue";
              version = "1.0.0";
              src = ./.;
              nativeBuildInputs = [ cmake ];
            }
          ) { };
        };
      };
    };
}

