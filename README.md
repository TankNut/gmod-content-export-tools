# content-export-tools

These tools consist of a set of console commands that are designed to make extracting content from the game significantly easier by automating several aspects.

- Files are written to the `garrysmod/data/_export` folder directly from the game's virtual filesystem, no need to download or unpack gma files.
- You can perform bulk operations using [patterns](https://wiki.facepunch.com/gmod/Patterns) to export entire folders in one go.
- The type of content you export can be filtered. Never export base game, episodic or CS:S content by mistake.
- Dependencies are automatically handled. Models include all of their materials, materials include all of their textures and soundscripts export all of their sounds.

## Console commands

### Single files
