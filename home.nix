inputs@{ nixpkgs, plasma-manager, nixgl, nur, mitch-utils, nvim-config, ... }:
this:
{ config, lib, pkgs, ... }:
let
  mkDomainSymlink = rel: (
    config.lib.file.mkOutOfStoreSymlink (this.checkouts.dz-home-manager + "/domain/" + rel)
  );
  getEnvExtra = ({ env ? {}, ... }: env);
  envExtra = getEnvExtra this;
  system = pkgs.stdenv.hostPlatform.system;
  nurRepos = (import nixpkgs {
    inherit system;
    config = { allowUnfree = true; };
    overlays = [nur.overlays.default];
  }).nur.repos;
  zn = inputs.zn-nix.mk-zn system;
  fontPkgs = [
    pkgs.font-awesome
    pkgs.monaspace
    pkgs.liberation_ttf
    pkgs.nerd-fonts.monaspace
    pkgs.nerd-fonts.ubuntu-mono
    pkgs.nerd-fonts.comic-shanns-mono
    pkgs.nerd-fonts.shure-tech-mono
    pkgs.nerd-fonts.recursive-mono
    pkgs.nerd-fonts.proggy-clean-tt
    pkgs.nerd-fonts.profont
    pkgs.nerd-fonts.open-dyslexic
    pkgs.nerd-fonts.monofur
    pkgs.nerd-fonts.lilex
    pkgs.nerd-fonts.hurmit
    pkgs.nerd-fonts.gohufont
    pkgs.nerd-fonts.fantasque-sans-mono
    pkgs.nerd-fonts.daddy-time-mono
    pkgs.nerd-fonts.bigblue-terminal
    pkgs.nerd-fonts.agave
    pkgs.nerd-fonts._3270
    pkgs.ubuntu-classic
  ];
  zkmPkg = (
    config.lib.nixGL.wrap inputs.zkm.packages.${pkgs.hostPlatform.system}.zkm
  );
  mkZkm = n: f: zn.writeBashScriptBin' n [zkmPkg f] ''
    ${zkmPkg}/bin/zkm ${f}
  '';
in {
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];
  targets.genericLinux.nixGL = {
    packages = nixgl.packages;
    defaultWrapper = this.defaultNixGLWrapper;
  };
  home.username = this.username;
  home.homeDirectory = this.homeDirectory;
  home.stateVersion = this.stateVersion;
  home.packages = with pkgs; fontPkgs ++ [
    audacity
    babashka
    bat
    blueman
    brightnessctl
    bundler
    direnv
    emacs
    fastfetch
    fd
    fennel-ls
    fzf
    gh
    github-desktop
    google-cloud-sdk
    grc
    htop
    imagemagick
    jekyll
    jq
    just
    libnotify
    lua-language-server
    lxqt.pavucontrol-qt
    mpc
    ncmpcpp
    networkmanagerapplet
    nix-prefetch-github
    nixd
    nixfmt
    pandoc
    prettier
    ripgrep
    rlwrap
    rofi
    rust-analyzer
    typescript-language-server
    ueberzugpp
    unzip
    vlc
    watchexec
    (config.lib.nixGL.wrap inputs.zkg.packages.${pkgs.hostPlatform.system}.zkg)
    (config.lib.nixGL.wrap inputs.ztr.packages.${pkgs.hostPlatform.system}.ztr)
    zkmPkg
    (mkZkm "home.zkm" ./zkm/home.clj)
    (luajit.withPackages (luaPackages: with luaPackages; [
      busted
      fennel
    ]))
    (config.lib.nixGL.wrap pkgs.vesktop)
    (config.lib.nixGL.wrap pkgs.pear-desktop)
    (config.lib.nixGL.wrap pkgs.neovide)
    (mitch-utils.mkFnlFmt pkgs.luajit)
    (mitch-utils.mkNixWork pkgs)
    (zn.writeBashScriptBin "lvim" ''
      export DZ_NVIM_CONFIG_USE_LOCAL=no
      nvim "$@"
    '')
    (zn.writeBashScriptBin "gvim" ''
      neovide "$@" & disown
    '')
    (zn.writeBashScriptBin "lgvim" ''
      export DZ_NVIM_CONFIG_USE_LOCAL=no
      gvim "$@"
    '')
    (zn.writeBashScriptBin "jj" ''
      just "$@"
    '')
    (zn.writeBashScriptBin "rofi-dmenu" ''
      rofi -matching fuzzy -sorting-method fzf -sort -dmenu "$@"
    '')
    (zn.writeBashScriptBin "dz-hm" ''
      nix run "path:$DZ_HOME_MANAGER_CHECKOUT_PATH" -- "$@"
    '')
    (zn.writeBashScriptBin "ssh-adhdz" ''
      gcloud compute ssh \
        --zone "us-central1-c" \
        --project "adhdz-414420" \
        --command "bash -c fish" \
        mitch@instance-20250718-181706 \
        -- -t
    '')
    (zn.writeBashScriptBin "kittyRootWindow" ''
      TEMP_DIR=$(mktemp -d --)
      trap 'rm -rf "$TEMP_DIR"' EXIT
      up="$TEMP_DIR/k"
      export DZ_KITTY_UNIX_PATH="$up"
      /usr/bin/kitty -o allow_remote_control=yes --listen-on "unix:$up" "$@"
    '')
    (zn.writeBashScriptBin "kittenSelf" ''
      function doTheThing() {
        sleep 1.01
        kitten @ --to "unix:$DZ_KITTY_UNIX_PATH" "$@"
      }
      doTheThing "$@" & disown
    '')
  ];
  home.file = { };
  home.sessionVariables = envExtra // {
    DZ_NVIM_CONFIG_CHECKOUT_PATH = this.checkouts.dz-nvim-config;
    DZ_HOME_MANAGER_CHECKOUT_PATH = this.checkouts.dz-home-manager;
  };
  home.pointerCursor = {
    # gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    hyprcursor = { enable = true; size = 24; };
  };

  # gtk.enable = true;
  # gtk.theme.package = pkgs.rose-pine-gtk-theme;
  # gtk.theme.name = "rose-pine";
  # gtk.iconTheme.package = pkgs.dracula-icon-theme;
  # gtk.iconTheme.name = "Dracula";

  xdg.configFile = {
    "klassy" = {
      source = mkDomainSymlink "./klassy";
      recursive = true;
    };
    "fastfetch" = {
      source = mkDomainSymlink "./fastfetch";
      recursive = true;
    };
    "neovide/config.toml".text = ''
      [font]
      normal = ["monospace"]
      size = 11.0
    '';
  };
  systemd.user.services.polybar = {
    Unit = {
      Description = "polybar runner";
      WantedBy = [];
    };
    Service = {
      ExecStart = "${zn.writeBashScriptBin' "polybar.launch" [pkgs.picom] ''
        export PATH=${pkgs.picom}/bin:$PATH
        picom
      ''}/bin/polybar.launch";
      Restart = "always";
    };
  };

  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.serif = [ "Liberation Serif" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Ubuntu" ];
  fonts.fontconfig.defaultFonts.monospace = [
    # "RecMonoCasual Nerd Font Mono"
    # "Lilex Nerd Font Mono"
    ### "Hurmit Nerd Font Mono"
    # "FantasqueSansM Nerd Font Mono"
    # "ComicShannsMono Nerd Font Mono"
    # "Monaspace Krypton Frozen SemiBold"
    # "Monaspace Argon Frozen SemiBold"
    # "Monaspace Argon Frozen ExtraBold"
    # "Monaspace Krypton Frozen ExtraBold"
    # "Monaspace Xenon Frozen ExtraBold"
    # "Monaspace Radon Frozen ExtraBold"
    # "MonaspiceKr Nerd Font Mono"
    # "MonaspiceXe Nerd Font Mono"
    # "MonaspiceRn Nerd Font Mono"
    "MonaspiceAr Nerd Font Mono"
  ];

  programs.firefox = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.firefox;
    policies = {
      Preferences = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = { Value = true; Status = "locked"; };
        "layout.css.devPixelsPerPx" = { Value = "1.0"; Status = "locked"; };
      };
    };
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.tabs.inTitlebar" = 0;
          "full-screen-api.ignore-widgets" = true;
          "full-screen-api.exit-on.windowRaise" = false;
          "extensions.activeThemeId" = with nurRepos.rycee;
            firefox-addons.dracula-dark-colorscheme.addonId;
        };
        userChrome = builtins.readFile ./domain/firefox/userChrome.css;
        extensions.packages = with nurRepos.rycee.firefox-addons; [
          dracula-dark-colorscheme
          ublock-origin
          video-downloadhelper
        ];
      };
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    escapeTime = 0;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = rose-pine;
        extraConfig = ''
          set -g @rose_pine_variant 'main'
        '';
      }
    ];

    extraConfig = ''
      set -g allow-passthrough on
      set -g default-shell ${pkgs.fish}/bin/fish
    '';
  };
  programs.fish = import ./domain/fish/hm.nix { lib = lib; pkgs = pkgs; };
  programs.neovim = (
    let
      nvimConfigPkg = (nvim-config.mkPkg pkgs);
      shCore = pkgs.writeText "shCore" (nvim-config.mkShellHook pkgs);
      shPost = pkgs.writeText "shPost" ''
        # if [[ "$DZ_NVIM_CONFIG_USE_LOCAL" != "no" ]]; then
        export DZ_NVIM_CONFIG_USE_LOCAL=yes
        # fi
        export DZ_NVIM_CONFIG_MACRO_PATH="$FENNEL_MACRO_PATH"
        export DZ_NVIM_CONFIG_FENNEL_PATH="$DZ_NVIM_CONFIG_CHECKOUT_PATH/src/?.fnl"
        export DZ_NVIM_CONFIG_LUA_PATH_EXTRA="$LUA_PATH_EXTRA;$DZ_NVIM_CONFIG_CHECKOUT_PATH/src/?.fnl"
        cd "$vimRunDir"
      '';
    in {
      package = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
        postInstall = ''
          mv $out/bin/nvim $out/bin/nvim-true-bin
          echo 'vimRunDir="$(pwd)"'                                  > $out/bin/nvim
          cat ${pkgs.writeText "hk" (nvim-config.mkShellHook pkgs)} >> $out/bin/nvim
          cat ${shPost}                                             >> $out/bin/nvim
          echo $out/bin/nvim-true-bin '"$@"'                        >> $out/bin/nvim
          chmod +x $out/bin/nvim
        '';
      });
      initLua = "require(\"nvim-config\").doTheThings()";
      plugins = nvimConfigPkg.propagatedBuildInputs ++ [(pkgs.neovimUtils.buildNeovimPlugin { luaAttr = nvimConfigPkg; })];
    } // (builtins.listToAttrs (map (n: {name = n; value = true;}) [
      "enable" "defaultEditor" "viAlias" "vimAlias" "vimdiffAlias" "withNodeJs" "withPython3" "withRuby"
    ]))
  );
  # programs.plasma = (import ./domain/kdeplasma/config.nix).programs.plasma;
  programs.rofi = {
    enable = true;
    theme = ./domain/rofi/theme.rasi;
  };
  programs.home-manager.enable = true;
}
