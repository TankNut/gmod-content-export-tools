content-export-tools
=========
These tools consist of a set of console commands that are designed to make extracting content from the game significantly easier by automating several aspects.

- Files are written to the `garrysmod/data/_export` folder directly from the game's virtual filesystem, no need to download or unpack gma files.
- You can perform bulk operations to export entire folder structures in one go.
- The type of content you export can be filtered. Never export base game, episodic or CS:S content by mistake.
- Dependencies are automatically handled. Models include all of their materials, materials include all of their textures and soundscripts export all of their sounds.

Console commands
---

- `mdl_export <mdl>` - Exports a model and it's materials.
- `mat_export <material>` - Exports a material and it's textures.
- `snd_export <sound>` - Exports a single sound file.
- `soundscript_export <script>` - Exports all of the sounds used in a specific soundscript.

Bulk commands
---

Each of the above commands also has a `_bulk` variant, which takes a partial path (e.g. `models/hunter/misc`) and recursively handles all the files it finds. For soundscripts, it supports [patterns](https://wiki.facepunch.com/gmod/Patterns) instead.

Console variables
---

- `cet_filter_mount` - A comma-separated list of [file search paths](https://wiki.facepunch.com/gmod/File_Search_Paths) to ignore when exporting files.
- `cet_filter_folders` - A comma-separated list of patterns used to ignore specific file paths when exporting files.
