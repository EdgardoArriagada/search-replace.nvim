local M = {}

local function execute(str)
	vim.cmd(vim.api.nvim_replace_termcodes(str, true, true, true))
end

local function escapeForRegex(x)
	return (
		x:gsub("%\\", "\\\\")
			:gsub("%^", "\\^")
			:gsub("%$", "\\$")
			:gsub("%~", "\\~")
			:gsub("%.", "\\.")
			:gsub("%[", "\\[")
			:gsub("%]", "\\]")
			:gsub("%*", "\\*")
			:gsub("%+", "\\+")
			:gsub("%-", "\\-")
			:gsub("%/", "\\/")
			:gsub("%&", "\\&")
	)
end

M.searchAndReplace = function()
	local currPos = vim.fn.col(".")
	local currLine = vim.fn.line(".")
	local startVisualPos = vim.fn.getpos("v")[3]
	local vSelection = string.sub(currLine, startVisualPos, currPos)
	local seq_cur = vim.fn.undotree().seq_cur

	local okGetReplaceString, replaceString = pcall(vim.fn.input, "Replace: ", vSelection)

	execute("normal<Esc>")

	if not okGetReplaceString then
		return
	end

	local search = escapeForRegex(vSelection)
	local replace = escapeForRegex(replaceString)

	-- `:h range` or `:h substitute` to see more config options
	local searchAndReplaceInline = "s/\\%>" .. startVisualPos - 1 .. "c" .. search .. "/" .. replace .. "/gcI"
	local searchAndReplaceNext = currLine + 1 .. ",$s/" .. search .. "/" .. replace .. "/gcI"

	local ok, _ = pcall(execute, searchAndReplaceInline)

	if not ok then
		vim.cmd("undo " .. seq_cur)
		execute("nohlsearch")
		return
	end

	local ok2, _ = pcall(execute, searchAndReplaceNext)

	if not ok2 then
		vim.cmd("undo " .. seq_cur)
		execute("nohlsearch")
		return
	end

	execute("nohlsearch")
end

return M
