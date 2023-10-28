<img  src="https://media.discordapp.net/attachments/868128630683893851/1166760941589897216/iw8cine.png">

#  *IW8cine*
### ⚙️ A prototype cinematic mod for Call of Duty®: Modern Warfare (2019)

<img src="https://img.shields.io/badge/IN%20DEVELOPMENT-1995ff?style=flat-square">　<a href="https://github.com/sortileges/iw8cine/releases"><img src="https://img.shields.io/badge/Latest%20release-PRERELEASE-1995ff?style=flat-square"></a>　<a href="https://discord.gg/wgRJDJJ"><img src="https://img.shields.io/discord/617736623412740146?label=Join%20us%20on%20Discord&style=flat-square&color=1995ff"></a>
<br/><br/>

Designed for video editors to create cinematics shots on **Call of Duty®: Modern Warfare (2019)**.

This mod creates new dvars, which executes a script when modified. As it stands now, IW8 only responds to player commands that already exist *(+attack, +smoke, etc)*. The mod creates new dvars, then checks after every sv_ frame if their values have been modified, and runs the rest of the script if changed.

This mod was also designed as a Multiplayer mod only. It will not work in Singleplayer or Spec Ops as is.

<br/><br/>
## Requirements
In order to use this, you will need a build of Call of Duty®: Modern Warfare that supports GSC injection. **For obvious legal concerns, no such build will be given or linked.** You are on your own!

<br/><br/>
## Compiling & Installation
Since the mod is still in development, you will need to compile the script yourself if you want all the latest features. A pre-compiled script from the very first commit is available [here](https://github.com/sortileges/iw8cine/releases/latest). 

You can compile the script by using [Xensik's GSC tool](https://github.com/xensik/gsc-tool). The usage of this CLI tool is very-well explained in its README if you need further instructions or information.

As a very brief rundown, you can compile the script by using the following command in your terminal, provided you have GSC tool downloaded and the script.gsc file in the same directory:

```bash
gsc-tool.exe comp iw8 pc script.gsc
```
<br/>

Once the script is compiled, you will get a **./compiled/iw8/script.gscbin** file. This is the file you will need to use in order to use the mod.

The way you're going to use that file will entirely depend on how your game client injects compiled GSC files. Though in most current cases, you might want to put it in your MW19 root directory, where **ModernWarfare.exe** is.
```text
X:/
└── .../
	└── MW19/
		└── ModernWarfare.exe
		└── script.gscbin
```
There is no way to know if the mod is loaded until you start a match. A welcome message and a fictitious achievement pop-up should appear once you spawn!

<br/><br/>
## How to use
**A web page or a wiki will be done once the mod is ready for its first release.** For now, you can find a list of all the commands directly in the **script.gsc** file, and all of the commands except /clone start with "mvm". There's a link to a Discord sever below that you can join for help in the meantime.

<br/><br/>
## Join us on Discord

We have a Discord server related to the mod, where you can get help and resources, share your work, or just hang out. **[Everyone's welcome!](https://discord.gg/wgRJDJJ)**
