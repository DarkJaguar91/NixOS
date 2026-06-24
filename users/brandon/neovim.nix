{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      termguicolors = true;
      scrolloff = 8;
      updatetime = 250;
      timeoutlen = 300;
      splitbelow = true;
      splitright = true;
      undofile = true;
      clipboard = "unnamedplus";
      cursorline = true;
      ignorecase = true;
      smartcase = true;
    };

    # ── Colorscheme ───────────────────────────────────────────────────────────
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        integrations = {
          bufferline = true;
          cmp = true;
          flash = true;
          gitsigns = true;
          mini = {
            enabled = true;
          };
          neo_tree = true;
          noice = true;
          notify = true;
          snacks = true;
          telescope = {
            enabled = true;
          };
          treesitter = true;
          trouble = true;
          which_key = true;
        };
      };
    };

    plugins = {
      web-devicons.enable = true;

      # ── Statusline ────────────────────────────────────────────────────────
      lualine = {
        enable = true;
        settings.options = {
          theme = "catppuccin";
          component_separators = "|";
          section_separators = "";
        };
      };

      # ── Buffer line ───────────────────────────────────────────────────────
      bufferline = {
        enable = true;
        settings.options = {
          diagnostics = "nvim_lsp";
          always_show_bufferline = false;
        };
      };

      # ── Notifications ─────────────────────────────────────────────────────
      notify = {
        enable = true;
        settings = {
          render = "compact";
          timeout = 3000;
          stages = "fade";
        };
      };

      noice = {
        enable = true;
        settings = {
          lsp.override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
          presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
          };
        };
      };

      # ── Snacks (dashboard, indent guides, word highlights) ────────────────
      snacks = {
        enable = true;
        settings = {
          dashboard = {
            enabled = true;
          };
          indent = {
            enabled = true;
          };
          words = {
            enabled = true;
          };
          bigfile = {
            enabled = true;
          };
          quickfile = {
            enabled = true;
          };
          terminal = {
            enabled = true;
          };
        };
      };

      # ── Leader preview ────────────────────────────────────────────────────
      which-key = {
        enable = true;
        settings = {
          delay = 300;
          spec = [
            {
              __unkeyed-1 = "<leader>b";
              group = "Buffer";
            }
            {
              __unkeyed-1 = "<leader>e";
              group = "Explorer";
            }
            {
              __unkeyed-1 = "<leader>f";
              group = "Find";
            }
            {
              __unkeyed-1 = "<leader>g";
              group = "Git";
            }
            {
              __unkeyed-1 = "<leader>l";
              group = "LSP";
            }
            {
              __unkeyed-1 = "<leader>q";
              group = "Quit/Session";
            }
            {
              __unkeyed-1 = "<leader>s";
              group = "Search";
            }
            {
              __unkeyed-1 = "<leader>x";
              group = "Diagnostics";
            }
          ];
        };
      };

      # ── File tree ─────────────────────────────────────────────────────────
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          window.width = 30;
          window.mappings."l" = {
            __raw = ''
              function(state)
                local node = state.tree:get_node()
                if node.type == "directory" then
                  state.commands["toggle_node"](state)
                else
                  state.commands["open"](state)
                  vim.schedule(function() vim.cmd("wincmd l") end)
                end
              end
            '';
          };
          window.mappings."h" = {
            __raw = ''
              function(state)
                local node = state.tree:get_node()
                if node.type == "directory" and node:is_expanded() then
                  state.commands["toggle_node"](state)
                else
                  state.commands["navigate_up"](state)
                end
              end
            '';
          };
          filesystem = {
            filtered_items = {
              hide_dotfiles = false;
              hide_gitignored = false;
            };
            follow_current_file.enabled = true;
          };
        };
      };

      # ── File finder + grep ────────────────────────────────────────────────
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
        settings.defaults.mappings.i = {
          "<C-k>".__raw = "require('telescope.actions').move_selection_previous";
          "<C-j>".__raw = "require('telescope.actions').move_selection_next";
        };
      };

      # ── Flash navigation ──────────────────────────────────────────────────
      flash.enable = true;

      # ── Git ───────────────────────────────────────────────────────────────
      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
      };

      # ── Diagnostics list ──────────────────────────────────────────────────
      trouble = {
        enable = true;
        settings.modes.lsp.win.position = "right";
      };

      # ── TODO comments ─────────────────────────────────────────────────────
      todo-comments = {
        enable = true;
        settings.signs = true;
      };

      # ── Search and replace ────────────────────────────────────────────────
      grug-far.enable = true;

      # ── Syntax ────────────────────────────────────────────────────────────
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      treesitter-textobjects = {
        enable = true;
        settings.move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]f" = "@function.outer";
            "]c" = "@class.outer";
            "]a" = "@parameter.inner";
          };
          goto_next_end = {
            "]F" = "@function.outer";
            "]C" = "@class.outer";
          };
          goto_previous_start = {
            "[f" = "@function.outer";
            "[c" = "@class.outer";
            "[a" = "@parameter.inner";
          };
          goto_previous_end = {
            "[F" = "@function.outer";
            "[C" = "@class.outer";
          };
        };
      };

      ts-autotag.enable = true;

      # ── LSP ───────────────────────────────────────────────────────────────
      lsp = {
        enable = true;
        keymaps = {
          diagnostic = {
            "[d" = "goto_prev";
            "]d" = "goto_next";
            "<leader>lq" = "setloclist";
          };
          lspBuf = {
            "K" = "hover";
            "gd" = "definition";
            "gD" = "declaration";
            "gI" = "implementation";
            "gy" = "type_definition";
            "gr" = "references";
            "<leader>ld" = "definition";
            "<leader>lD" = "declaration";
            "<leader>li" = "implementation";
            "<leader>lr" = "references";
            "<leader>ln" = "rename";
            "<leader>la" = "code_action";
            "<leader>lf" = "format";
          };
        };
        servers = {
          lua_ls = {
            enable = true;
            settings.Lua = {
              diagnostics.globals = [ "vim" ];
              workspace.checkThirdParty = false;
              telemetry.enable = false;
            };
          };
          nil_ls = {
            enable = true;
            settings."nil".formatting.command = [ "nixfmt" ];
          };
        };
      };

      # ── Lua development ───────────────────────────────────────────────────
      lazydev = {
        enable = true;
        settings.library = [
          {
            path = "snacks.nvim";
            words = [ "Snacks" ];
          }
        ];
      };

      # ── Completion ────────────────────────────────────────────────────────
      luasnip = {
        enable = true;
        fromVscode = [ { } ];
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          snippet.expand.__raw = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
          mapping = {
            "<C-k>".__raw = "cmp.mapping.select_prev_item()";
            "<C-j>".__raw = "cmp.mapping.select_next_item()";
            "<C-b>".__raw = "cmp.mapping.scroll_docs(-4)";
            "<C-f>".__raw = "cmp.mapping.scroll_docs(4)";
            "<C-Space>".__raw = "cmp.mapping.complete()";
            "<C-e>".__raw = "cmp.mapping.abort()";
            "<CR>".__raw = "cmp.mapping.confirm({ select = false })";
            "<Tab>".__raw = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif require('luasnip').expand_or_jumpable() then
                  require('luasnip').expand_or_jump()
                else
                  fallback()
                end
              end, { "i", "s" })
            '';
            "<S-Tab>".__raw = ''
              cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif require('luasnip').jumpable(-1) then
                  require('luasnip').jump(-1)
                else
                  fallback()
                end
              end, { "i", "s" })
            '';
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          window = {
            completion.__raw = "cmp.config.window.bordered()";
            documentation.__raw = "cmp.config.window.bordered()";
          };
        };
      };

      # ── Mini plugins ──────────────────────────────────────────────────────
      mini = {
        enable = true;
        modules = {
          ai = {
            n_lines = 500;
          };
          pairs = { };
          surround = { };
        };
      };

      # ── Formatting ────────────────────────────────────────────────────────
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            fish = [ "fish_indent" ];
          };
          format_on_save = {
            lsp_fallback = true;
            timeout_ms = 3000;
          };
        };
      };

      # ── Linting ───────────────────────────────────────────────────────────
      lint = {
        enable = true;
        lintersByFt = {
          fish = [ "fish" ];
        };
      };

      # ── Session management ────────────────────────────────────────────────
      persistence.enable = true;
    };

    extraPackages = with pkgs; [
      ripgrep
      fd
      stylua
      nixfmt
    ];

    keymaps = [
      # ── Explorer ──────────────────────────────────────────────────────────
      {
        mode = "n";
        key = "<leader>ee";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Toggle Explorer";
      }
      {
        mode = "n";
        key = "<leader>ef";
        action = "<cmd>Neotree reveal<cr>";
        options.desc = "Reveal File";
      }

      # ── Find ──────────────────────────────────────────────────────────────
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd>Telescope oldfiles<cr>";
        options.desc = "Recent Files";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<cr>";
        options.desc = "Help Tags";
      }

      # ── Search / Grep ─────────────────────────────────────────────────────
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "Live Grep";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action = "<cmd>Telescope grep_string<cr>";
        options.desc = "Grep Word";
      }
      {
        mode = "n";
        key = "<leader>sr";
        action = "<cmd>GrugFar<cr>";
        options.desc = "Search & Replace";
      }
      {
        mode = "n";
        key = "<leader>st";
        action = "<cmd>TodoTelescope<cr>";
        options.desc = "Search TODOs";
      }

      # ── Buffers ───────────────────────────────────────────────────────────
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "Prev Buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<cmd>Neotree focus<cr>";
        options.desc = "Focus Explorer";
      }
      {
        mode = "n";
        key = "[b";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "Prev Buffer";
      }
      {
        mode = "n";
        key = "]b";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "Next Buffer";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>BufferLineTogglePin<cr>";
        options.desc = "Toggle Pin";
      }
      {
        mode = "n";
        key = "<leader>bP";
        action = "<cmd>BufferLineGroupClose ungrouped<cr>";
        options.desc = "Close Unpinned";
      }

      # ── Git ───────────────────────────────────────────────────────────────
      {
        mode = "n";
        key = "]h";
        action.__raw = "function() require('gitsigns').next_hunk() end";
        options.desc = "Next Hunk";
      }
      {
        mode = "n";
        key = "[h";
        action.__raw = "function() require('gitsigns').prev_hunk() end";
        options.desc = "Prev Hunk";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action.__raw = "function() require('gitsigns').stage_hunk() end";
        options.desc = "Stage Hunk";
      }
      {
        mode = "n";
        key = "<leader>gr";
        action.__raw = "function() require('gitsigns').reset_hunk() end";
        options.desc = "Reset Hunk";
      }
      {
        mode = "n";
        key = "<leader>gp";
        action.__raw = "function() require('gitsigns').preview_hunk() end";
        options.desc = "Preview Hunk";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action.__raw = "function() require('gitsigns').blame_line() end";
        options.desc = "Blame Line";
      }
      {
        mode = "n";
        key = "<leader>gd";
        action.__raw = "function() require('gitsigns').diffthis() end";
        options.desc = "Diff This";
      }

      # ── Diagnostics ───────────────────────────────────────────────────────
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        options.desc = "Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>xb";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options.desc = "Buffer Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>xl";
        action = "<cmd>Trouble loclist toggle<cr>";
        options.desc = "Location List";
      }
      {
        mode = "n";
        key = "<leader>xq";
        action = "<cmd>Trouble qflist toggle<cr>";
        options.desc = "Quickfix List";
      }

      # ── TODO ──────────────────────────────────────────────────────────────
      {
        mode = "n";
        key = "]t";
        action.__raw = "function() require('todo-comments').jump_next() end";
        options.desc = "Next TODO";
      }
      {
        mode = "n";
        key = "[t";
        action.__raw = "function() require('todo-comments').jump_prev() end";
        options.desc = "Prev TODO";
      }

      # ── Flash ─────────────────────────────────────────────────────────────
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "s";
        action.__raw = "function() require('flash').jump() end";
        options.desc = "Flash Jump";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action.__raw = "function() require('flash').treesitter() end";
        options.desc = "Flash Treesitter";
      }

      # ── Session ───────────────────────────────────────────────────────────
      {
        mode = "n";
        key = "<leader>qs";
        action.__raw = "function() require('persistence').load() end";
        options.desc = "Restore Session";
      }
      {
        mode = "n";
        key = "<leader>ql";
        action.__raw = "function() require('persistence').load({ last = true }) end";
        options.desc = "Last Session";
      }
      {
        mode = "n";
        key = "<leader>qd";
        action.__raw = "function() require('persistence').stop() end";
        options.desc = "Stop Session";
      }

      # ── Quit ──────────────────────────────────────────────────────────────
      {
        mode = "n";
        key = "<leader>qq";
        action = "<cmd>confirm qa<cr>";
        options.desc = "Quit All";
      }
    ];
  };
}
