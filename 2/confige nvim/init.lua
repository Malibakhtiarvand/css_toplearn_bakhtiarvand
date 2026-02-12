-- Modern Neovim Configuration (init.lua)
-- Setup for lazy.nvim, LSP, Treesitter, and a beautiful UI

-- 1. Load Settings from JSON
local settings_path = vim.fn.stdpath("config") .. "/settings.json"
local settings = {
  theme = "catppuccin-mocha",
  line_numbers = true,
  relative_line_numbers = true,
  tab_size = 4,
  format_on_save = true,
}

local f = io.open(settings_path, "r")
if f then
  local content = f:read("*all")
  f:close()
  local ok, decoded = pcall(vim.fn.json_decode, content)
  if ok then
    settings = vim.tbl_deep_extend("force", settings, decoded)
  end
end

-- 2. Basic Settings
vim.g.mapleader = " "
vim.opt.encoding = "utf-8"
vim.opt.fileencodings = "utf-8,ucs-bom,cp1256,latin1"
vim.opt.number = settings.line_numbers
vim.opt.relativenumber = settings.relative_line_numbers
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = settings.tab_size
vim.opt.shiftwidth = settings.tab_size
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.scrolloff = 8

-- 3. Plugin Manager (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- UI: Dashboard (Startup Screen)
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }
      alpha.setup(dashboard.config)
    end,
  },

  -- UI: Bufferline (Tabs)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "thin",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        color_icons = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
  },

  -- UI: Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- UI: Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme(settings.theme)
    end,
  },

  -- UI: Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  -- UI: Modern LSP UI (Visual popups and actions)
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
          devicon = true,
        },
        lightbulb = {
          enable = true,
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Web Development: Auto close/rename HTML tags
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },

  -- Session Management: Auto-restore previous folder/session
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize" } },
    config = function(_, opts)
      require("persistence").setup(opts)
      -- Restore session on startup if Neovim is opened without arguments
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("persistence", { clear = true }),
        callback = function()
          if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
            require("persistence").load()
          end
        end,
      })
    end,
  },

  -- UI: Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- UI: Breadcrumbs (Toolbar-like file path)
  {
    "Bekaboo/dropbar.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    config = function()
      require("dropbar").setup()
    end,
  },

  -- UI: Visual Dialogs and Inputs
  {
    "stevearc/dressing.nvim",
    opts = {},
  },

  -- UI: Smooth Scrolling and Notifications
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  -- Syntax Highlighting: Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs", -- Use the new 'main' key for lazy.nvim
    opts = {
      ensure_installed = { 
        "lua", 
        "javascript", 
        "typescript", 
        "tsx", 
        "html", 
        "css", 
        "python", 
        "c_sharp", 
        "java",
        "json",
        "markdown"
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- LSP: Core Configuration
  {
    "neovim/nvim-lspconfig",
    version = "v1.*",
    dependencies = {
      "williamboman/mason.nvim",
      { "williamboman/mason-lspconfig.nvim", version = "1.*" },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = { 
          "lua_ls", 
          "pyright", 
          "ts_ls", 
          "html", 
          "cssls", 
          "tailwindcss", 
          "omnisharp",
          "jdtls" 
        },
      })

      -- Ensure non-LSP tools are installed via Mason
      local mr = require("mason-registry")
      local tools = { "prettier", "eslint_d", "black" }
      for _, tool in ipairs(tools) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- VS Code style on_attach
      local on_attach = function(client, bufnr)
        local nmap = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
        nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        nmap("K", vim.lsp.buf.hover, "Hover Documentation")
        nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
      end

      -- Setup servers using mason-lspconfig handlers (modern way)
      mason_lspconfig.setup_handlers({
        function(server_name)
          local opts = {
            capabilities = capabilities,
            on_attach = on_attach,
          }

          -- Language specific overrides
          if server_name == "ts_ls" then
            opts.settings = {
              javascript = {
                suggest = { autoImports = true },
                updateImportsOnFileMove = { enabled = "always" },
              },
              typescript = {
                suggest = { autoImports = true },
                updateImportsOnFileMove = { enabled = "always" },
              },
            }
          end

          if server_name == "pyright" then
            opts.settings = {
              python = {
                analysis = {
                  autoImportCompletions = true,
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  indexing = true, -- Enable indexing for better auto-imports
                },
              },
            }
          end

          if server_name == "omnisharp" then
            opts.settings = {
              RoslynExtensionsOptions = {
                EnableImportCompletion = true,
                EnableDecompilationSupport = true,
              },
            }
          end

          if server_name == "jdtls" then
            opts.settings = {
              java = {
                import = {
                  gradle = { enabled = true },
                  maven = { enabled = true },
                },
                contentProvider = { preferred = "fernflower" },
              },
            }
          end

          require("lspconfig")[server_name].setup(opts)
        end,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
          highlight_opened_files = "all",
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            window_picker = {
              enable = false,
            },
          },
        },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
      
      -- Open nvim-tree on startup
      vim.api.nvim_create_autocmd({ "VimEnter" }, {
        callback = function(data)
          -- buffer is a directory
          local directory = vim.fn.isdirectory(data.file) == 1

          if not directory then
            return
          end

          -- change to the directory
          vim.api.nvim_set_current_dir(data.file)

          -- open the tree
          require("nvim-tree.api").tree.open()
        end
      })
    end,
  },

  -- Discoverable Keybindings (Toolbar-like popup)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        icons = {
          breadcrumb = "»",
          separator = "➜",
          group = "+",
        },
      })
      -- Define VS Code like menu structure
      wk.add({
        { "<leader>f", group = "File" },
        { "<leader>e", group = "Edit" },
        { "<leader>v", group = "View" },
        { "<leader>s", group = "Selection" },
        { "<leader>g", group = "Go" },
        { "<leader>r", group = "Run/Debug" },
        { "<leader>t", group = "Terminal" },
        { "<leader>h", group = "Help" },
      })
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  -- Fuzzy Finder (Telescope)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          file_browser = {
            hijack_netrw = true,
            theme = "ivy",
          },
        },
      })
      telescope.load_extension("file_browser")
      
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set("n", "<leader>fd", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "File Browser" })
    end,
  },

  -- Git Integration
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  -- Multi-cursor support (VS Code style Ctrl+D)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-d>",
        ["Find Next"] = "<C-d>",
        ["Select All"] = "<C-S-l>",
      }
    end,
  },

  -- Quality of Life
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        python = { "black" },
      },
      format_on_save = settings.format_on_save and {
        timeout_ms = 500,
        lsp_fallback = true,
      } or nil,
    },
  },
  { "windwp/nvim-autopairs", opts = {} },
  { "numToStr/Comment.nvim", opts = {} },
})

-- VS Code Style Keybindings
local keymap = vim.keymap.set

-- Helper for Which-Key menus
local wk = require("which-key")

-- Native Windows Dialog Helpers (Robust version using Temp Scripts)
local function run_powershell_dialog(ps_code)
  local tmp_file = os.getenv("TEMP") .. "\\nvim_dialog_" .. os.time() .. ".ps1"
  local f = io.open(tmp_file, "w")
  if not f then return nil end
  
  -- Wrap code to ensure output is captured correctly
  local wrapped_code = [[
    $OutputEncoding = [System.Text.Encoding]::UTF8
    Add-Type -AssemblyName System.Windows.Forms
    $dialog_script = {
  ]] .. ps_code .. [[
    }
    $result = & $dialog_script
    if ($result) { Write-Host $result }
  ]]
  
  f:write(wrapped_code)
  f:close()
  
  local cmd = string.format("powershell -NoProfile -ExecutionPolicy Bypass -File %q", tmp_file)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  
  os.remove(tmp_file)
  return result:gsub("[\r\n]", "")
end

local function open_native_folder_dialog()
  local ps_code = [[
    $f = New-Object System.Windows.Forms.FolderBrowserDialog
    $f.Description = 'Select Folder'
    $f.ShowNewFolderButton = $true
    $top = New-Object System.Windows.Forms.Form
    $top.TopMost = $true
    if ($f.ShowDialog($top) -eq 'OK') { return $f.SelectedPath }
  ]]
  
  local result = run_powershell_dialog(ps_code)
  if result and result ~= "" then
    local path = result:gsub("\\", "/")
    vim.schedule(function()
      vim.cmd("cd " .. vim.fn.fnameescape(path))
      require("nvim-tree.api").tree.change_root(path)
      require("nvim-tree.api").tree.open()
      print("Opened folder: " .. path)
    end)
    return true
  end
  return false
end

local function open_native_file_dialog()
  local ps_code = [[
    $f = New-Object System.Windows.Forms.OpenFileDialog
    $f.Filter = 'All Files (*.*)|*.*'
    $top = New-Object System.Windows.Forms.Form
    $top.TopMost = $true
    if ($f.ShowDialog($top) -eq 'OK') { return $f.FileName }
  ]]
  
  local result = run_powershell_dialog(ps_code)
  if result and result ~= "" then
    local path = result:gsub("\\", "/")
    vim.schedule(function()
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end)
    return true
  end
  return false
end

-- Manual Path Input Fallbacks
local function manual_open_folder()
  vim.ui.input({ prompt = "Enter Folder Path: ", default = vim.fn.getcwd(), completion = "dir" }, function(input)
    if input and input ~= "" then
      local path = input:gsub("\\", "/")
      vim.cmd("cd " .. vim.fn.fnameescape(path))
      require("nvim-tree.api").tree.change_root(path)
      require("nvim-tree.api").tree.open()
      print("Changed directory to: " .. path)
    end
  end)
end

local function manual_open_file()
  vim.ui.input({ prompt = "Enter File Path: ", default = vim.fn.getcwd() .. "/", completion = "file" }, function(input)
    if input and input ~= "" then
      local path = input:gsub("\\", "/")
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end
  end)
end

-- Save Function with Robust Dialog Support
local function save_file()
  if vim.fn.expand("%" ) == "" then
    local ps_code = [[
      $f = New-Object System.Windows.Forms.SaveFileDialog
      $f.Filter = 'All Files (*.*)|*.*'
      $top = New-Object System.Windows.Forms.Form
      $top.TopMost = $true
      if ($f.ShowDialog($top) -eq 'OK') { return $f.FileName }
    ]]
    
    local result = run_powershell_dialog(ps_code)
    if result and result ~= "" then
      local path = result:gsub("\\", "/")
      vim.schedule(function()
        vim.cmd("write " .. vim.fn.fnameescape(path))
        print("File saved to: " .. path)
      end)
    else
      -- Manual fallback
      vim.ui.input({ prompt = "Save As (Manual Path): ", default = vim.fn.getcwd() .. "/" }, function(input)
        if input and input ~= "" then
          vim.cmd("write " .. vim.fn.fnameescape(input))
        end
      end)
    end
  else
    vim.cmd("write")
  end
end

-- Open in System Explorer (Windows)
local function open_in_explorer()
  local path = vim.fn.expand("%:p:h")
  if path == "" then path = vim.fn.getcwd() end
  vim.fn.jobstart({ "explorer.exe", path }, { detach = true })
end

-- Change Working Directory (Open Folder)
local function change_folder()
  vim.ui.input({ prompt = "Open Folder: ", default = vim.fn.getcwd(), completion = "dir" }, function(input)
    if input and input ~= "" then
      -- Normalize path for Windows
      local path = input:gsub("\\", "/")
      vim.cmd("cd " .. path)
      
      -- Refresh NvimTree
      local api = require("nvim-tree.api")
      api.tree.change_root(path)
      api.tree.open()
      api.tree.reload()
      
      print("Directory changed to: " .. path)
    end
  end)
end

-- File Menu Bindings
wk.add({
  { "<leader>f", group = "File" },
  { "<leader>fn", "<cmd>enew<CR>", desc = "New File" },
  { "<leader>fo", open_native_file_dialog, desc = "Open File (Dialog)" },
  { "<leader>fO", manual_open_file, desc = "Open File (Manual Path)" },
  { "<leader>fd", open_native_folder_dialog, desc = "Open Folder (Dialog)" },
  { "<leader>fD", manual_open_folder, desc = "Open Folder (Manual Path)" },
  { "<leader>fs", save_file, desc = "Save / Save As" },
  { "<leader>fe", open_in_explorer, desc = "Show in Explorer" },
  { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files (Quick)" },
  { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent Files" },
})

-- Edit Menu Bindings
wk.add({
  { "<leader>ez", "u", desc = "Undo" },
  { "<leader>ey", "<C-r>", desc = "Redo" },
  { "<leader>ex", '"+x', desc = "Cut" },
  { "<leader>ec", '"+y', desc = "Copy" },
  { "<leader>ev", '"+p', desc = "Paste" },
  { "<leader>ea", "ggVG", desc = "Select All" },
  { "<leader>ed", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "Go to Definition" },
  { "<leader>er", "<cmd>lua vim.lsp.buf.references()<CR>", desc = "Find References" },
  { "<leader>eh", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Show Documentation" },
})

-- VS Code Navigation (Ctrl+1, Ctrl+2, etc. for Tabs)
for i = 1, 9 do
  keymap("n", "<C-" .. i .. ">", function()
    vim.cmd("BufferLineGoToBuffer " .. i)
  end, { desc = "Go to Tab " .. i })
end

-- VS Code Line Movement (Alt+Up/Down)
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Visual Mode Indenting (Tab/Shift+Tab)
keymap("v", "<Tab>", ">gv", { desc = "Indent" })
keymap("v", "<S-Tab>", "<gv", { desc = "Outdent" })

-- View Menu Bindings
wk.add({
  { "<leader>vv", "<cmd>vsplit<CR>", desc = "Split Vertical" },
  { "<leader>vh", "<cmd>split<CR>", desc = "Split Horizontal" },
  { "<leader>ve", "<C-w>=", desc = "Equalize Windows" },
  { "<leader>vx", "<cmd>close<CR>", desc = "Close Current Window" },
  { "<leader>vt", "<cmd>Telescope colorscheme enable_preview=true<CR>", desc = "Change Theme" },
})

-- Terminal Menu Bindings
wk.add({
  { "<leader>tt", "<cmd>ToggleTerm<CR>", desc = "Toggle Terminal" },
  { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Float Terminal" },
  { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal Terminal" },
  { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical Terminal" },
})

-- Global Keymaps (VS Code style)
keymap("n", "<C-s>", save_file, { desc = "Save" })
keymap("n", "<C-o>", function()
  -- Try dialog, if no result, do nothing (user can use manual from menu)
  open_native_file_dialog()
end, { desc = "Open File" })
keymap("n", "<C-S-o>", function()
  open_native_folder_dialog()
end, { desc = "Open Folder" })
keymap("i", "<C-s>", function()
  vim.cmd("stopinsert")
  save_file()
end, { desc = "Save File" })
keymap("n", "<C-a>", "ggVG", { desc = "Select All" })

-- Undo/Redo (Ctrl+Z, Ctrl+Y)
keymap({ "n", "i", "v" }, "<C-z>", function()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  vim.cmd("undo")
end, { desc = "Undo" })

keymap({ "n", "i", "v" }, "<C-y>", function()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
  vim.cmd("redo")
end, { desc = "Redo" })

-- Copy / Paste (Ctrl+C, Ctrl+V, Ctrl+X)
keymap("v", "<C-c>", '"+y', { desc = "Copy" })
keymap("v", "<C-x>", '"+x', { desc = "Cut" })
keymap({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste" })
keymap("i", "<C-v>", '<C-r>+', { desc = "Paste from Clipboard" })

-- Select Line (Ctrl+L)
keymap("n", "<C-l>", "V", { desc = "Select Line" })

-- Search & Replace (Ctrl+H)
keymap("n", "<C-h>", ":%s/", { desc = "Search and Replace" })

-- Multi-cursor hints (Ctrl+D is handled by vim-visual-multi)
-- Ctrl+D: Select word under cursor / next occurrence

-- Files & Explorer
keymap("n", "<C-b>", ":NvimTreeToggle<CR>", { desc = "Toggle Sidebar" })
keymap("n", "<C-p>", ":Telescope find_files<CR>", { desc = "Find Files" })
keymap("n", "<C-f>", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Search in File" })
keymap("n", "<C-S-f>", ":Telescope live_grep<CR>", { desc = "Global Search" })

-- Navigation (Tabs/Buffers/Windows)
keymap("n", "<C-Tab>", ":BufferLineCycleNext<CR>", { desc = "Next Tab" })
keymap("n", "<C-S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "Prev Tab" })
keymap("n", "<C-w>", ":bd<CR>", { desc = "Close Tab" })
keymap("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Split Vertical" })
keymap("n", "<C-->", "<cmd>split<CR>", { desc = "Split Horizontal" })

-- Window Navigation (Alt + Arrow Keys)
keymap("n", "<A-Left>", "<C-w>h", { desc = "Go to Left Window" })
keymap("n", "<A-Right>", "<C-w>l", { desc = "Go to Right Window" })
keymap("n", "<A-Up>", "<C-w>k", { desc = "Go to Up Window" })
keymap("n", "<A-Down>", "<C-w>j", { desc = "Go to Down Window" })

-- Terminal
keymap("n", "<C-`>", ":ToggleTerm<CR>", { desc = "Toggle Terminal" })
keymap("t", "<C-`>", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })

-- Editing
keymap("v", "<C-/>", "gc", { remap = true, desc = "Comment Selection" })
keymap("n", "<C-/>", "gcc", { remap = true, desc = "Comment Line" })
keymap("i", "<C-/>", "<esc>gcci", { remap = true, desc = "Comment Line" })

-- Move Lines (Alt + Up/Down)
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move Line Down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move Line Up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

-- LSP Visual Actions (Lspsaga)
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Docs" })
keymap("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Go to Definition" })
keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code Action" })
keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Rename" })
keymap("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line Diagnostics" })

-- Final Keybindings
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear search highlight
