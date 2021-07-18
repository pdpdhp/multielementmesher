# =============================================================
# This script is written to generate structured multi-block
# grids with different refinement levels over the CRM high-lift 
# 2D section according to grid guideline specifications.
#==============================================================
#
# written by Pay Dehpanah
# Mar 2021
# 
#==============================================================
#
# called by ---> extrusion.glf
#
#==============================================================

package require PWI_Glyph 3.18.3

set scriptDir [file dirname [info script]]

# running elliptic solver over domains surrounding the configuration

if {[string compare $global_smth YES]==0 && [string compare $GRD_TYP STR]==0} {

	set smth1 [pw::Application begin EllipticSolver $smthd]

	for {set i 0} {$i<[llength $floatd]} {incr i} {
		[lindex $floatd $i] setEllipticSolverAttribute -edge [lindex $floatedg $i] EdgeConstraint Floating
		[lindex $floatd $i] setEllipticSolverAttribute -edge [lindex $floatedg $i] EdgeSpacingCalculation Adjacent
	}

	foreach elm $fixd bc $fixedg {
		$elm setEllipticSolverAttribute -edge $bc EdgeConstraint Fixed
	}
	
	foreach elm $orthod bc $orthoedg {
		$elm setEllipticSolverAttribute -edge $bc EdgeConstraint Orthogonal
	}
	
	for {set i 0} {$i<[llength $smthd]} {incr i} {
		$smth1 setActiveSubGrids [lindex $smthd $i] [list]
	}

	$smth1 run $gsmthiter
	$smth1 end
	
	[lindex $smthd 5] setOrientation JMinimum IMinimum

	[lindex $smthd 0] setOrientation JMinimum IMinimum
	[lindex $smthd 0] setOrientation IMaximum JMinimum
	[lindex $smthd 0] setOrientation IMinimum JMaximum

	[lindex $smthd 3] setOrientation IMinimum JMaximum
	
	puts $symsepdd
	puts "GLOBAL ELLIPTIC SOLVER FINISHED $gsmthiter ITERATIONS OVER [llength $smthd] STRUCTURED DOMAINS."
	puts $symsepdd
}

