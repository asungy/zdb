{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs-stable = import inputs.nixpkgs-stable { inherit system; };
        pkgs-unstable = import inputs.nixpkgs-unstable { inherit system; };
        zig = inputs.zig.packages.${system}."0.14.0";
      in
      {
        devShell = pkgs-unstable.callPackage ./nix/devShell.nix {
          inherit zig;
          zon2nix = pkgs-stable.zon2nix;
        };

        packages =
        let
          mkArgs = optimize: {
            inherit optimize zig;
          };
        in rec
        {
          zdb-debug = pkgs-unstable.callPackage ./nix/packages.nix (mkArgs "Debug");
          zdb-releasesafe = pkgs-unstable.callPackage ./nix/packages.nix (mkArgs "ReleaseSafe");
          zdb-releasefast = pkgs-unstable.callPackage ./nix/packages.nix (mkArgs "ReleaseFast");

          zdb = zdb-releasefast;
          default = zdb;
        };
      }
    );
    
}
