# MountScripts

Script collection for mount/climbing Roblox games.

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Anggahrm/MountScripts/main/src/init.lua"))()
```

## Architecture

- `src/init.lua` — entry point and loader.
- `src/elements.lua` — shared UI framework and game-module loader.
- `src/games/<PlaceId>.lua` — game-specific modules loaded by the UI framework.
- `remote_logger.lua` — standalone debugging utility; it is not part of the game-module loader.

## Game module contract

Every file loaded from `src/games/` must return a function that accepts the shared `ui` object:

```lua
return function(ui)
    -- game-specific implementation
end
```

The loader requests exactly `src/games/<game.PlaceId>.lua`, so versioned or experimental files such as `*_v3.lua` are not loaded automatically.

## Custom Games

Place `.lua` files named by PlaceId in the `src/games/` folder and follow the game-module contract above.
