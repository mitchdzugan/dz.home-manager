{ lib, pkgs, nvim-config, mitch-utils, ... }:

let
  wrapColorscheme = pkg: pkg;
  colorschemes = {
    aurora = wrapColorscheme pkgs.vimPlugins.aurora;
  };
  fromGitHub = repo: ref: rev: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    buildInputs = [ pkgs.vimPlugins.plenary-nvim pkgs.git ];
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
      rev = rev;
    };
  };
in {
  enable = true;
  defaultEditor = false;
  viAlias = false;
  vimAlias = false;
  vimdiffAlias = true;
  withNodeJs = true;
  withPython3 = true;
  withRuby = true;
  extraLuaConfig = ''
    if ("yes" ~= os.getenv("DZ_NVIM_CONFIG_USE_LOCAL")) then
      require("nvim-config").doTheThings()
    else
      local fnlDirname = os.getenv("DZ_NVIM_CONFIG_CHECKOUT_PATH")
      local fennel = require("fennel").install()
      fennel["path"] = os.getenv("DZ_NVIM_CONFIG_FENNEL_PATH")
      fennel["macro-path"] = os.getenv("DZ_NVIM_CONFIG_MACRO_PATH")
      package.path = os.getenv("DZ_NVIM_CONFIG_LUA_PATH_EXTRA") .. package.path
      fennel.dofile(fnlDirname .. "/src/nvim-config.fnl").doTheThings()
    end
  '';
  plugins = with pkgs.vimPlugins; [
    (pkgs.neovimUtils.buildNeovimPlugin { luaAttr = nvim-config.mkPkg pkgs ; })
    (pkgs.neovimUtils.buildNeovimPlugin { luaAttr = pkgs.luajitPackages.fennel; })
    (pkgs.neovimUtils.buildNeovimPlugin {
      luaAttr = mitch-utils.mkLuaColors pkgs.luajit;
    })

    neomodern-nvim
    bluloco-nvim
    modus-themes-nvim
    onedarkpro-nvim
    oxocarbon-nvim
    (fromGitHub
      "tiagovla/tokyodark.nvim"
      "HEAD"
      "14bc1b3e596878a10647af7c82de7736300f3322")
    (fromGitHub
      "bluz71/vim-moonfly-colors"
      "HEAD"
      "63f20d657c9fd46ecdd75bd45c321f74ef9b11fe")
    (fromGitHub
      "dgox16/oldworld.nvim"
      "HEAD"
      "1b8e1b2052b5591386187206a9afbe9e7fdbb35f")
    (fromGitHub
      "fynnfluegge/monet.nvim"
      "HEAD"
      "af6c8fb9faaae2fa7aa16dd83b1b425c2b372891")
    (fromGitHub
      "maxmx03/fluoromachine.nvim"
      "HEAD"
      "d638ea221b4c6636978f49c1987d10ff2733c23d")

    cmp-nvim-lsp
    cmp-buffer
    cmp-conjure
    cmp-path
    cmp-cmdline
    cmp-vsnip
    nvim-cmp

    nvim-treesitter.withAllGrammars
    snacks-nvim
    nvim-paredit
    conform-nvim
    indent-blankline-nvim

    gitsigns-nvim
    nvim-navic
    rainbow-delimiters-nvim
    venn-nvim
    lualine-lsp-progress
    lualine-nvim
    nvim-autopairs
    orgmode
    # pkgs.tree-sitter-grammars.tree-sitter-org-nvim

    (fromGitHub
      "mcauley-penney/tidy.nvim"
      "HEAD"
      "f6c9cfc9ac5a92bb5ba3c354bc2c09a7ffa966f2")
    (fromGitHub
      "shellRaining/hlchunk.nvim"
      "HEAD"
      "5465dd33ade8676d63f6e8493252283060cd72ca")

    ##### USED RECENT AND DISLIKED
    /**
    parinfer-rust # IT BROKE UNDO!?!?!?!
    trouble-nvim # USELESS WHEN I KNOW HOW TO INTERACT WITH DIAG

    ### SHIT WAS EATING MY WORDS
    blink-cmp
    blink-cmp-words
    blink-cmp-dictionary
    */


    # (mitch-utils.mkNeorg pkgs.vimPlugins)
      /*
      aurora
      aylin-vim
      catppuccin-nvim
      conjure
      dracula-nvim
      guess-indent-nvim
      image-nvim
      kanagawa-nvim
      lspkind-nvim
      lsp_lines-nvim
      melange-nvim
      mini-icons
      neorg
      neorg-telescope
      neoscroll-nvim
      netrw-nvim
      nui-nvim
      nvim-cursorline
      # nvim-lspconfig
      nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-web-devicons

      neomodern-nvim

      plenary-nvim
      render-markdown-nvim
      rose-pine
      snacks-nvim
      tabby-nvim
      telescope-nvim
      vim-dispatch
      vim-jack-in
      vim-vsnip
      which-key-nvim
      (fromGitHub
        "Jxstxs/conceal.nvim"
        "HEAD"
        "1aff9fc5d1157aef1c7c88b6df6d6db21268d00a"
        )
*/

      /*
      (fromGitHub
       "Dan7h3x/signup.nvim"
        "HEAD"
        "2b21a2aa51efbdeb9454a3f5d62659368d87d420"
        )
      (fromGitHub
        "drybalka/tree-climber.nvim"
        "HEAD"
        "9b0c8c8358f575f924008945c74fd4f40d814cd7"
        )
      (fromGitHub
        "shellRaining/hlchunk.nvim"
        "HEAD"
        "5465dd33ade8676d63f6e8493252283060cd72ca"
        )
      (fromGitHub
        "srghma/nvimmer-ps"
        "HEAD"
        "9fd070a402e6b46ab10c1df5b4970de8346258bc"
        )
      */
    ];
}
