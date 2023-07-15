package provide holehelper 1.0

#PBC wrap ruins the whole system when wrapping, need to load in the system after everything is done

namespace eval ::HOLEHelper:: {
    variable w
    variable primarypdb
    variable primarypsf
    variable primarydcd
    variable dcd_step
	variable mol_sel
	variable wrapping_condition
	variable output_pdb
	variable sphere_directory
	variable primarycvec_x
	variable primarycvec_y
	variable primarycvec_z
	variable radius
	variable endrad
	variable primarycpnt_x
	variable primarycpnt_y
	variable primarycpnt_z

} 


proc ::HOLEHelper::holehelper {} {
    variable w
    variable primarypdb
    variable primarypsf
    variable primarydcd
    variable dcd_step
	variable mol_sel
	variable wrapping_condition
	variable output_pdb
	variable sphere_directory
	variable primarycvec_x
	variable primarycvec_y
	variable primarycvec_z
	variable radius
	variable endrad
	variable primarycpnt_x
	variable primarycpnt_y
	variable primarycpnt_z


    if { [winfo exists .holehelper] } {
        wm deiconify $w
	return
    }

    set w [toplevel ".holehelper"]
    wm title $w "Hole Helper"
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 0 -weight 1

    wm geometry $w 510x460

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
    grid [label $mol_window.wrapping.wraplabel -text "PBC Wraping Condition: "] \
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

    frame $inp_window.temppdb
    grid [label $inp_window.temppdb.tpdblabel -text "Output PDB File Name: "] \
    -row 1 -column 0 -sticky e
    grid [entry $inp_window.temppdb.tpdbpath -textvariable \
    ::HOLEHelper::output_pdb -width 70 -justify left] -row 1 -column 1
	grid columnconfigure $inp_window.temppdb 1 -weight 1
	

    frame $inp_window.sphere
    grid [label $inp_window.sphere.sphlabel -text "SPH Ouput File Path: "] \
    -row 1 -column 0 -sticky e
    grid [entry $inp_window.sphere.sphpath -textvariable \
    ::HOLEHelper::sphere_directory -width 70 -justify left] -row 1 -column 1
	grid columnconfigure $inp_window.sphere 1 -weight 1
	
	frame $inp_window.cvect
	pack [label $inp_window.cvect.cvlabel -text "Center Vector (x,y,z): " ] -side left
	pack [entry $inp_window.cvect.x -width 15 -textvariable HOLEHelper::primarycvec_x] -side left
	pack [entry $inp_window.cvect.y -width 15 -textvariable HOLEHelper::primarycvec_y] -side left
	pack [entry $inp_window.cvect.z -width 15 -textvariable HOLEHelper::primarycvec_z] -side left
	
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
	pack [entry $inp_window.cpnt.x -width 15 -textvariable HOLEHelper::primarycpnt_x] -side left
	pack [entry $inp_window.cpnt.y -width 15 -textvariable HOLEHelper::primarycpnt_y] -side left
	pack [entry $inp_window.cpnt.z -width 15 -textvariable HOLEHelper::primarycpnt_z] -side left
	
    frame $inp_window.edrad
    grid [label $inp_window.edrad.endlabel -text "Endrad: "] \
    -row 1 -column 0 -sticky e
    grid [entry $inp_window.edrad.endpath -textvariable \
    ::HOLEHelper::endrad -width 70 -justify left] -row 1 -column 1
	grid columnconfigure $inp_window.edrad 1 -weight 1
	
	
	pack $inp_window -side top -pady 5 -padx 3 -fill x -anchor w
	pack $inp_window.temppdb $inp_window.sphere $inp_window.rad $inp_window.cvect $inp_window.optional $inp_window.cpnt $inp_window.edrad \
		-side top -padx 0 -pady 2 -expand 1 -fill x
	
    pack [button $w.running -text "Run HOLE2" -command ::HOLEHelper::run_hole2] \
    -side top -pady 5 -padx 3 -fill x -anchor w
	
    pack [button $w.loaded -text "Run HOLE2 On Top Mol" -command ::HOLEHelper::loaded_hole] \
    -side top -pady 5 -padx 3 -fill x -anchor w
	#-------------------------------------------------------------------------

}

proc ::HOLEHelper::run_hole2 {} {

    variable primarypdb
    variable primarypsf
    variable primarydcd
    variable dcd_step
	variable mol_sel
	variable wrapping_condition
	variable output_pdb
	variable sphere_directory
	variable primarycvec_x
	variable primarycvec_y
	variable primarycvec_z
	variable radius 
	variable endrad
	variable primarycpnt_x
	variable primarycpnt_y
	variable primarycpnt_z
	
	puts "This is the text"

}

proc ::HOLEHelper::loaded_hole {} {

	puts "This is for loaded HOLE"
}

proc holehelper_tk_cb {} {
    variable foobar
    ::HOLEHelper::holehelper
    return $HOLEHelper::w
}
