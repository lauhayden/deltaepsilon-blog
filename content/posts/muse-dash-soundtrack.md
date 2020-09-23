+++
title = "Rip the Muse Dash Soundtrack"
date = 2020-09-23T17:52:02-04:00
images = []
tags = []
categories = []
draft = false
+++

I've started to play the excellent casual rhythm game [Muse Dash](https://store.steampowered.com/app/774171/Muse_Dash/). I love the music in that game, and wanted to rip the soundtrack to put into my own music collection. Obviously I can't share the soundtrack directly, but I can share the procedure I used. Fortunately, it turns out that ripping from the game is pretty easy!

## Objective

We want the complete soundtrack from Muse Dash, encoded in a modern high-quality lossy format (I chose Opus). We also want all the cover art, artists, titles, etc tagged.

## Tools

* [*Asset Studio*](https://github.com/Perfare/AssetStudio)
    
    An open-source Unity asset bundle extractor. Unfortunately this tool only runs on Windows - if anyone knows any alternatives that run on Linux, please tell me.

* `opusenc`

    The default Opus encoder. Ubuntu packages it as part of the `opus-tools` package.

* Python 3

    My scripting weapon of choice.

## Step 1: Extract all tracks as WAV and all covers as PNG

Muse Dash, when installed on Windows 10 from Steam, stores all the tracks here:

`C:\Program Files (x86)\Steam\steamapps\common\Muse Dash\MuseDash_Data\StreamingAssets\AssetBundles\datas\audios\stage\musics`

Cover images are stored here:

`C:\Program Files (x86)\Steam\steamapps\common\Muse Dash\MuseDash_Data\StreamingAssets\AssetBundles\datas\cover`

Download and open *Asset Studio*, then open each folder and use "Extract all assets". Extracting the tracks should give you a folder of WAV files named `AudioClip`, whereas extracting the covers should give you two different folders with apparently identical contents: `Sprite` and `Texture2D`. I'm not quite sure what the difference is between the two `Sprite` and `Texture2D` folders are, but I used the images in `Texture2D` and it worked just fine.

## Step 2: Download my CSV with info about all tracks

In order to tag all the metadata, we need additional information. I've created a CSV file that you can [download here](/files/muse_dash_songs.csv) (last updated Sept 2020). All of that information was sourced from the [Muse Dash Official Wiki](https://musedash.gamepedia.com/Songs). Unfortunately if I haven't updated this CSV in a while, it might not have some of the new music packs. It's fairly easy to edit and add them, though.

## Step 3: Download and run the script

I've put my [script here](https://gist.github.com/lauhayden/f1e011e1efe9fb4ae1df2e211d856ce9). Once you've downloaded it, you can edit the constants at the top of the file to point to the directories where you've stashed the extracted WAVs and PNGs. Then, run the script with `python3 encode_music.py`.

...and you're done! The script should populate the output directory with a bunch of Opus-encoded files, one for each music track in Muse Dash.

## Notes about the Script

* Why 128 kbit/s for the bitrate?

    The default for Opus bitrate is 96 kbit/s, and it should be imperceptibly close to the original source. I chose 128 kbit/s just to go beyond a bit. Storage is cheap nowadays anyway.

* Isn't this re-coding an already lossily compressed audio stream?

    Yes. Muse Dash seems to store files in a Vorbis-encoded stream inside the Unity asset file, as indicated by *AssetStudio*. However, I could not find a tool that would extract the raw Vorbis bitstream from the asset file, so we're extracting to uncompressed WAV here and re-compressing with Opus. Definitely less than ideal, but good enough for my purposes.