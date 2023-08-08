# HoleHelper
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) 
</br>
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

<p>
  <img src="https://github.com/joshua-mae/HoleHelper/blob/cd99b3d5d8285a14747a36f05369d04052ca588b/demos/Screenshot%202023-07-31%20at%2011.53.28%20AM.png" width="325">
</p>

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

Here would be for a newly loaded molecule (File names must be unique or else the program will not work):
```
holehelper no system.psf dcdfolder 100 "segname 36 to 41 and not segname 4" no "0 0 1" "simple2" no no testfolder trimer
```

Same can be done if a user wants it done on a single frame:
```
holehelper system.pdb no no no "segname 36 to 41 and not segname 4" no "0 0 1" "simple2" no no testfolder trimer
```

Here is an example if you already have a molecule loaded and you wanted to run it on the top mol:
```
holehelper no no no no "segname 36 to 41 and not segname 4" no "0 0 1" "simple2" no no testfolder trimer
```

In theory, if one wanted to maximize efficiency, it would be possible to stack the commands in one tcl file and run that to perform this on several holes with one file already loaded in.
```
# example.tcl
holehelper no no no no "segname 0 1 2 3 4 5" "segname 0" "0 0 1" "simple2" no no testfolder trimer1
holehelper no no no no "segname 36 to 41 and not segname 4" no "0 0 1" "simple2" no no testfolder1 trimer2
holehelper no no no no "segname 6 7 8 9 10 11" "segname 6" "0 0 1" "simple2" no no testfolder2 trimer3
```
File/folder names must not have spaces and should be using hyphens or underscores to connect them so no bugs or issues occur when running the program.  

## Acknowledgements (Citations work in progress)
This program uses the HOLE2 program originally written by Oliver Smart and a file from `rad` folder in Lily Wang's MDAnalysis version for better calculations.

## License
![License](https://github.com/joshua-mae/HoleHelper/blob/25d4763fa1e24126c30b030b59925db77133e2ca/LICENSE)

