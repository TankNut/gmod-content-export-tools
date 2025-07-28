content-export-tools
=========
These tools consist of a set of console commands that are designed to make extracting content from the game significantly easier by automating several aspects.

- Files are written to the `garrysmod/data/_export` folder directly from the game's virtual filesystem, no need to download or unpack gma files.
- You can perform bulk operations to export entire folder structures in one go.
- Any content part of the base game or any mounted source games is ignored.
- Dependencies are automatically handled. Models include all of their materials, materials include all of their textures and soundscripts export all of their sounds.

Console commands
---

- `mdl_export <mdl>` - Exports a model and it's materials.
- `mat_export <material>` - Exports a material and it's textures.
- `snd_export <sound>` - Exports a single sound file.
- `soundscript_export <script>` - Exports all of the sounds used in a specific soundscript.
- `pcf_export <pcf>` - Exports a .pcf file with all of it's materials.

Bulk commands
---

Each of the above commands also has a `_bulk` variant, which takes a partial path (e.g. `models/hunter/misc`) and recursively handles all the files it finds. For soundscripts, it supports [patterns](https://wiki.facepunch.com/gmod/Patterns) instead.

Console variables
---

- `cet_filter_folders` - A comma-separated list of patterns used to ignore specific file paths when exporting files.
