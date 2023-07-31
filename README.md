# HoleHelper

This is a quick and easy setup guide to get this plugin running along with a demo and photos.

## Installation 

Install the plugin files by `git clone` or downloading the zip file.  Keep in the mind where you installed the plugin.

The first line makes sure that the plugin is found/recognized when vmd is started; replace the path with where you put the plugin.  \
The second line actually puts the plugin into the extension section of vmd in the "Analysis" section.
```
lappend auto_path /home/josh/HoleHelper/
vmd_install_extension HoleHelper holehelper_tk_cb Analysis/HoleHelper
```
For a quick sanity check, go to the TK console and input: `package require holehelper` \
which should yield a version number if correctly installed.

Lastly, this needs HOLE2 to be installed and configured for this plugin to work.  If you do not have HOLE2, go to the HOLE website and download it.  The last step is to set the HOLE path in your `.bashrc` file which may be something like this pointing to where HOLE is installed: `PATH=$PATH:~josh/hole2/exe`. If correctly pointing to the path, the hole program should spin up in your terminal by typing `hole`; you may need to restart the terminal and then try to load hole.

## Purpose/Usage
This plugin was made so users could utilize HOLE without having to go through the outdated or limited workings of the MDAnalysis version; more will be explained in the application note, but that is the main idea.

## **GUI Version**
This version is meant to only handle one "hole" in which the user can load it directly through the GUI or from a loaded molecule that is the top molecule in VMD.  Additionally, it does come with some other bells and whistles like seeing where the HOLE program will originate and an easier to follow workflow. 

**Sections:** \
**File Options:**
- Input the necessary files here which should be in the combination of either a single pdb file for single frame HOLE calculations or a psf and dcd file with an indicated step size (all three is redundant but the program can handle it). 

**Mol Sel/Wrap:**
- Input the mol selection and the wrapping condition 
- The mol selection can be anything that isolates the current hole such as: segname 6 7 8 9 10 11
- The wrapping condition should be the protein in which you want pbc to wrap around (centersel)
    - The condition will go into the wrapping statement like so: 
- `pbc wrap -all -sel "your original mol selection" -centersel "wrapping condition input" -compound fragment -center com` 

**INP File Options:**
- This is where the inputs for the INP file that the bash HOLE operation uses to make this program run faster than the other solutions currently. 

**Outputs:**
- This is where you decide where the files will be located after this program is finished running.  The folder design will be like so:
```
HH Results
    |
    |-----PDB Files
    |
    |-----INP Files
    |
    |-----SPH Files
    |
    |-----Bash Log Files
```

## **CLI Version** 
This version is the bare bones version that still only does one hole at a time but should be able to be put in a TCL script several times to calculate multiples holes at the same time. The CLI version can run multiple HOLE programs at the same time with knowledge of recent tests; the python version had issues with this so I was unsure. 

**Sections:** \
This version has the same layout as the GUI version except everything happens behind the hood but it essentially loads the molecule and does the operation on that given molecule

Here would be for a newly loaded molecule (File names must be unique or else the program will not work)
```
holehelper no system.psf dcdfolder 100 "segname 36 to 41 and not segname 4" no "0 0 1" "simple2" no no testfolder
```

Here is an example if you already have a molecule loaded and you wanted to run it on the top mol:
```
holehelper no no no no "segname 36 to 41 and not segname 4" no "0 0 1" "simple2" no no testfolder
```