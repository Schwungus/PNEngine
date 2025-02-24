# PNEngine

PNEngine is a fully external 3D engine for GameMaker with support for modding
and local multiplayer with up to 4 players.

## Multiplayer (EXPERIMENTAL)

These steps require the developer console, which you can open by pressing `~`
(`Ö` on Nordic keyboard layouts) on Windows.

### Local

PNEngine uses input device hotswapping by default. If you want to add other
players using separate input devices, type `config in_mode 1` into the console
to enable join mode (use value `2` to revert back to hotswap). If you save your
current settings after doing this, it will persist until you reset your
settings to defaults.

You can assign a new player to an input device by pressing any button on it.
Once assigned, that player is readied and will be able to play when the level
changes.

Players can unready or leave the game by pressing `Backspace` on their keyboard
or `Select` on their gamepad.

## Credits

PNEngine was created by **[Can't Sleep](https://cantsleep.cc)**.

The curve shader is from **[Mors](https://mors-games.com/)**' [Super Mario 64 Plus Launcher](https://github.com/MorsGames/sm64plus-launcher).

### Special Thanks

- **[Alynne Keith](https://offalynne.neocities.org)** and **[Co](https://offalynne.github.io/Input/#/6.0/Credits)** for [Input](https://github.com/offalynne/Input)
- **Jaydex**, **[nonk](https://nonk.dev)**, **[Sable](https://github.com/circuitsable)** and **Soh** for beta testing
- **[Juju Adams](https://www.jujuadams.com)** for [Scribble](https://github.com/JujuAdams/Scribble)
- **[katsaii](https://www.katsaii.com)** for [Catspeak](https://www.katsaii.com/catspeak-lang)
- **[Nikita Krapivin](https://github.com/nkrapivin)** for [NekoPresence](https://github.com/nkrapivin/NekoPresence)
- **[Patrik Kraif](https://github.com/kraifpatrik)** for [BBMOD](https://blueburn.cz/bbmod)
- **[TabularElf](https://tabularelf.com)** for [Canvas](https://github.com/tabularelf/Canvas), [Collage](https://github.com/tabularelf/Collage), [Lexicon](https://github.com/tabularelf/lexicon) and [MultiClient](https://github.com/tabularelf/MultiClient)
- **[YoYo Games](https://yoyogames.com)** for [GMEXT-FMOD](https://github.com/YoYoGames/GMEXT-FMOD)