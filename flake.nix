{
  description = "NixOS Flake";

  # `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to
  # the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs.
    # The most widely used is `github:owner/name/reference`,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };

  # `outputs` are all the build result of the flake.
  # 
  # parameters in function `outputs` are defined in `inputs` and
  # can be referenced by their names. However, `self` is an exception,
  # this special parameter points to the `outputs` itself(self-reference)
  # 
  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = { self, nixpkgs, home-manager, impermanence, ... }@inputs: {
    nixosConfigurations = {
      # By default, NixOS will try to refer the nixosConfiguration with
      # However, the configuration name can also be specified using:
      #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
      #
      # The `nixpkgs.lib.nixosSystem` function is used to build this
      # configuration, the following attribute set is its parameter.
      #
      # Run the following command in the flake's directory to
      # deploy this configuration on any NixOS system:
      #   sudo nixos-rebuild switch --flake .#nixos-test
      "janix" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # The Nix module system can modularize configuration,
        # improving the maintainability of configuration.
        #
        # Each parameter in the `modules` is a Nixpkgs Modules
        # A Nixpkgs Module can be an attribute set, or a function that
        # returns an attribute set. By default, if a Nixpkgs Module is a
        # function, this function have the following default parameters:
        #
        #  lib:     the nixpkgs function library, which provides many
        #             useful functions for operating Nix expressions:
        #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
        #  config:  all config options of the current flake, very useful
        #  options: all options defined in all NixOS Modules
        #             in the current flake
        #  pkgs:   a collection of all packages defined in nixpkgs,
        #            plus a set of functions related to packaging.
        #            you can assume its default value is
        #            `nixpkgs.legacyPackages."${system}"` for now.
        #            can be customed by `nixpkgs.pkgs` option
        #  modulesPath: the default path of nixpkgs's modules folder,
        #               used to import some extra modules from nixpkgs.
        #               this parameter is rarely used,
        #               you can ignore it for now.
        #
        # The default parameters mentioned above are automatically
        # generated by Nixpkgs. 
        # However, if you need to pass other non-default parameters
        # to the submodules, 
        # you'll have to manually configure these parameters using
        # `specialArgs`. 
        # you must use `specialArgs` by uncomment the following line:
        #
        # specialArgs = {...};  # pass custom arguments into all sub module.
        modules = [
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nixpkgs Module,
          ./system-configs/janix.nix
		      home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jannis = import ./home-configs/janix-home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
          impermanence.nixosModules.impermanence
        ];
      };
      "matix" = nixpkgs.lib.nixosSystem{
        system = "x86_64-linux";
        modules = [
          ./system-configs/matix.nix
		      home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mattes = import ./home-configs/matix-home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
          impermanence.nixosModules.impermanence
        ];
      };
      "nix" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./system-configs/nix.nix
		      home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.niklas = import ./home-configs/nix-home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
          impermanence.nixosModules.impermanence
        ];
      };
      "kodi" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	      modules = [
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nixpkgs Module,
          ./system-configs/kodi.nix
          impermanence.nixosModules.impermanence
	];
      };
    };
  };
}