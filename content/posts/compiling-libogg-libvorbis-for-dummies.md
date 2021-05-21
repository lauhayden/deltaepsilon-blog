+++
title = "Compiling libogg and libvorbis on Windows for Dummies"
date = 2021-05-20T19:31:10-04:00
tags = []
categories = []
draft = false
+++

I don't have much experience with Visual Studio (I'm a linux/gcc person) so I wasted a few hours messing around to get this to work. Hopefully this'll save someone some time.

## Procedure

### libogg

1. Download Visual Studio 2019 Community installer from https://visualstudio.microsoft.com/downloads/

2. Install Visual Studio 2019 Community, selecting the "Desktop Development with C++ option"
![Choose Visual Studio 2019 Community in the installer](/images/compiling-libogg-libvorbis-for-dummies/vs-install-1.png)
![Choose Desktop Development with C++ option](/images/compiling-libogg-libvorbis-for-dummies/vs-install-2.png)

3. Download `libogg` and `libvorbis` from https://xiph.org/downloads/, extracting to the same folder. `libogg-x.y.z` and `libvorbis-x.y.z` folders should be side-by-side.

4. Open `libogg-x.y.z/win32/VS2015/libogg.sln`. if there is an error saying that the project was not loaded, close Visual Studio and re-open.
![Re-open the solution file if you see a loading error](/images/compiling-libogg-libvorbis-for-dummies/loading-error.png)

5. If prompted, accept the upgrade to Platform Toolset v142 and Windows SDK 10.0 (latest installed version). If no prompt appears, you can retarget to those options by right-clicking on `libogg` in the `Solution Explorer` pane, or by using the Project menu: `Project` > `Properties` > `All Configurations, All Platforms` > `Windows SDK Version & Platform Toolset`.
![Accept the upgrade prompt](/images/compiling-libogg-libvorbis-for-dummies/upgrade-prompt.png)

6. Select Configuration and Platform in the toolbar up top. Select `Debug`/`Release` if you need a `.lib` to link against statically. Select `DebugDLL`/`ReleaseDLL` if you need a `.dll` to link against dynamically. `Win32` if you need 32-bit, otherwise `x64`.

7. Build!

### libvorbis

You'll need `libogg` to compile `libvorbis`, so make sure all the steps above are completed.

1. Edit `libvorbis-x.y.z/win32/VS2010/libogg.props`, check that the `LIBOGG_VERSION` is the same as what  you've downloaded.

2. Open `libvorbis-x.y.z/win32/VS2010/vorbis_{dynamic,static}.sln`. If you need a `.lib`, choose `vorbis_static.sln`. If you need a `.dll`, choose `vorbis_dynamic.sln`.

3. Similar to `libogg`, accept the upgrade or retarget.

4. Select Configuration and Platform. Since the solution files are different this time, there's only two configurations: `Debug`/`Release`.

5. Build! If there's an error when building that says `cannot open file libogg.lib`, you'll need to compile the static `libogg` first - make sure `libogg` is compiled for the same `Debug`/`Release` and same platform that you want to compile `libvorbis` for.