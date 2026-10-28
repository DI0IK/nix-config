{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      plenary-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      nvim-web-devicons
      telescope-nvim
      (nvim-treesitter.withPlugins (p: with p; [ rust typescript tsx javascript markdown markdown_inline ]))
      rustaceanvim
      typescript-tools-nvim
      render-markdown-nvim
      markdown-preview-nvim
      conform-nvim
    ];

    extraPackages = with pkgs; [
      rust-analyzer
      rustfmt
      clippy
      typescript-language-server
      nodejs
      marksman
      ripgrep
      fd
      prettier
    ];

    initLua = ''
      -- Basic options
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"

      -- Treesitter
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- Completion
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      -- LSP capabilities
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Rust (rustaceanvim handles LSP)
      vim.g.rustaceanvim = {
        server = {
          capabilities = capabilities,
        },
      }

      -- TypeScript
      require('typescript-tools').setup({
        capabilities = capabilities,
      })

      -- Markdown
      require('render-markdown').setup({})

      -- Formatting
      require('conform').setup({
        formatters_by_ft = {
          rust = { "rustfmt" },
          typescript = { "prettier" },
          javascript = { "prettier" },
          typescriptreact = { "prettier" },
          javascriptreact = { "prettier" },
          markdown = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- Keymaps
      vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
      vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
      vim.keymap.set('n', '<leader>fm', '<cmd>Format<cr>')
    '';
  };
}
