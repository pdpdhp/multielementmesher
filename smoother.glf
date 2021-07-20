# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

proc Global_Smooth { } {
	
	global smthd floatd floatedg fixd fixedg orthod orthoedg gsmthiter
	
	upvar 1 symsepdd asep

	# running elliptic solver over domains surrounding the configuration

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
	
	puts $asep
	puts "GLOBAL ELLIPTIC SOLVER FINISHED $gsmthiter ITERATIONS OVER [llength $smthd] STRUCTURED DOMAINS."
	puts $asep
}

