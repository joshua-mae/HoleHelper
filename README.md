# HoleHelper

This is a quick and easy setup guide to get this plugin running along with a demo and photos.

## Installation 

Install the plugin files by `git clone` or downloading the zip file.  Keep in the mind where you installed the plugin.

The first line makes sure that the plugin is found/recognized when vmd is started; replace the path with where you put the plugin.  \
The second line actually puts the plugin into the extension section of vmd in the "Analysis" section.
```
lappend auto_path /home/josh/improved-hole-plugin/
vmd_install_extension HoleHelper holehelper_tk_cb Analysis/holehelper
```
For a quick sanity check, go to the TK console and input: `package require holehelper` \
which should yield a version number if correctly installed.

Lastly, this needs HOLE2 to be installed and configured for this plugin to work.  If you do not have HOLE2, go to the HOLE website and download it.  The last step is to set the HOLE path in your `.bashrc` file which may be something like this pointing to where HOLE is installed: `PATH=$PATH:~josh/hole2/exe`. If correctly pointing to the path, the hole program should spin up in your terminal by typing `hole`; you may need to restart the terminal and then try to load hole.

## Purpose/Usage
This plugin was made so users could utilize HOLE without having to go through the outdated or limited workings of the MDAnalysis version; more will be explained in the application note, but that is the main idea.

GUI Version - This version is meant to only handle one "hole" in which the user can load it directly through the GUI or from a loaded molecule that is the top molecule in VMD.  Additionally, it does come with some other bells and whistles like seeing where the HOLE program will originate and an easier to follow workflow. 

CLI Version - This version is the bare bones version that still only does one hole at a time but should be able to be put in a TCL script several times to calculate multiples holes at the same time. This version is WIP regarding the multiple holes aspect, at worst, you will only be able to calculate one hole at a time (very little users will find this limiting, the multiple holes is for the superusers). 
