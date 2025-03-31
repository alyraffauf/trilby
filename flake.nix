{
  description = "Helper shell for Trilby";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    bluebuild = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:blue-build/cli";
    };
  };

  outputs = {self, ...}: let
    allSystems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    forAllSystems = f:
      self.inputs.nixpkgs.lib.genAttrs allSystems (system:
        f {
          pkgs = import self.inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        });
  in {
    devShells = forAllSystems ({pkgs}: {
      default = pkgs.mkShell {
        packages = (with pkgs; [
            nixd
          ])
          ++ [
            self.inputs.bluebuild.packages.${pkgs.system}.bluebuild
          ];
      };
    });

    formatter = forAllSystems ({pkgs}: pkgs.alejandra);
  };
}
