local mountFilter = CreateClientConVar("cet_filter_mount", "garrysmod,hl2,cstrike", true, false, "Ignores any files provided by these mounted games")
local folderFilter = CreateClientConVar("cet_filter_folders", "", true, false, "Ignores any files matching these partial paths")

local baseColor = Color(255, 255, 255)
local okColor = Color(0, 255, 0)
local warnColor = Color(255, 191, 0)
local errorColor = Color(255, 0, 0)

local function msg(str, ...) MsgC(baseColor, string.format(str, ...), "\n") end
local function ok(str, ...) MsgC(okColor, "\t", string.format(str, ...), "\n") end
local function warn(str, ...) MsgC(warnColor, "\t", string.format(str, ...), "\n") end
local function err(str, ...) MsgC(errorColor, "\t", string.format(str, ...), "\n") end

local parsedMounts = string.Explode(",", mountFilter:GetString())
local parsedfolders = string.Explode(",", folderFilter:GetString())

cvars.AddChangeCallback("cet_filter_mount", function(_, _, new) parsedMounts = string.Explode(",", new) end)
cvars.AddChangeCallback("cet_filter_folders", function(_, _, new) parsedfolders = string.Explode(",", new) end)

file.CreateDir("_export")

local function checkFilter(path)
	for _, mountPath in ipairs(parsedMounts) do
		if file.Exists(path, mountPath) then
			warn("Skipping %s: Part of mount '%s'", path, mountPath)

			return false
		end
	end

	for _, folderPath in ipairs(parsedfolders) do
		if #folderPath < 1 then
			continue
		end

		if string.find(path, folderPath) then
			warn("Skipping %s: Matches folder '%s'", path, folderPath)

			return false
		end
	end

	return true
end

local fileList = {}

local function addFile(path)
	if not file.Exists(path, "GAME") then
		warn("Skipping %s: File not found", path)
		return false
	end

	if not checkFilter(path) then
		return false
	end

	if file.Exists("_export/" .. path, "DATA") then
		warn("Skipping %s: File already exists in _export", path)

		return false
	end

	fileList[path] = true

	ok("Found file: %s", path)

	return true
end

local textureBlacklist = {
	["effects/flashlight001"] = true
}

local function processMaterial(path)
	if path == "___error" or Material(path):GetName() == "___error" then
		err("*** Encountered ___error material, some materials may be missing! ***")

		return
	end

	msg("Material: %s", path)

	if not addFile("materials/" .. path .. ".vmt") then
		return
	end

	for _, texture in pairs(Material(path):GetKeyValues()) do
		if type(texture) != "ITexture" then
			continue
		end

		local name = texture:GetName()

		if textureBlacklist[name] then
			continue
		end

		addFile("materials/" .. name .. ".vtf")
	end
end

local function getModelMaterials(mdl)
	local ent = ClientsideModel(mdl)

	ent:SetModel(mdl)
	ent:Spawn()
	ent:Activate()

	local materials = ent:GetMaterials()

	ent:Remove()

	return materials
end

local function processModel(path)
	msg("Model: %s", path)

	if not addFile(path) then
		return
	end

	local short = string.Left(path, -5)

	addFile(short .. ".vvd")
	addFile(short .. ".dx80.vtx")
	addFile(short .. ".dx90.vtx")
	addFile(short .. ".phy")
	addFile(short .. ".ani")

	for _, mat in ipairs(getModelMaterials(path)) do
		processMaterial(mat)
	end
end

local function processSoundscript(snd)
	msg("Soundscript: %s", snd)

	local props = sound.GetProperties(snd)

	if not props then
		warn("Skipping %s: Soundscript not found", snd)
	end

	if istable(props.sound) then
		for _, path in ipairs(props.sound) do
			addFile("sound/" .. path)
		end
	else
		addFile("sound/" .. props.sound)
	end
end

local function getFileList(basePath, filetypes)
	local foundFiles = {}

	if not istable(filetypes) then
		filetypes = {filetypes}
	end

	local function recurse(subPath)
		local files, folders = file.Find(subPath .. "/*", "GAME")

		for _, path in ipairs(files) do
			local extension = string.GetExtensionFromFilename(path)
			local found = false

			for _, filetype in ipairs(filetypes) do
				if extension == filetype then
					found = true

					break
				end
			end

			if not found then
				continue
			end

			path = subPath .. "/" .. path

			table.insert(foundFiles, path)
		end

		for _, folder in ipairs(folders) do
			recurse(subPath .. "/" .. folder)
		end
	end

	recurse(basePath)

	return foundFiles
end

local function write(path, contents)
	file.CreateDir(string.GetPathFromFilename(path))
	file.Write(path, contents)
end

local function init()
	fileList = {}
end

local function finish()
	local i = 0

	for path in pairs(fileList) do
		i = i + 1
		write("_export/" .. path, file.Read(path, "GAME"))
	end

	msg(string.format("Exported %s files to data/_export/", i))

	fileList = {}
end

local function handleBulk(files, func)
	local count = #files

	ok("Found %s files to process", count)
	warn("Run export_abort to abort processing")

	local i = 1

	hook.Add("PostRender", "cet_bulk", function()
		if i > count then
			msg("Finished running %s exports!", count)
			hook.Remove("PostRender", "cet_bulk")

			return
		end

		msg("Bulk processing: %s/%s (%.2f%%)", i, count, (i / count) * 100)

		func(files[i])
		finish()

		i = i + 1
	end)
end

concommand.Add("export_abort", function()
	msg("Aborted processing")
	hook.Remove("PostRender", "cet_bulk")
end)

concommand.Add("mdl_export", function(_, _, _, mdl)
	if string.Right(mdl, 4) != ".mdl" then
		return
	end

	init()
	processModel(mdl)
	finish()
end)

concommand.Add("mdl_export_bulk", function(_, _, _, path)
	if string.Right(path, 1) == "/" then
		path = string.sub(path, 1, -1)
	end

	msg("Bulk processing models: %s", path)

	init()
	handleBulk(getFileList(path, "mdl"), processModel)
end)

concommand.Add("mat_export", function(_, _, _, mat)
	init()
	processMaterial(mat)
	finish()
end)

concommand.Add("mat_export_bulk", function(_, _, _, path)
	if string.Right(path, 1) == "/" then
		path = string.sub(path, 1, -1)
	end

	msg("Bulk processing materials: %s", path)

	init()
	handleBulk(getFileList(path, "vmt"), processMaterial)
end)

concommand.Add("snd_export", function(_, _, _, snd)
	init()
	msg("Sound: sound/%s", snd)
	addFile("sound/" .. snd)
	finish()
end)

concommand.Add("snd_export_bulk", function(_, _, _, path)
	if string.Right(path, 1) == "/" then
		path = string.sub(path, 1, -1)
	end

	msg("Bulk processing sounds: %s", path)

	init()
	handleBulk(getFileList(path, {"ogg", "wav", "mp3"}), addFile)
end)

concommand.Add("soundscript_export", function(_, _, _, soundscript)
	init()
	processSoundscript(soundscript)
	finish()
end)

concommand.Add("soundscript_export_bulk", function(_, _, _, soundscript)
	local scripts = {}

	for _, name in sound.GetTable() do
		if string.find(name, soundscript) then
			table.insert(scripts, name)
		end
	end

	init()
	handleBulk(scripts, processSoundscript)
end)
