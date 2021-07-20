# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

proc Extr_Mesh { } {
	
	global conu_tail con_consp conl_tail conlowspsp texrv
	global dom_blk3 blk4 blk5 blk33 r3_blk4 blk322 r3_blk3 blk31 blk321 r1_blk2 blk3 blk1 blk12sp blk2 blk22 domexm
	
	upvar 1 GRD_TYP grid_type
	upvar 1 res_lev grid_level
	
	global smthd floatd floatedg fixd fixedg orthod orthoedg gsmthiter domfarbc confarbc ncells
	
	#smoother Entities
	set floatd []
	set floatedg []
	set orthod []
	set orthoedg []
	set fixd []
	set fixedg []
	
	set xtr1 200

	set spcgrfact [list 1.04 1.06 1.08 1.1]
	set sply [list 0.0003 0.0004 0.0005 0.001 0.003 0.01 0.03]
	set levratio [list 0.9999 1 2 3 4 5 6]

	for {set i 0} {$i<[llength $spcgrfact]} {incr i} {
		lappend spcextrgr [expr ([lindex $spcgrfact $i] - 1)*([lindex $levratio $grid_level]/6.0) + 1]
	}


	set maxstpsize [list 12 24 48 96 192 350]

	for {set i 0} {$i<[llength $maxstpsize]} {incr i} {
		lappend maxstpextr [expr [lindex $maxstpsize $i]*([lindex $levratio $grid_level]/6.0)]
	}


	# =====================================================OUTTER DOMAIN EXTRUSION====================================

	set edgxtr [pw::Edge createFromConnectors [list [lindex $conu_tail 0] [lindex $conu_tail 1] [lindex $conu_tail 2] [lindex $con_consp 1] [lindex $conl_tail 0]\
							[lindex $conlowspsp 0] [lindex $conlowspsp 1] [lindex $conl_tail 1] [lindex $conl_tail 2] [lindex $conl_tail 3]]]
	set blkxtr [pw::DomainStructured create]
	$blkxtr addEdge $edgxtr
	set sxtr [pw::Application begin ExtrusionSolver [list $blkxtr]]
	$blkxtr setExtrusionBoundaryCondition Begin Splay [lindex $sply $grid_level]
	$blkxtr setExtrusionBoundaryConditionStepSuppression Begin 0
	$blkxtr setExtrusionBoundaryCondition End Splay [lindex $sply $grid_level]
	$blkxtr setExtrusionBoundaryConditionStepSuppression End 0
	$blkxtr setExtrusionSolverAttribute NormalInitialStepSize $texrv
	$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 0]
	$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize 0.0
	$blkxtr setExtrusionSolverAttribute StopAtHeight 50
	$blkxtr setExtrusionSolverAttribute NormalExplicitSmoothing 0.1
	$blkxtr setExtrusionSolverAttribute NormalImplicitSmoothing 0.2
	$blkxtr setExtrusionSolverAttribute NormalKinseyBarthSmoothing 0.0
	$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.0001
	$sxtr run $xtr1
	$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 1]
	$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 0]
	$blkxtr setExtrusionSolverAttribute StopAtHeight 150
	$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.001
	$sxtr run $xtr1
	$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 2]
	$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 1]
	$blkxtr setExtrusionSolverAttribute StopAtHeight 300
	$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.003
	$sxtr run $xtr1
	$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 3]
	$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 2]
	$blkxtr setExtrusionSolverAttribute StopAtHeight 600
	$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.005
	$sxtr run $xtr1
	$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 3]
	$blkxtr setExtrusionSolverAttribute StopAtHeight 1200
	$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.009
	$sxtr run $xtr1
	$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 4]
	$blkxtr setExtrusionSolverAttribute StopAtHeight 2400
	$blkxtr setExtrusionSolverAttribute NormalExplicitSmoothing 0.3
	$blkxtr setExtrusionSolverAttribute NormalImplicitSmoothing 0.9
	$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.02
	$sxtr run $xtr1
	$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 5]
	$blkxtr setExtrusionSolverAttribute StopAtHeight 4000
	$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.027
	$sxtr run $xtr1
	$sxtr end

	# split domains
	#====================================================================================================================

	set I1 [[lindex $conl_tail 3] getDimension]
	set I2 [[lindex $conl_tail 2] getDimension]
	set I3 [[lindex $conl_tail 1] getDimension]
	set I4 [[lindex $conl_tail 0] getDimension]
	set I5  [[lindex $conlowspsp 1] getDimension]
	set I6  [[lindex $conlowspsp 0] getDimension]
	set I7 [[lindex $con_consp 1] getDimension]
	set I8 [[lindex $conu_tail 2] getDimension]
	set I9 [[lindex $conu_tail 1] getDimension]

	set blkxtrsp [$blkxtr split -I [list $I1 [expr $I1+$I2-1] [expr $I3+$I2+$I1-2] [expr $I4+$I3+$I2+$I1-3] \
							[expr $I5+$I4+$I3+$I2+$I1-4] [expr $I6+$I5+$I4+$I3+$I2+$I1-5]\
								[expr $I7+$I6+$I5+$I4+$I3+$I2+$I1-6] [expr $I8+$I7+$I6+$I5+$I4+$I3+$I2+$I1-7] \
													[expr $I9+$I8+$I7+$I6+$I5+$I4+$I3+$I2+$I1-8]]]

	# ================================================REJOINING DOMAINS================================

	lappend floatd $dom_blk3
	lappend floatedg 4
	lappend fixd $dom_blk3
	lappend fixedg 2

	lappend fixd $blk4
	lappend fixd $blk4
	lappend fixedg 2 
	lappend fixedg 4
	lappend fixd $blk4
	lappend fixedg 1

	set blkjoin []

	lappend blkjoin [pw::DomainStructured join [list [lindex $blkxtrsp 0] [lindex $blkxtrsp 1] $blk5 $blk33 $r3_blk4]]
	lappend blkjoin [pw::DomainStructured join [list [lindex $blkxtrsp 2] $blk322 $r3_blk3]]
	lappend blkjoin [pw::DomainStructured join [list [lindex $blkxtrsp 4] [lindex $blkxtrsp 3] $blk31 $blk321]]
	lappend blkjoin [pw::DomainStructured join [list [lindex $blkxtrsp 6] [lindex $blkxtrsp 5] $r1_blk2 $blk3]]
	lappend blkjoin [pw::DomainStructured join [list [lindex $blkxtrsp 7] $blk1]]
	lappend blkjoin [pw::DomainStructured join [list [lindex $blkxtrsp 8] [lindex $blk12sp 0] $blk2]]
	lappend blkjoin [pw::DomainStructured join [list [lindex $blkxtrsp 9] [lindex $blk12sp 1] $blk22]]

	array set connjoin []
	set connjoin(1) []

	lappend connjoin(1) [[[lindex $blkjoin 0] getEdge 4] getConnector 1]
	lappend connjoin(1) [[[lindex $blkjoin 0] getEdge 4] getConnector 2]
	lappend connjoin(1) [[[lindex $blkjoin 0] getEdge 4] getConnector 3]

	lappend fixd [lindex $blkjoin 0]
	lappend fixd [lindex $blkjoin 0]
	lappend fixedg 1
	lappend fixedg 4

	set connjoin(2) []

	lappend connjoin(2) [[[lindex $blkjoin 1] getEdge 1] getConnector 3]
	lappend connjoin(2) [[[lindex $blkjoin 1] getEdge 1] getConnector 4]

	lappend floatd [lindex $blkjoin 1]
	lappend fixd [lindex $blkjoin 1]
	lappend fixd [lindex $blkjoin 1]
	lappend floatedg 1
	lappend fixedg 3
	lappend fixedg 4

	set connjoin(3) []

	lappend connjoin(3) [[[lindex $blkjoin 2] getEdge 1] getConnector 1]
	lappend connjoin(3) [[[lindex $blkjoin 2] getEdge 1] getConnector 2]

	lappend floatd [lindex $blkjoin 2]
	lappend fixd [lindex $blkjoin 2]
	lappend fixedg 1
	lappend floatedg 3

	set connjoin(4) []

	lappend connjoin(4) [[[lindex $blkjoin 3] getEdge 2] getConnector 1]
	lappend connjoin(4) [[[lindex $blkjoin 3] getEdge 2] getConnector 2]

	lappend floatd [lindex $blkjoin 3]
	lappend fixd [lindex $blkjoin 3]
	lappend floatedg 2
	lappend fixedg 4

	set connjoin(5) []

	lappend connjoin(5) [[[lindex $blkjoin 4] getEdge 1] getConnector 1]
	lappend connjoin(5) [[[lindex $blkjoin 4] getEdge 1] getConnector 2]

	lappend floatd [lindex $blkjoin 4]
	lappend fixd [lindex $blkjoin 4]
	lappend floatedg 1
	lappend fixedg 3

	set connjoin(6) []

	lappend connjoin(6) [[[lindex $blkjoin 5] getEdge 1] getConnector 3]
	lappend connjoin(6) [[[lindex $blkjoin 5] getEdge 1] getConnector 4]

	lappend orthod [lindex $blkjoin 5]
	lappend fixd [lindex $blkjoin 5]
	lappend orthoedg 3
	lappend fixedg 1

	lappend connjoin(7) [[[lindex $blkjoin 6] getEdge 1] getConnector 1]
	lappend connjoin(7) [[[lindex $blkjoin 6] getEdge 1] getConnector 2]
	lappend connjoin(7) [[[lindex $blkjoin 6] getEdge 1] getConnector 3]

	lappend orthod [lindex $blkjoin 6]
	lappend fixd [lindex $blkjoin 6]
	lappend orthoedg 1
	lappend fixedg 4

	set conjoin []

	lappend conjoin [pw::Connector join [list [lindex $connjoin(1) 0] [lindex $connjoin(1) 1] [lindex $connjoin(1) 2]]]
	lappend conjoin [pw::Connector join [list [lindex $connjoin(2) 0] [lindex $connjoin(2) 1]]]
	lappend conjoin [pw::Connector join [list [lindex $connjoin(3) 0] [lindex $connjoin(3) 1]]]
	lappend conjoin [pw::Connector join [list [lindex $connjoin(4) 0] [lindex $connjoin(4) 1] ]]
	lappend conjoin [pw::Connector join [list [lindex $connjoin(5) 0] [lindex $connjoin(5) 1] ]]
	lappend conjoin [pw::Connector join [list [lindex $connjoin(6) 0] [lindex $connjoin(6) 1] ]]
	lappend conjoin [pw::Connector join [list [lindex $connjoin(7) 0] [lindex $connjoin(7) 1] [lindex $connjoin(7) 2]]]

	$domexm addEntity $blkjoin

	if {[string compare $grid_type STR]==0} {
		for {set i 0} {$i < [llength $blkjoin]} {incr i} {
			lappend ncells [[lindex $blkjoin $i] getCellCount]
		}
	}

	set smthd [list $dom_blk3 $blk4 {*}$blkjoin]

	set connfar(1) []
	array set confar []

	lappend connfar(1) [[[lindex $blkjoin 0] getEdge 2] getConnector 1]
	lappend connfar(1) [[[lindex $blkjoin 0] getEdge 2] getConnector 2]
	lappend connfar(1) [[[lindex $blkjoin 0] getEdge 3] getConnector 1]
	lappend connfar(1) [[[lindex $blkjoin 0] getEdge 3] getConnector 2]

	set confar(1) [pw::Connector join [list [lindex $connfar(1) 0] [lindex $connfar(1) 1] [lindex $connfar(1) 2] [lindex $connfar(1) 3]]]

	lappend confarbc [lindex $confar(1) 0]
	lappend confarbc [lindex $confar(1) 1]

	lappend domfarbc [lindex $blkjoin 0]
	lappend domfarbc [lindex $blkjoin 0]

	set confar(2) [[[lindex $blkjoin 1] getEdge 2] getConnector 1]

	lappend confarbc [lindex $confar(2) 0]
	lappend domfarbc [lindex $blkjoin 1]

	set connfar(3) []

	lappend connfar(3) [[[lindex $blkjoin 2] getEdge 4] getConnector 1]
	lappend connfar(3) [[[lindex $blkjoin 2] getEdge 4] getConnector 2]

	set confar(3) [pw::Connector join [list [lindex $connfar(3) 0] [lindex $connfar(3) 1] ]]

	lappend confarbc [lindex $confar(3) 0]
	lappend domfarbc [lindex $blkjoin 2]

	set connfar(4) []

	lappend connfar(4) [[[lindex $blkjoin 3] getEdge 3] getConnector 1]
	lappend connfar(4) [[[lindex $blkjoin 3] getEdge 3] getConnector 2]

	set confar(4) [pw::Connector join [list [lindex $connfar(4) 0] [lindex $connfar(4) 1] ]]

	lappend confarbc [lindex $confar(4) 0]
	lappend domfarbc [lindex $blkjoin 3]

	set confar(5) [[[lindex $blkjoin 4] getEdge 2] getConnector 1]

	lappend confarbc [lindex $confar(5) 0]
	lappend domfarbc [lindex $blkjoin 4]

	set confar(6) [[[lindex $blkjoin 5] getEdge 2] getConnector 1]

	lappend confarbc [lindex $confar(6) 0]
	lappend domfarbc [lindex $blkjoin 5]

	set connfar(7) []

	lappend connfar(7) [[[lindex $blkjoin 6] getEdge 3] getConnector 1]
	lappend connfar(7) [[[lindex $blkjoin 6] getEdge 3] getConnector 2]
	lappend connfar(7) [[[lindex $blkjoin 6] getEdge 3] getConnector 3]

	set confar(7) [pw::Connector join [list [lindex $connfar(7) 0] [lindex $connfar(7) 1] [lindex $connfar(7) 2]]]

	lappend confarbc [lindex $confar(7) 0]
	lappend confarbc [[[lindex $blkjoin 6] getEdge 2] getConnector 1]
	lappend domfarbc [lindex $blkjoin 6]
	lappend domfarbc [lindex $blkjoin 6]

}

