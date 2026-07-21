{
  description = "dotfiles — Home Manager environment (macOS host & Linux VMs)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      # ─── VM ごとに変えるのはここだけ ──────────────────────────
      username = "ken";

      # この dotfiles リポジトリを clone した場所 ($HOME からの相対パス)。
      # ~/.config/nvim はここの .config/nvim へ symlink される。
      dotfilesDir = "dotfiles";

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin" # Apple Silicon の macOS ホスト
        "x86_64-darwin" # Intel Mac (使わないなら消してよい)
      ];
      # ─────────────────────────────────────────────────────────

      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username dotfilesDir; };
          modules = [ ./nix/home ];
        };
    in
    {
      # `home-manager switch --flake .#ken@x86_64-linux` で適用する
      homeConfigurations = builtins.listToAttrs (
        map (system: {
          name = "${username}@${system}";
          value = mkHome system;
        }) systems
      );
    };
}
