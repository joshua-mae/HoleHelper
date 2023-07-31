set user [exec whoami]
set hh_path [exec find /home/$user -type d -name "HH-Results" ! -path "/home/*/*.*"]
cd $hh_path/sph-folder

set frame_nums [molinfo top get numframes]
set sphfilelist [lsort [glob *.sph]]

foreach sph $sphfilelist {
    mol new $sph type pdb
    set real_atom_count [molinfo top get numatoms]
    set moleculeid [molinfo top]
    set fake_atom_count 10000
    set atom_count_diff [expr $fake_atom_count - $real_atom_count]
    set outfile [open $sph a]
    for { set f 0 } {$f < $atom_count_diff } { incr f} {
        puts $outfile "ATOM      1  QSS SPH S-888"
    }
    close $outfile
    mol delete $moleculeid
}
