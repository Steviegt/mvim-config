-- Zeilennummern
vim.wo.number = true

-- Relative Zeilennummern
vim.wo.relativenumber = true

-- Leader Taste setzen
-- Leader = Präfix für eigene Tastenkürzel
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Tastenkürzel, um :wa und :q einfacher zu machen
--
-- Parameter 1: Mode (n = normal, i = insert…)
-- Parameter 2: Tastenkürzel (Leader, dann w für „write“)
-- Parameter 3: Andere Tasten
--              Doppelpunkt wa Enter; Doppelpunk q Enter
vim.keymap.set("n", "<leader>q", ":wa<CR> :q<CR>")

-- Hilfe-Links mit Enter folgen
vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = "help",
  callback = function ()
    vim.keymap.set("n", "<CR>", "<C-]>", {buffer = true})
  end
})

-- Beim Wiederöffnen einer Datei zur letzten Position springen
vim.api.nvim_command([[au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]])


-- Einrückung mit 4 Spaces als Standard
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true


-- Aktuelle Einrückung fortführen
vim.o.smartindent = true


-- Undo-Historie abspeichern
vim.opt.undofile = true

-- System-Clipboard verwenden
vim.o.clipboard = 'unnamedplus'

-- netrw ausschalten
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1 
