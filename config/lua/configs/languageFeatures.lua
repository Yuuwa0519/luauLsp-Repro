-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require("cmp")
local luaSnip = require("luasnip")

luaSnip.config.setup()

cmp.setup({
	snippet = {
		expand = function(args)
			luaSnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luaSnip.expand_or_locally_jumpable() then
				luaSnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luaSnip.locally_jumpable(-1) then
				luaSnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	window = {
		completion = {
			border = "double",
		},
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "luasnip" },
	}),
})

-- Language Server
local mason = require("mason")
local masonLspConfig = require("mason-lspconfig")
local cmpNvimLsp = require("cmp_nvim_lsp")
local luauLsp = require("luau-lsp")
local lspConfig = require("lspconfig")

local installingServers = {
	luau_lsp = {},
}

local function onAttach(client, bufferNumber)
	-- print(client.name, "attached to", bufferNumber)

	vim.keymap.set("n", "gh", vim.lsp.buf.hover)
	vim.keymap.set("n", "gf", vim.diagnostic.open_float)
	vim.keymap.set("n", "gr", vim.lsp.buf.references)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition)
	vim.keymap.set("n", "<F2>", vim.lsp.buf.rename)

	if client.name == "luau_lsp" or client.name == "lua_ls" then
		vim.cmd([[autocmd BufWritePre <buffer> lua require("stylua-nvim").format_file()]])
	else
		vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]])
	end
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmpNvimLsp.default_capabilities(capabilities)

vim.filetype.add({
	extension = {
		luau = "luau",
	},
})

mason.setup()
masonLspConfig.setup({
	ensure_installed = vim.tbl_keys(installingServers),
})
masonLspConfig.setup_handlers({
	function(serverName)
		-- print("Setting up", serverName)

		lspConfig[serverName].setup({
			capabilities = capabilities,
			on_attach = onAttach,
			settings = installingServers[serverName],
			filetypes = (installingServers[serverName] or {}).filetypes,
		})
	end,
	luau_lsp = function()
		-- print("Setting up luau_lsp")

		luauLsp.setup({
			server = {
				on_attach = onAttach,
				settings = {
					["luau-lsp"] = {
						completion = {
							imports = {
								enabled = true,
								separateGroupsWithLine = true,
							},
							autocompleteEnd = true,
						},
					},
				},
			},
		})
	end,
})

-- Syntax Highlighting
local nvimTreesitterConfigs = require("nvim-treesitter.configs")

luauLsp.treesitter()
nvimTreesitterConfigs.setup({
	ensure_installed = { "lua", "luau", "rust" },

	highlight = { enable = true },
	indent = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<M-space>",
		},
	},
})
