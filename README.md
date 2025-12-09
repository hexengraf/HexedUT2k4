# HexedUT2k4 - Hexed Unreal Tournament 2004

The mutators and packages provided here were not extensively tested nor are guaranteed to work under every circumstance.
You can download and use the latest release at your own risk.

## Installation

Which archives you need to extract into your UT2004 installation depends on what you're going to use:
* HexedUT: no dependencies, you only need to download and extract the corresponding archive.
* HexedGUI: no dependencies, you only need to download and extract the corresponding archive.
* HexedUTComp: depends on HexedUT, even if you don't enable `MutHexedUT` in your server, so download and extract both.

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

HexedGUI is a client-side package providing better font scaling for higher resolutions (4K and 2K).
Some fonts in some places end up clipped or bigger than their backgrounds, but I still find it better than dealing with super small fonts.
Ideally, all GUI classes and related textures should be replaced to better handle scaling, but that is outside the scope of what I'm willing to do.

To use HexedGUI, replace the GUIController in the `UT2004.ini`:

```ini
[Engine.Engine]
; GUIController=GUI2K4.UT2K4GUIController
GUIController=HexedGUI.HxGUIController
```

Additionally, you can enable a cursor pointer replacement to make it smaller (only tested in 4K, might be too small in lower resolutions):
```ini
[HexedGUI.HxGUIController]
bFixedMouseSize=True
bSmallCursor=True
```

And you can also override the resolution used to scale the fonts (useful if your monitor is full HD with high DPI):
```ini
[HexedGUI.HxGUIFont]
OverrideX=2560 ; one of: 800, 1024, 1366, 1600, 1920, 2560, 3840
```

There is no version number in the package name due to being client-side only, but the latest version will always be included with the latest version of HexedUT.

## HexedUTComp

[HexedUTComp](https://github.com/hexengraf/HexedUTComp) is a fork of [WSUTComp](https://github.com/zenakuten/WSUTComp) made to work together with HexedUT and significantly reduce the amount of features.
For the sake of a streamlined building process, releases of HexedUTComp are bundled together with HexedUT here.

To enable it in a dedicated server, add `HexedUTCompvN.MutUTComp` to the mutators list (replace `N` with the current version).
`MutUTComp` can be enabled without enabling `MutHexedUT`, but if you want to use `mutate HexedUT` to configure it, you need to enable both.
