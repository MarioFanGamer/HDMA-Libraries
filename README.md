# HDMA-Libraries
A repository which contains my HDMA libraries. These all are primarily to be used for [UberASM Tool](https://github.com/VitorVilela7/UberASMTool) for SMW, though with some modifications,
they're usable for other SNES games as well as homebrew projects.

Keep in mind that this readme is kept very general and only contains a short description as well as which file is what.
You can find more details for each resource in the corresponding readmes.

## General insertion

In order to insert any of these libraries in UberASM, you have to perform the following steps (assuming default values):
1. Insert the content of `BaseMacros.asm` to `other/macro_library.asm`.
2. Insert the contents of the macro for the HDMA effects you want to insert to `other/macro_library.asm`.
3. Copy the library to `library`
4. Insert the level codes to `level`, though you may want to edit the default values.


## Scrollable HDMA Gradients
This is a library which handles scrollable HDMA gradients. HDMA gradients are one of the most famous applications of HDMA to the point that HDMA is practically synonymous with it in some circles.
It is, however, static to the screen by default so having them scrollable relative to the screen requires some workaround. Naturally, this library is one of these workarounds.

Contents of this library:
- `ScrollHDMA.asm`: The library of Scrollable HDMA Gradietns.
- `ScrollMacros.asm`: The macros for Scrollable HDMA Gradients.
- `Scrollable HDMA Gradient - Readme.txt`: The readme of Scrollable HDMA Gradients.
- `Scrollable HDMA Gradient - Technical Readme.txt`: The readme of `ScrollMacros.asm`.
- `Base.asm`: Contains the minimal code, doesn't include a proper gradient.
- `examples`: The folder with working examples.


## Parallax HDMA Toolkit
That library is an easy way and generic way to handle parallax HDMA. Parallax HDMA is one of the many methods of performing parallax scrolling i.e. giving the graphics depth by scrolling parts of the background at different rates.
Methods can be multiple layers (a given feature for the SNES), sprites (particularly if all the layers are used), repeated tiles (i.e. there is a texture whose graphics change depending on the position) and rasters/scanlines (which is what HDMA does).
This library in particular is used to have the scrolling not being static to the screen. It's also able

Contents of this library:
- `ParallaxToolkit.asm`: The library of Parallax HDMA Toolkit.
- `Parallax HDMA Toolkit - Readme.txt`: The readme of Parallax HDMA Toolkit.
- `Base.asm`: Contains the minimal code, doesn't include a proper parallax table.
- `examples`: The folder with working examples.


## Waves HDMA Toolkit
This library, on the other hand, is to handle waves on the screen. Unlike the other two codes, most of the code should be handled with macros.

Contents of this library:
- `WavesToolkit.asm`: The library of Wave HDMA Toolkit.
- `WavesMacros.asm`: The macros for Waves HDMA Toolkit.
- `HDMA Waves Toolkit - Readme.txt`: The readme of Waves HDMA Toolkit.
- `HDMA Waves Toolkit - Technical Readme.txt`: The readme of `WavesMacros.asm`.
- `Base.asm`: Contains the minimal code, doesn't include the waves code.
- `examples`: The folder with working examples.


## Release Script

In order to make packaging the libraries easier, I provide a library.

The script runs on Shell script (though tested in Bash only) and uses ZIP compression. As a result, you should have `zip` installed which most package mangers provide.
If you use Windows, I recommend you to install MSYS2 which comes with a port of Unix tools including `bash` (to run this script) and `zip` (to create the release archive).
