package provide holehelper 1.0

namespace eval ::HOLEHelper:: {
    global env
    variable w
    set hh_path "$env(HOLEHELPERDIR)"
    set user [exec whoami] 
    variable primarypdb
    variable primarypsf
    variable primarydcd
    variable dcd_step
	variable mol_sel
	variable wrapping_condition
	variable primarycvec_x
	variable primarycvec_y
	variable primarycvec_z
	variable radius
	variable endrad
	variable primarycpnt_x
	variable primarycpnt_y
	variable primarycpnt_z
    variable output_dir
} 

proc holehelper_usage {} {
    vmdcon -info "Usage: holehelper <pdbfile> <psffile> <dcdfolder> <dcdstep> <molsel> <wrap> \
    <cvec> <radtype> <cp> <endrad> <outputdir>"
    error "Needs correct inputs -> Look at the example or the README.md for guidance"
}

proc holehelper {args} {
    # Print usage information if no arguments are given
    global errorInfo errorCode
    set oldcontext [psfcontext new]  ;# new context
    set errflag [catch { eval holehelper_core $args } errMsg]
    set savedInfo $errorInfo
    set savedCode $errorCode
    psfcontext $oldcontext delete  ;# revert to old context
    if $errflag { error $errMsg $savedInfo $savedCode }
}

proc holehelper_core {args} {
    global env
    set user_holepath "$env(HOLEHELPERDIR)"
    set user [exec whoami]
    if { ![llength $args ]} {
        holehelper_usage
    }

    set pdbfile [lindex $args 0]
    set psffile [lindex $args 1]
    set dcd_folder [lindex $args 2]
    set step_size [lindex $args 3]
    set molesel [lindex $args 4]
    set wrap [lindex $args 5]
    set cvec [lindex $args 6]
    set radtype [lindex $args 7]
    set cpoint [lindex $args 8]
    set edrad [lindex $args 9]
    set outputdir [lindex $args 10]

    # Need to make sure file names are unique

    set pdbbashpath [exec find /home/$user -type f -name "${pdbfile}" ! -path "*/\.*"]
    set psfbashpath [exec find /home/$user -type f -name "${psffile}" ! -path "*/\.*"]
    set dcdbashpath [exec find /home/$user  -type d -name "${dcd_folder}" ! -path "/home/*/*.*"]
    
    if {($pdbfile != "no") && ($psffile == "no") && ($dcd_folder == "no")} {
        if {[file extension $pdbbashpath] != ".pdb"} {
            error "Needs proper pdb file"
        } 
    } elseif {($pdbfile != "no") && ($psffile != "no") && ($dcd_folder != "no")} {
        if {[file extension $pdbbashpath] != ".pdb"} {
            error "Needs proper pdb file"
        } 
        if {[file extension $psfbashpath] != ".psf"} {
            error "Needs proper psf file"
        } 
        if {[file isdirectory $dcd_folder] != 1} {
            error "Needs proper dcd directory"
        } 
    } elseif {($pdbfile != "no") && ($psffile != "no") && ($dcd_folder == "no")} {

        if {[file extension $pdbbashpath] != ".pdb"} {
            error "Needs proper pdb file"
        } 
        if {[file extension $psfbashpath] != ".psf"} {
            error "Needs proper psf file"
        } 
    } elseif {($pdbfile == "no") && ($psffile != "no") && ($dcd_folder != "no")} {

        if {[file extension $psfbashpath] != ".psf"} {
            error "Needs proper psf file"
        } 
        if {[file isdirectory $dcd_folder] != 1} {
            error "Needs proper dcd directory"
        } 
    } elseif {($pdbfile == "no") && ($psffile == "no") && ($dcd_folder == "no") && ($step_size == "no")} {
        puts "This is still a valid combination!"
    } else {
        error "Needs valid combination of file inputs"
    }
    if {$dcd_folder != "no"} {
        if {[string is double -strict $step_size] != 1} {
        error "Needs proper dcd step input"
        } 
    }
    # Not gonna check for the molecule selections, wrap, or center vec/point.
    # VMD errors will give enough info, I cant do those checks without ruining the 
    # workflow drastically

    set outputdirbashpath [exec find /home/$user  -type d -name "${outputdir}" ! -path "/home/*/*.*"]

    if {$wrap != "no"} {
        pbc wrap -sel "${molesel}" -all -centersel "${wrap}" \
        -compound fragment -center com
    }   

    if {$edrad != "no"} {    
        if {[string is double -strict $edrad] != 1} {
        error "Needs proper end radius"
        } 
    } 
    if {[file isdirectory $outputdirbashpath] != 1} {
        error "Needs proper output directory"
    } 

    if {($pdbfile != "no") && ($psffile == "no") && ($dcd_folder == "no")} {
        mol new $pdbbashpath type pdb waitfor all
    } elseif {($pdbfile != "no") && ($psffile != "no") && ($dcd_folder == "no")} {
        mol new $pdbbashpath type pdb waitfor all
        mol addfile $psfbashpath type psf waitfor all
    } elseif {($pdbfile != "no") && ($psffile != "no") && ($dcd_folder != "no")} {
        mol new $pdbbashpath type pdb waitfor all
        mol addfile $psfbashpath type psf waitfor all
        cd $dcdbashpath
        foreach dcdfiles [lsort [glob *dcd]] {
            puts $dcdfiles
            mol addfile $dcdfiles type dcd step $step_size waitfor -1 
        }
    } elseif {($pdbfile == "no") && ($psffile != "no") && ($dcd_folder != "no")} {
        mol new $psfbashpath type psf waitfor all
        cd $dcdbashpath
        foreach dcdfiles [lsort [glob *dcd]] {
            puts $dcdfiles
            mol addfile $dcdfiles type dcd step $step_size waitfor -1 
        }
    }
    set top_mol [molinfo top]
    cd $outputdirbashpath
    file mkdir HH-Results
    cd $outputdirbashpath/HH-Results
    file mkdir pdb-folder
    file mkdir inp-folder
    file mkdir sph-folder
    file mkdir logs-folder

    set frame_nums [molinfo top get numframes]

    for { set f 0 } { $f < $frame_nums } { incr f} {

        # Sets a sel variable for later use in the animate

        set sel [atomselect top $molesel]

        # Writing out the pdbs 

        cd $outputdirbashpath/HH-Results/pdb-folder
        animate write pdb "HoleHelper-PDB-${f}.pdb" beg $f end $f waitfor -1 sel $sel

        # Writing the inp files for the bash script to read

        cd ../inp-folder
        set outfile [open "HoleHelper-INP-${f}.inp" w+]
        puts $outfile "coord ${outputdirbashpath}/HH-Results/pdb-folder/HoleHelper-PDB-${f}.pdb"
        puts $outfile "radius ${user_holepath}/rad/${radtype}.rad"
        puts $outfile "sphpdb ${outputdirbashpath}/HH-Results/sph-folder/HoleHelper-SPH-${f}.sph"
        puts $outfile "cvect ${cvec}"
        if {$cpoint != "no"} {
            puts $outfile "cpoint ${cpoint}"
        }
        if {$edrad != "no"} {
            puts $outfile "endrad ${edrad}"
        }
        close $outfile
    }

    cd $user_holepath
    exec sh holebash.sh "${outputdirbashpath}"
    exec python3 sphcleaner.py ${outputdirbashpath}
    cd $outputdirbashpath/HH-Results/sph-folder
    set sphfilelist [lsort [glob *.sph]]

    foreach sph $sphfilelist {
        mol new $sph type pdb
        set real_atom_count [molinfo top get numatoms]
        set moleculeid [molinfo top]
        set fake_atom_count 1000
        set atom_count_diff [expr $fake_atom_count - $real_atom_count]
        set outfile [open $sph a]
        for { set f 0 } {$f < $atom_count_diff } { incr f} {
            puts $outfile "ATOM      1  QSS SPH S-888"
        }
        close $outfile
        mol delete $moleculeid
    }

    set sphfilelist [lsort [glob *.sph]]
    mol new [lindex $sphfilelist 0] type pdb
    set top_num [molinfo top]
    mol modstyle 0 $top_num VDW
    set sel [atomselect top "all"]
    $sel set radius [$sel get beta]
    for {set f 1} {$f < $frame_nums} {incr f} {
        mol addfile [lindex $sphfilelist $f] type pdb
    }
    cd /home/$user
    mol top $top_mol


}


proc ::HOLEHelper::holehelper {} {
    variable w
    variable hh_path
    variable user
    variable primarypdb 
    variable primarypsf 
    variable primarydcd 
    variable dcd_step 
	variable mol_sel 
	variable wrapping_condition 
	variable primarycvec_x 0
	variable primarycvec_y 0
	variable primarycvec_z 1
	variable radius "simple2"
	variable endrad
	variable primarycpnt_x
	variable primarycpnt_y
	variable primarycpnt_z
    variable output_dir "/home/$user"

    if { [winfo exists .holehelper] } {
        wm deiconify $w
	return
    }

    set w [toplevel ".holehelper"]
    wm title $w "Hole Helper"
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 0 -weight 1

    wm geometry $w 510x600

    set file_window $w.fileoptions
    ttk::labelframe $file_window -borderwidth 2 -relief ridge -text "File Options"

    frame $file_window.pdb
    grid [label $file_window.pdb.pdblabel -text "PDB File: "] \
    -row 0 -column 0 -sticky e
    grid [entry $file_window.pdb.pdbpath -textvariable \
    ::HOLEHelper::primarypdb -width 70 -justify left] -row 0 -column 1
    grid [button $file_window.pdb.pdbbutton -text "Browse" \
    -command {
        set tempfile [tk_getOpenFile]
	if {![string equal $tempfile ""]} {set ::HOLEHelper::primarypdb $tempfile}
	}] -row 0 -column 2 -sticky w
	grid columnconfigure $file_window.pdb 1 -weight 1

    frame $file_window.psf
    grid [label $file_window.psf.psflabel -text "PSF File: "] \
    -row 0 -column 0 -sticky e
    grid [entry $file_window.psf.psfpath -textvariable \
    ::HOLEHelper::primarypsf -width 70 -justify left] -row 0 -column 1
    grid [button $file_window.psf.psfbutton -text "Browse" \
    -command {
        set tempfile [tk_getOpenFile]
	if {![string equal $tempfile ""]} {set ::HOLEHelper::primarypsf $tempfile}
	}] -row 0 -column 2 -sticky w
	grid columnconfigure $file_window.psf 1 -weight 1

    frame $file_window.dcd
    grid [label $file_window.dcd.dcdlabel -text "DCD File: "] \
    -row 0 -column 0 -sticky e
    grid [entry $file_window.dcd.dcdpath -textvariable \
    ::HOLEHelper::primarydcd -width 70 -justify left] -row 0 -column 1
    grid [button $file_window.dcd.dcdbutton -text "Browse" \
    -command {
        set tempfile [tk_chooseDirectory]
	if {![string equal $tempfile ""]} {set ::HOLEHelper::primarydcd $tempfile}
	}] -row 0 -column 2 -sticky w
	grid columnconfigure $file_window.dcd 1 -weight 1

    frame $file_window.dcdstep
    grid [label $file_window.dcdstep.dcdsteplabel -text "DCD Step Size: "] \
    -row 0 -column 0 -sticky e
    grid [entry $file_window.dcdstep.dcdstepdpath -textvariable \
    ::HOLEHelper::dcd_step -width 10 -justify left] -row 0 -column 1
 

    pack $file_window -side top -pady 5 -padx 3 -fill x -anchor w
    pack $file_window.pdb $file_window.psf $file_window.dcd $file_window.dcdstep \
    -side top -padx 0 -pady 2 -expand 1 -fill x
	
    pack [button $w.loadmol -text "Load Mol" -command ::HOLEHelper::file_loader] \
    -side top -pady 5 -padx 3 -fill x -anchor w
    pack [button $w.delmol -text "Delete Top Mol" -command "mol delete top"] \
    -side top -pady 5 -padx 3 -fill x -anchor w
    
    #------------------------------------------------------------------------

    set mol_window $w.moloptions
    ttk::labelframe $mol_window -borderwidth 2 -relief ridge -text "Mol Sel/Wrap"
	
    frame $mol_window.molsel
    grid [label $mol_window.molsel.mollabel -text "Molecule Selection: "] \
    -row 0 -column 0 -sticky e
    grid [entry $mol_window.molsel.molpath -textvariable \
    ::HOLEHelper::mol_sel -width 70 -justify left] -row 0 -column 1
	grid columnconfigure $mol_window.molsel 1 -weight 1
	
    frame $mol_window.wrapping
    grid [label $mol_window.wrapping.wraplabel -text "PBC Wraping Condition (Centersel): "] \
    -row 1 -column 0 -sticky e
    grid [entry $mol_window.wrapping.wrappath -textvariable \
    ::HOLEHelper::wrapping_condition -width 70 -justify left] -row 1 -column 1
	grid columnconfigure $mol_window.wrapping 1 -weight 1
	
	pack $mol_window -side top -pady 5 -padx 3 -fill x -anchor w
	pack $mol_window.molsel $mol_window.wrapping -side top -padx 0 -pady 2 -expand 1 -fill x

	#------------------------------------------------------------------------
    set inp_window $w.inpoptions
    ttk::labelframe $inp_window -borderwidth 2 -relief ridge -text "INP File Options"
	ttk::style configure TLabelframe.Label -font bold
	
	frame $inp_window.cvect
	pack [label $inp_window.cvect.cvlabel -text "Center Vector (x,y,z): " ] -side left
	pack [entry $inp_window.cvect.x -width 16 -textvariable HOLEHelper::primarycvec_x] -side left
	pack [entry $inp_window.cvect.y -width 16 -textvariable HOLEHelper::primarycvec_y] -side left
	pack [entry $inp_window.cvect.z -width 16 -textvariable HOLEHelper::primarycvec_z] -side left
	
	frame $inp_window.rad
	grid [label $inp_window.rad.radlabel -text "RAD File Type:"] \
		-row 1 -column 0 -sticky w
	grid [radiobutton $inp_window.rad.simple2 -variable ::HOLEHelper::radius \
		-tristatevalue "simple2" -value "simple2" -text "Simple2"] -row 1 -column 1 -sticky w
	grid [radiobutton $inp_window.rad.simple -variable ::HOLEHelper::radius \
		-tristatevalue "simple" -value "simple" -text "Simple"] -row 1 -column 2 -sticky w
	grid [radiobutton $inp_window.rad.amber -variable ::HOLEHelper::radius \
		-tristatevalue "amberuni" -value "amberuni" -text "Amber"] -row 1 -column 3 -sticky w
	grid [radiobutton $inp_window.rad.bondi -variable ::HOLEHelper::radius \
		-tristatevalue "bondi" -value "bondi" -text "Bondi"] -row 1 -column 4 -sticky w
	grid [radiobutton $inp_window.rad.hardcore -variable ::HOLEHelper::radius \
		-tristatevalue "hardcore" -value "hardcore" -text "Hardcore"] -row 1 -column 5 -sticky w
	grid [radiobutton $inp_window.rad.xplor -variable ::HOLEHelper::radius \
		-tristatevalue "xplor" -value "xplor" -text "Xplor"] -row 1 -column 6 -sticky w
	
	frame $inp_window.optional
	pack [label $inp_window.optional.optlabel -font bold -text "Optional INP Inputs: " ] -side left
	
	frame $inp_window.cpnt
	pack [label $inp_window.cpnt.cpntlabel -text "Center Point (x,y,z):  " ] -side left
	pack [entry $inp_window.cpnt.x -width 12 -textvariable HOLEHelper::primarycpnt_x] -side left
	pack [entry $inp_window.cpnt.y -width 12 -textvariable HOLEHelper::primarycpnt_y] -side left
	pack [entry $inp_window.cpnt.z -width 12 -textvariable HOLEHelper::primarycpnt_z] -side left
    pack [button $inp_window.cpnt.cpntbutton -text "Simulate" \
    -command ::HOLEHelper::draw_sphere] \
	
    frame $inp_window.edrad
    grid [label $inp_window.edrad.endlabel -text "Endrad: "] \
    -row 1 -column 0 -sticky e
    grid [entry $inp_window.edrad.endpath -textvariable \
    ::HOLEHelper::endrad -width 70 -justify left] -row 1 -column 1
	grid columnconfigure $inp_window.edrad 1 -weight 1
	
	pack $inp_window -side top -pady 5 -padx 3 -fill x -anchor w
	pack $inp_window.cvect $inp_window.rad $inp_window.optional $inp_window.cpnt $inp_window.edrad \
		-side top -padx 0 -pady 2 -expand 1 -fill x
	
    #-------------------------------------------------------------------------
    set output_window $w.outputdir
    ttk::labelframe $output_window -borderwidth 2 -relief ridge -text "Output"
	ttk::style configure TLabelframe.Label -font bold

    frame $output_window.files
    grid [label $output_window.files.filelabel -text "Output Directory: "] \
    -row 0 -column 0 -sticky e
    grid [entry $output_window.files.filepath -textvariable \
    ::HOLEHelper::output_dir -width 70 -justify left] -row 0 -column 1
    grid [button $output_window.files.filebutton -text "Browse" \
    -command {
        set tempfile [tk_chooseDirectory]
	if {![string equal $tempfile ""]} {set ::HOLEHelper::output_dir $tempfile}
	}] -row 0 -column 2 -sticky w
	grid columnconfigure $output_window.files 1 -weight 1

	pack $output_window -side top -pady 5 -padx 3 -fill x -anchor w
	pack $output_window.files -side top -padx 0 -pady 2 -expand 1 -fill x

	#-------------------------------------------------------------------------

    pack [button $w.single -text "Run HOLE2 on Single Frame" -command ::HOLEHelper::run_hole2_single] \
    -side top -pady 5 -padx 3 -fill x -anchor w

    pack [button $w.traj -text "Run HOLE2 on Trajectory" -command ::HOLEHelper::run_hole2_traj] \
    -side top -pady 5 -padx 3 -fill x -anchor w

	#-------------------------------------------------------------------------
}
proc ::HOLEHelper::run_hole2_single {} {
    variable user
    variable primarypdb
    variable hh_path
	variable mol_sel
	variable wrapping_condition
	variable primarycvec_x
	variable primarycvec_y
	variable primarycvec_z
	variable radius 
	variable endrad
	variable primarycpnt_x
	variable primarycpnt_y
	variable primarycpnt_z
    variable output_dir
    
    # Utilizes PBC wrap to wrap a molecule if necessary

    error_checker $mol_sel $wrapping_condition $primarycvec_x \
    $primarycvec_y $primarycvec_z $primarycpnt_x $primarycpnt_y $primarycpnt_z \
    $endrad $output_dir

        
    set top_mol [molinfo top]

    cd $output_dir
    file mkdir HH-Results
    cd $output_dir/HH-Results
    file mkdir pdb-folder
    file mkdir inp-folder
    file mkdir sph-folder
    file mkdir logs-folder

    if {$wrapping_condition != ""} {
        pbc wrap -all -sel "${mol_sel}" -centersel "${wrapping_condition}" \
        -compound fragment -center com
    }
    set sel [atomselect top $mol_sel]
    cd $output_dir/HH-Results/pdb-folder
    animate write pdb "HoleHelper-PDB-0.pdb" beg 0 end 0 waitfor -1 sel $sel

    # Bash script needs an inp file in order to run 

    cd $output_dir/HH-Results/inp-folder
    set outfile [open "HoleHelper-INP-0.inp" w+]
    puts $outfile "coord ${output_dir}/HH-Results/pdb-folder/HoleHelper-PDB-0.pdb"
    puts $outfile "radius ${hh_path}/rad/${radius}.rad"
    puts $outfile "sphpdb ${output_dir}/HH-Results/sph-folder/HoleHelper-SPH-0.sph"
    puts $outfile "ignore hoh tip wat"
    puts $outfile "cvect ${primarycvec_x} ${primarycvec_y} ${primarycvec_z}"
    if {($primarycpnt_x != "") && ($primarycpnt_x != "") && ($primarycpnt_x != "")} {
        puts $outfile "cpoint ${primarycpnt_x} ${primarycpnt_y} ${primarycpnt_z}"
    } 
    if {$endrad != ""} {
        puts $outfile "endrad ${endrad}"
    } 
    close $outfile

    cd $hh_path
    exec sh holebash.sh


    cd $output_dir/HH-Results/sph-folder
    set sphfilelist [lsort [glob *.sph]]
    mol new [lindex $sphfilelist 0] type pdb
    set top_num [molinfo top]
    mol modstyle 0 $top_num VDW
    set sel [atomselect top "all"]
    $sel set radius [$sel get beta]

    cd /home/$user
    mol top $top_mol

}

# pbc wrap -all -sel "segname 12 13 14 15 16 17" -centersel "segname 12" -compound fragment -center com
# pbc wrap -all -sel "segname 0 1 2 3 4 5" -centersel "segname 0" -compound fragment -center com
#pbc wrap -all -sel "segname 6 7 8 9 10 11" -centersel "segname 11" -compound fragment -center com

proc ::HOLEHelper::run_hole2_traj {} {
    variable user
    variable hh_path
	variable mol_sel
	variable wrapping_condition
	variable primarycvec_x
	variable primarycvec_y
	variable primarycvec_z
	variable radius 
	variable endrad
	variable primarycpnt_x
	variable primarycpnt_y
	variable primarycpnt_z
    variable output_dir

	error_checker $mol_sel $wrapping_condition $primarycvec_x \
    $primarycvec_y $primarycvec_z $primarycpnt_x $primarycpnt_y $primarycpnt_z \
    $endrad $output_dir
    
    set top_mol [molinfo top]

    cd $output_dir
    file mkdir HH-Results
    cd $output_dir/HH-Results
    file mkdir pdb-folder
    file mkdir inp-folder
    file mkdir sph-folder
    file mkdir logs-folder
    set frame_nums [molinfo top get numframes]

    # Utilizes PBC wrap to wrap a molecule if necessary

    if {$wrapping_condition != ""} {
        pbc wrap -all -sel "${mol_sel}" -centersel "${wrapping_condition}" \
        -compound fragment -center com
    }

    for { set f 0 } { $f < $frame_nums } { incr f} {

        # Sets a sel variable for later use in the animate

        set sel [atomselect top $mol_sel]

        # Writing out the pdbs 

        cd $output_dir/HH-Results/pdb-folder
        animate write pdb "HoleHelper-PDB-${f}.pdb" beg $f end $f waitfor -1 sel $sel

        # Writing the inp files for the bash script to read

        cd ../inp-folder
        set outfile [open "HoleHelper-INP-${f}.inp" w+]
        puts $outfile "coord ${output_dir}/HH-Results/pdb-folder/HoleHelper-PDB-${f}.pdb"
        puts $outfile "radius ${hh_path}/rad/${radius}.rad"
        puts $outfile "sphpdb ${output_dir}/HH-Results/sph-folder/HoleHelper-SPH-${f}.sph"
        puts $outfile "cvect ${primarycvec_x} ${primarycvec_y} ${primarycvec_z}"
        if {($primarycpnt_x != "") && ($primarycpnt_x != "") && ($primarycpnt_x != "")} {
            puts $outfile "cpoint ${primarycpnt_x} ${primarycpnt_y} ${primarycpnt_z}"
        }
        if {$endrad != ""} {
            puts $outfile "endrad ${endrad}"
        }
        close $outfile
    }


    cd $hh_path
    exec sh holebash.sh "${output_dir}"
    exec python3 sphcleaner.py ${output_dir}

    cd $output_dir/HH-Results/sph-folder
    set sphfilelist [lsort [glob *.sph]]

    foreach sph $sphfilelist {
        mol new $sph type pdb
        set real_atom_count [molinfo top get numatoms]
        set moleculeid [molinfo top]
        set fake_atom_count 1000
        set atom_count_diff [expr $fake_atom_count - $real_atom_count]
        set outfile [open $sph a]
        for { set f 0 } {$f < $atom_count_diff } { incr f} {
            puts $outfile "ATOM      1  QSS SPH S-888"
        }
        close $outfile
        mol delete $moleculeid
    }

    cd $output_dir/HH-Results/sph-folder
    set sphfilelist [lsort [glob *.sph]]
    mol new [lindex $sphfilelist 0] type pdb
    set top_num [molinfo top]
    mol modstyle 0 $top_num VDW
    set sel [atomselect top "all"]
    $sel set radius [$sel get beta]
    for {set f 1} {$f < $frame_nums} {incr f} {
        mol addfile [lindex $sphfilelist $f] type pdb
    }
    cd /home/$user
    mol top $top_mol

}

proc ::HOLEHelper::error_checker {molsel pbccond cvx cvy cvz cpx cpy cpz ed outdir} {

    # Checks the validity of the mol sel and wrapping condition 

    set mol [atomselect top "$molsel"]
    if {[$mol num] == 0} {
        error "Needs real selection"
    } 
    if {$pbccond != ""} {
        set pbcmol [atomselect top $pbccond]
        if {[$pbcmol get mass] < 0} {
            error "The center of the pbc wrap needs to have a + center of mass"
        }
    }

    # Checks the direction vector for the inp file

    if {[string is double -strict $cvx] != 1} {
        error "Needs proper x vector"
    } 
    if {[string is double -strict $cvy] != 1} {
        error "Needs proper y vector"
    } 
    if {[string is double -strict $cvz] != 1} {
        error "Needs proper z vector"
    } 

    # Checks the center point vector for the inp file

    if {($cpx != "") || ($cpy != "") || ($cpz != "")} {
        if {[string is double -strict $cpx] != 1} {
            error "Needs proper x center"
        } 
        if {[string is double -strict $cpy] != 1} {
            error "Needs proper y center"
        } 
        if {[string is double -strict $cpz] != 1} {
            error "Needs proper x center"
        } 
    }

    # Checks type of end radius input

    if {$ed != ""}    {    
        if {[string is double -strict $ed] != 1} {
        error "Needs proper end radius"
        } 
    }

    # Checks if valid directory

    if {[file isdirectory $outdir] != 1} {
        error "Needs proper output directory"
    } 
    puts "This goes through with no errors"
}

proc ::HOLEHelper::file_loader {} {
    variable primarypdb
    variable primarypsf
    variable primarydcd
    variable dcd_step

    # Initial error checker before the files are loaded

    if {($primarypdb != "") && ($primarypsf == "") && ($primarydcd == "")} {
        if {[file extension $primarypdb] != ".pdb"} {
            error "Needs proper pdb file"
        } 
    } elseif {($primarypdb != "") && ($primarypsf != "") && ($primarydcd != "")} {
        if {[file extension $primarypdb] != ".pdb"} {
            error "Needs proper pdb file"
        } 
        if {[file extension $primarypsf] != ".psf"} {
            error "Needs proper psf file"
        } 
        if {[file isdirectory $primarydcd] != 1} {
            error "Needs proper dcd directory"
        } 
    } elseif {($primarypdb != "") && ($primarypsf != "") && ($primarydcd == "")} {

        if {[file extension $primarypdb] != ".pdb"} {
            error "Needs proper pdb file"
        } 
        if {[file extension $primarypsf] != ".psf"} {
            error "Needs proper psf file"
        } 
    } elseif {($primarypdb == "") && ($primarypsf != "") && ($primarydcd != "")} {

        if {[file extension $primarypsf] != ".psf"} {
            error "Needs proper psf file"
        } 
        if {[file isdirectory $primarydcd] != 1} {
            error "Needs proper dcd directory"
        } 
    } else {
        error "Needs valid combination of file inputs"
    }
    if {$primarydcd != ""} {
        if {[string is double -strict $dcd_step] != 1} {
        error "Needs proper dcd step input"
        } 
    }

    # Loads files when all inputs are free of errors
    # Needs to happen before the other checker because a valid mol sel needs
    # to be present

    if {($primarypdb != "") && ($primarypsf == "") && ($primarydcd == "")} {
        mol new $primarypdb type pdb waitfor all
    } elseif {($primarypdb != "") && ($primarypsf != "") && ($primarydcd == "")} {
        mol new $primarypdb type pdb waitfor all
        mol addfile $primarypsf type psf waitfor all
    } elseif {($primarypdb != "") && ($primarypsf != "") && ($primarydcd != "")} {
        mol new $primarypdb type pdb waitfor all
        mol addfile $primarypsf type psf waitfor all
        cd $primarydcd
        foreach dcdfiles [lsort [glob *dcd]] {
            puts $dcdfiles
            mol addfile $dcdfiles type dcd step $dcd_step waitfor -1 
        }
    } elseif {($primarypdb == "") && ($primarypsf != "") && ($primarydcd != "")} {
        mol new $primarypsf type psf waitfor all
        cd $primarydcd
        foreach dcdfiles [lsort [glob *dcd]] {
            puts $dcdfiles
            mol addfile $dcdfiles type dcd step $dcd_step waitfor -1 
        }
    } 
}

proc ::HOLEHelper::draw_sphere {} {
    variable mol_sel
    variable primarycpnt_x
    variable primarycpnt_y
    variable primarycpnt_z

    set mol [atomselect top "$mol_sel"]
    if {[$mol num] == 0} {
        error "Needs real selection"
    } 
    if {($primarycpnt_x != "") || ($primarycpnt_y != "") || ($primarycpnt_z != "")} {
        if {[string is double -strict $primarycpnt_x] != 1} {
            error "Needs proper x center"
        } 
        if {[string is double -strict $primarycpnt_y] != 1} {
            error "Needs proper y center"
        } 
        if {[string is double -strict $primarycpnt_z] != 1} {
            error "Needs proper z center"
        } 
    }
    set sel [atomselect top "${mol_sel}"]
    set radius [measure rgyr $sel]
    set new_radius [expr $radius*0.4]
    set com [measure center $sel]
    if {($primarycpnt_x != "") && ($primarycpnt_x != "") && ($primarycpnt_x != "")} {
        draw sphere [list $primarycpnt_x $primarycpnt_y $primarycpnt_z] radius $new_radius
    } else {
        draw sphere $com radius $new_radius
    }
}

proc holehelper_tk_cb {} {
    variable foobar
    ::HOLEHelper::holehelper
    return $HOLEHelper::w
}