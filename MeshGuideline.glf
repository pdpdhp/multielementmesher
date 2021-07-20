# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

proc MGuideLine {ref_lev hoarg guidedir} {
	
	global ypg dsg grg chord_sg ter_sg ler_sg tpts1_sg tpts2_sg exp_sg imp_sg vol_sg stp_sg
	
	#Reading Meshing Guidline
	if {[string compare $hoarg YES]==0} {
		set fp [open "$guidedir/grid_specification_HO.txt" r]
	} else {
		set fp [open "$guidedir/grid_specification_metric.txt" r]
	}

	set i 0
	while {[gets $fp line] >= 0} {
		set g_spec($i) {}
			foreach elem $line {
				lappend g_spec($i) [scan $elem %e]
			}
		incr i
	}
	close $fp

	for {set j 1} {$j<$i} {incr j} {
		lappend y_p [lindex $g_spec($j) 0]
		lappend d_s [lindex $g_spec($j) 1]
		lappend gr [lindex $g_spec($j) 2]
		lappend chord_s [lindex $g_spec($j) 3]
		lappend ter [lindex $g_spec($j) 4]
		lappend ler [lindex $g_spec($j) 5]
		lappend tpt1 [lindex $g_spec($j) 6]
		lappend tpt2 [lindex $g_spec($j) 7]
		lappend exp [lindex $g_spec($j) 8]
		lappend imp [lindex $g_spec($j) 9]
		lappend vol [lindex $g_spec($j) 10]
		lappend extr [lindex $g_spec($j) 11]
	}

	set NUM_REF [llength $y_p]

	if {$ref_lev<$NUM_REF} {
		set ypg [lindex $y_p $ref_lev]
		set dsg [lindex $d_s $ref_lev]
		set grg [lindex $gr $ref_lev]
		set chord_sg [lindex $chord_s $ref_lev]
		set ter_sg [lindex $ter $ref_lev]
		set ler_sg [lindex $ler $ref_lev]
		set tpts1_sg [lindex $tpt1 $ref_lev]
		set tpts2_sg [lindex $tpt2 $ref_lev]
		set exp_sg [lindex $exp $ref_lev]
		set imp_sg [lindex $imp $ref_lev]
		set vol_sg [lindex $vol $ref_lev]
		set stp_sg [lindex $extr $ref_lev]
	} else {
		puts "PLEASE SELECT THE RIGHT REFINEMENT LEVEL ACCORDING TO YOUR GUIDELINE FILE: ref_lev"
		exit -1
	}

}
