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
# called by ---> mesher.glf
#
#==============================================================


package require PWI_Glyph 3.18.3

set scriptDir [file dirname [info script]]

set xtr1 200

set spcgrfact [list 1.08 1.1 1.12 1.15]
set sply [list 0.001 0.0025 0.005 0.01 0.01 0.015 0.02]
set levratio [list 0.9 1 2 3 4 5 6]

for {set i 0} {$i<[llength $spcgrfact]} {incr i} {
	lappend spcextrgr [expr ([lindex $spcgrfact $i] - 1)*([lindex $levratio $res_lev]/6.0) + 1]
}


set maxstpsize [list 12 24]

for {set i 0} {$i<[llength $maxstpsize]} {incr i} {
	lappend maxstpextr [expr [lindex $maxstpsize $i]*([lindex $levratio $res_lev]/6.0)]
}


# =====================================================OUTTER DOMAIN EXTRUSION====================================

set edgxtr [pw::Edge createFromConnectors [list [lindex $conu_tail 0] [lindex $conu_tail 1] [lindex $conu_tail 2] [lindex $con_consp 1] [lindex $conl_tail 0]\
						[lindex $conlowspsp 0] [lindex $conlowspsp 1] [lindex $conl_tail 1] [lindex $conl_tail 2] [lindex $conl_tail 3]]]
set blkxtr [pw::DomainStructured create]
$blkxtr addEdge $edgxtr
set sxtr [pw::Application begin ExtrusionSolver [list $blkxtr]]
$blkxtr setExtrusionBoundaryCondition Begin Splay [lindex $sply $res_lev]
$blkxtr setExtrusionBoundaryConditionStepSuppression Begin 0
$blkxtr setExtrusionBoundaryCondition End Splay [lindex $sply $res_lev]
$blkxtr setExtrusionBoundaryConditionStepSuppression End 0
$blkxtr setExtrusionSolverAttribute NormalInitialStepSize $texrv
$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 0]
$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize 0.0
$blkxtr setExtrusionSolverAttribute StopAtHeight 25
$blkxtr setExtrusionSolverAttribute NormalExplicitSmoothing 0.1
$blkxtr setExtrusionSolverAttribute NormalImplicitSmoothing 0.2
$blkxtr setExtrusionSolverAttribute NormalKinseyBarthSmoothing 0.0
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.0001
$sxtr run $xtr1
$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 1]
$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 0]
$blkxtr setExtrusionSolverAttribute StopAtHeight 75
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.005
$sxtr run $xtr1
$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 2]
$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize [lindex $maxstpextr 1]
$blkxtr setExtrusionSolverAttribute StopAtHeight 100
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.009
$sxtr run $xtr1
$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor [lindex $spcextrgr 3]
$blkxtr setExtrusionSolverAttribute StopAtHeight 125
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.013
$sxtr run $xtr1
$blkxtr setExtrusionSolverAttribute StopAtHeight 150
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.015
$sxtr run $xtr1
$blkxtr setExtrusionSolverAttribute StopAtHeight 175
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.02
$sxtr run $xtr1
$blkxtr setExtrusionSolverAttribute StopAtHeight 225
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.022
$sxtr run $xtr1
$blkxtr setExtrusionSolverAttribute StopAtHeight 270
$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize 0.0
$blkxtr setExtrusionSolverAttribute NormalExplicitSmoothing 0.3
$blkxtr setExtrusionSolverAttribute NormalImplicitSmoothing 0.9
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.025
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

set blkxtrsp [$blkxtr split -I [list $I1 [expr $I1+$I2-1] [expr $I3+$I2+$I1-2] [expr $I4+$I3+$I2+$I1-3] [expr $I5+$I4+$I3+$I2+$I1-4] [expr $I6+$I5+$I4+$I3+$I2+$I1-5]\
							[expr $I7+$I6+$I5+$I4+$I3+$I2+$I1-6] [expr $I8+$I7+$I6+$I5+$I4+$I3+$I2+$I1-7] [expr $I9+$I8+$I7+$I6+$I5+$I4+$I3+$I2+$I1-8]]]

# ================================================REJOINING DOMAINS================================

lappend floatd $dom_blk3
lappend floatedg 4
lappend fixd $dom_blk3
lappend fixedg 2

lappend floatd $blk4
lappend floatd $blk4
lappend floatedg 2 
lappend floatedg 4
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

lappend floatd [lindex $blkjoin 0]
lappend floatd [lindex $blkjoin 0]
lappend floatedg 1
lappend floatedg 4

set connjoin(2) []

lappend connjoin(2) [[[lindex $blkjoin 1] getEdge 1] getConnector 3]
lappend connjoin(2) [[[lindex $blkjoin 1] getEdge 1] getConnector 4]

lappend floatd [lindex $blkjoin 1]
lappend floatd [lindex $blkjoin 1]
lappend fixd [lindex $blkjoin 1]
lappend floatedg 1
lappend floatedg 3
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
lappend floatd [lindex $blkjoin 6]
lappend orthoedg 1
lappend floatedg 4

set conjoin []

lappend conjoin [pw::Connector join [list [lindex $connjoin(1) 0] [lindex $connjoin(1) 1] [lindex $connjoin(1) 2]]]
lappend conjoin [pw::Connector join [list [lindex $connjoin(2) 0] [lindex $connjoin(2) 1]]]
lappend conjoin [pw::Connector join [list [lindex $connjoin(3) 0] [lindex $connjoin(3) 1]]]
lappend conjoin [pw::Connector join [list [lindex $connjoin(4) 0] [lindex $connjoin(4) 1] ]]
lappend conjoin [pw::Connector join [list [lindex $connjoin(5) 0] [lindex $connjoin(5) 1] ]]
lappend conjoin [pw::Connector join [list [lindex $connjoin(6) 0] [lindex $connjoin(6) 1] ]]
lappend conjoin [pw::Connector join [list [lindex $connjoin(7) 0] [lindex $connjoin(7) 1] [lindex $connjoin(7) 2]]]

$domexm addEntity $blkjoin

for {set i 0} {$i < [llength $blkjoin]} {incr i} {
	lappend ncells [[lindex $blkjoin $i] getCellCount]
}

set smthd [list $dom_blk3 $blk4 {*}$blkjoin]

#=====================================================SMOOTHER====================================

source [file join $scriptDir "smoother.glf"]


