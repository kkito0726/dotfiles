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

      # gui:
      #   false … 従来どおり (macOS ホスト / ヘッドレス Linux VM)。
      #   true  … GUI 付き Linux 専用。キー再マップ (xremap) など desktop 向け設定を有効化。
      # Nix は「GUI の有無」を評価時に自動判定できないため、明示フラグで別構成にする。
      mkHome =
        system: gui:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username dotfilesDir gui; };
          modules = [ ./nix/home ];
        };

      linuxSystems = builtins.filter (s: nixpkgs.lib.hasSuffix "linux" s) systems;
    in
    {
      # 従来と同名・同挙動 (gui 無し): `home-manager switch --flake .#ken@x86_64-linux`
      # GUI Linux 専用 (gui 有り):      `home-manager switch --flake .#ken-gui@x86_64-linux`
      homeConfigurations = builtins.listToAttrs (
        (map (system: {
          name = "${username}@${system}";
          value = mkHome system false;
        }) systems)
        ++ (map (system: {
          name = "${username}-gui@${system}";
          value = mkHome system true;
        }) linuxSystems)
      );
    };
}
