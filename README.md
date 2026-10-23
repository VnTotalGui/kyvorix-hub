# KYVORIX Hub

Private development snapshot: v5, Potassium test target.

Kyvorix.lua is the current standalone Roblox UI source. It includes the transparent KYVORIX logo, local-image loading when supported, Roblox-image fallback, eight pages, motion controls, three palettes, local interface profiles and read-only character information when the game exposes it.

The accompanying PNG is the editable source logo. The same image is embedded in the Lua file, so a separate download is not required for that route.

Gameplay automation, Auto Farm, Auto Stat, raids and progression quests are not implemented. Related UI entries are marked unavailable. Universal executor compatibility is not claimed.

Source review and PNG byte-integrity checks have passed. The current build has not yet completed in-game runtime testing. Earlier runtime inspection observed an unavailable Roblox-hosted image in a previous build. The current source includes local PNG fallbacks.

For Studio, place the source in a LocalScript under StarterPlayerScripts. Executor-specific filesystem and custom-asset functions are optional and checked before use.

This repository is private. An unauthenticated public raw loader is not supplied, and no GitHub token should be embedded in a distributed script.
