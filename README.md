# PNEngine

PNEngine is a fully external 3D engine for GameMaker with support for modding
and local/online multiplayer with up to 4 players.

## Multiplayer

### Local

PNEngine uses input device hotswapping by default. If you want to add other
players by using different input devices, launch the game with the
`-multiplayer` command line.

You can assign a new player to an input device by pressing any button on it.
Once assigned, that player is readied and will be able to play when the level
changes.

Players can unready or leave the game by pressing `Backspace` on their keyboard
or `Select` on their gamepad.

### Online (EXPERIMENTAL)

Deterministic lockstep and client-side prediction are used for netgames, so you
need minimal ping with other players for a smooth experience.
Desyncs are entirely dependent on the mods that users have enabled and
whether or not they are properly scripted to be fully deterministic.

- Open the developer console by pressing `~` (`Ö` on Nordic keyboard layouts).
- Host the game on the title screen (`lvlTitle`) with the console command `host [port]`. Other players can connect with `connect <ip> [port]`.

## Credits

PNEngine was created by **[Can't Sleep](https://cantsleep.cc)**.

The curve shader is from **[Mors](https://mors-games.com/)**' [Super Mario 64 Plus Launcher](https://github.com/MorsGames/sm64plus-launcher).

### Special Thanks

- **[Alynne Keith](https://offalynne.neocities.org)** and **[Co](https://offalynne.github.io/Input/#/6.0/Credits)** for [Input](https://github.com/offalynne/Input)
- **Jaydex**, **[nonk](https://nonk.dev)** and **Soh** for beta testing multiplayer
- **[Juju Adams](https://www.jujuadams.com)** for [Scribble](https://github.com/JujuAdams/Scribble)
- **[katsaii](https://www.katsaii.com)** for [Catspeak](https://www.katsaii.com/catspeak-lang)
- **[Nikita Krapivin](https://github.com/nkrapivin)** for [NekoPresence](https://github.com/nkrapivin/NekoPresence)
- **[Patrik Kraif](https://github.com/kraifpatrik)** for [BBMOD](https://blueburn.cz/bbmod)
- **[TabularElf](https://tabularelf.com)** for [Canvas](https://github.com/tabularelf/Canvas), [Collage](https://github.com/tabularelf/Collage), [Lexicon](https://github.com/tabularelf/lexicon) and [MultiClient](https://github.com/tabularelf/MultiClient)
- **[YoYo Games](https://yoyogames.com)** for [GMEXT-FMOD](https://github.com/YoYoGames/GMEXT-FMOD)