# nvim-sniptip

Snippets manager

## 🔒 Requirements
* Install the lates version of [sniptip tool](https://github.com/anfelo/sniptip)
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "anfelo/sniptip.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        vim.keymap.set("n", "<leader>sl", require("sniptip").list)
        vim.keymap.set("v", "<leader>sa", require("sniptip").add)
    end
}
```

## 📚 Documentation

See `:help sniptip.nvim`

A pluggin for saving snippets of text and retrive them later. It uses the
[sniptip tool](https://github.com/anfelo/sniptip) under the hood so make sure
to install that first.
