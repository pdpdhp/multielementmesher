# =============================================================
# This script is written to generate structured multi-block
# grids with different refinement levels over the CRM high-lift 
# 2D section according to grid guideline specifications.
#==============================================================
#
# written by Pay Dehpanah
# Feb 2020 
# 
#==============================================================
#
# called by ---> extrusion.glf
#
#==============================================================

package require PWI_Glyph 3.18.3

set scriptDir [file dirname [info script]]

# running elliptic solver over domains surrounded the configuration

if {$smth == 1} {
	set bcs []
	set smthdoms []

	for {set i 0} {$i < [llength $doms]} {incr i} {
		lappend smthdoms [lindex $doms $i]
		lappend bcs 1
		lappend smthdoms [lindex $doms $i]
		lappend bcs 2
		lappend smthdoms [lindex $doms $i]
		lappend bcs 3
		lappend smthdoms [lindex $doms $i]
		lappend bcs 4
	}

	set smth1 [pw::Application begin EllipticSolver $doms]

	for {set i 0} {$i<[llength $smthdoms]} {incr i} {
		[lindex $smthdoms $i] setEllipticSolverAttribute -edge [lindex $bcs $i] EdgeConstraint Floating
	}

	for {set i 0} {$i<[llength $adjdoms]} {incr i} {
		[lindex $adjdoms $i] setEllipticSolverAttribute -edge [lindex $adjbcs $i] EdgeSpacingCalculation Adjacent
	}

	foreach elm [list $dom_blk3 $blk31] bc [list 2 1] {
		$elm setEllipticSolverAttribute -edge $bc EdgeConstraint Fixed
	}

	for {set i 0} {$i<[llength $doms]} {incr i} {
		$smth1 setActiveSubGrids [lindex $doms $i] [list]
	}

	$smth1 run 2000
	$smth1 end

	puts "Elliptic solver ran over first  and second layers of structured domains! To run only over the first layer switch off smth!"
}

# running elliptic solver over the C-type outer domain

if { $smth_b == 1} {
	set smth2 [pw::Application begin EllipticSolver [list $blkxtr2]]
	$smth2 setActiveSubGrids $blkxtr2 [list]
	$smth2 run 500
	$smth2 end
	puts "Elliptic solver ran over third layer of structured domain!"
}

