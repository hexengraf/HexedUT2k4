# HexedUT2k4 - Hexed Unreal Tournament 2004

This repository is a collection of mutators and packages I've developed to use while playing with friends.
It is not extensively tested nor guaranteed to work under every circumstance.
You can download and use the latest release at your own risk (there is no official release yet, v1 coming soon).

## HexedUT

HexedUT is a UT2004 mutator that provides features that enhance the game experience without affecting core gameplay.
It should be compatible with any other mutator (no core game classes are replaced) and can be used in dedicated/listen servers.

Current features:
* Hit sounds
* Damage numbers

To enable it in a dedicated server, add `HexedUTvN.MutHexedUT` to the mutators list (replace `N` with the current version).
All configuration can be customized through an in-game menu accessible via `mutate HexedUT` command in the console.
It is a good idea to bind it to a key (e.g. `set input F5 mutate HexedUT`).

## HexedGUI

HexedGUI is a client-side package providing better font scaling for higher resolutions (1440p and 2560p).
Some fonts in some places end up clipped or bigger than their backgrounds, but I still find it better than dealing with super small fonts.
Ideally, all GUI classes and related textures should be replaced to better handle scaling, but that is outside the scope of what I'm willing to do.

To use HexedGUI, replace the GUIController in the `UT2004.ini`:

```ini
[Engine.Engine]
; GUIController=GUI2K4.UT2K4GUIController
GUIController=HexedGUI.HxGUIController
```

There is no version number in the package name due to being client-side only, but the latest version will always be included with the latest version of HexedUT.

## HexedUTComp

[HexedUTComp](https://github.com/hexengraf/HexedUTComp) is a fork of [WSUTComp](https://github.com/zenakuten/WSUTComp) made to work together with HexedUT and significantly reduce the amount of features.
For the sake of a streamlined building process, releases of HexedUTComp are bundled together with HexedUT here.

To enable it in a dedicated server, add `HexedUTCompvN.MutUTComp` to the mutators list (replace `N` with the current version).
`MutUTComp` can be enabled without enabling `MutHexedUT`, but if you want to use `mutate HexedUT` to configure it, you need to enable both.
