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

if {$res_lev == 0} {
	set res_lev 0.5
}

for {set i 0} {$i<[llength $spcgrfact]} {incr i} {
	lappend spcextrgr [expr ([lindex $spcgrfact $i] - 1)*($res_lev/6.0) + 1]
}


set maxstpsize [list 12 24]

for {set i 0} {$i<[llength $maxstpsize]} {incr i} {
	lappend maxstpextr [expr [lindex $maxstpsize $i]*($res_lev/6.0)]
}


# =====================================================OUTTER DOMAIN EXTRUSION====================================

set edgxtr [pw::Edge createFromConnectors [list [lindex $conu_tail 0] [lindex $conu_tail 1] [lindex $conu_tail 2] [lindex $con_consp 1] [lindex $conl_tail 0]\
						[lindex $conlowspsp 0] [lindex $conlowspsp 1] [lindex $conl_tail 1] [lindex $conl_tail 2] [lindex $conl_tail 3]]]
set blkxtr [pw::DomainStructured create]
$blkxtr addEdge $edgxtr
set sxtr [pw::Application begin ExtrusionSolver [list $blkxtr]]
$blkxtr setExtrusionBoundaryCondition Begin Splay 0.001
$blkxtr setExtrusionBoundaryConditionStepSuppression Begin 0
$blkxtr setExtrusionBoundaryCondition End Splay 0.001
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

#set blkxtredge [[$blkxtr getEdge 3] getConnector 1]
#set blkxtredge2 [[[$blkxtr getEdge 2] getConnector 1] getDimension]

#set xtr1i [expr int([$blkxtredge getDimension]/2)]

#set stepxtr [pw::Examine create DomainLengthJ]
#$stepxtr addEntity $blkxtr
#$stepxtr examine
#set stepxtrv [$stepxtr getValue $blkxtr [list $xtr1i $blkxtredge2]]

#set end1x1 [[$blkxtr getEdge 2] getConnector 1]
#set end1x1s [pw::Examine create ConnectorEdgeLength]
#$end1x1s addEntity $end1x1
#$end1x1s examine
#set end1x1sv [$end1x1s getMaximum]

#set end2x1 [[$blkxtr getEdge 4] getConnector 1]
#set end2x1s [pw::Examine create ConnectorEdgeLength]
#$end2x1s addEntity $end2x1
#$end2x1s examine
#set end2x1sv [$end2x1s getMaximum]

## =====================================================OUTTER DOMAIN EXTRUSION====================================

#set edgxtr2 [pw::Edge createFromConnectors [list $blkxtredge]]
#set blkxtr2 [pw::DomainStructured create]
#$blkxtr2 addEdge $edgxtr2
#set sxtr2 [pw::Application begin ExtrusionSolver [list $blkxtr2]]
#$blkxtr2 setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
#$blkxtr2 setExtrusionBoundaryCondition Begin Splay 0.03
#$blkxtr2 setExtrusionBoundaryConditionStepSuppression Begin 0
#$blkxtr2 setExtrusionBoundaryCondition End Splay 0.03
#$blkxtr2 setExtrusionBoundaryConditionStepSuppression End 0
#$blkxtr2 setExtrusionSolverAttribute NormalInitialStepSize $stepxtrv
#$blkxtr2 setExtrusionSolverAttribute SpacingGrowthFactor 1.05
#$blkxtr2 setExtrusionSolverAttribute NormalMaximumStepSize 50.0
#$blkxtr2 setExtrusionSolverAttribute StopAtHeight 440
#$blkxtr2 setExtrusionSolverAttribute NormalExplicitSmoothing 0.1
#$blkxtr2 setExtrusionSolverAttribute NormalImplicitSmoothing 0.2
#$blkxtr2 setExtrusionSolverAttribute NormalKinseyBarthSmoothing 0.0
#$blkxtr2 setExtrusionSolverAttribute NormalVolumeSmoothing 0.1
#$sxtr2 run $xtr2
#$sxtr2 end

#$domexm addEntity $blkxtr2
#lappend ncells [$blkxtr2 getCellCount]

#set end1x2 [[$blkxtr2 getEdge 2] getConnector 1]
#[$end1x2 getDistribution 1] setBeginSpacing $end2x1sv
#set end2x2 [[$blkxtr2 getEdge 4] getConnector 1]
#[$end2x2 getDistribution 1] setBeginSpacing $end1x1sv

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

$domexm addEntity [lindex $blkxtrsp 0]
	lappend ncells [[lindex $blkxtrsp 0] getCellCount]
	lappend doms [lindex $blkxtrsp 0]
$domexm addEntity [lindex $blkxtrsp 1]
	lappend ncells [[lindex $blkxtrsp 1] getCellCount]
	lappend doms [lindex $blkxtrsp 1]
$domexm addEntity [lindex $blkxtrsp 2]
	lappend ncells [[lindex $blkxtrsp 2] getCellCount]
	lappend doms [lindex $blkxtrsp 2]
$domexm addEntity [lindex $blkxtrsp 3]
	lappend ncells [[lindex $blkxtrsp 3] getCellCount]
	lappend doms [lindex $blkxtrsp 3]
$domexm addEntity [lindex $blkxtrsp 4]
	lappend ncells [[lindex $blkxtrsp 4] getCellCount]
	lappend doms [lindex $blkxtrsp 4]
$domexm addEntity [lindex $blkxtrsp 5]
	lappend ncells [[lindex $blkxtrsp 5] getCellCount]
	lappend doms [lindex $blkxtrsp 5]
$domexm addEntity [lindex $blkxtrsp 6]
	lappend ncells [[lindex $blkxtrsp 6] getCellCount]
	lappend doms [lindex $blkxtrsp 6]
$domexm addEntity [lindex $blkxtrsp 7]
	lappend ncells [[lindex $blkxtrsp 7] getCellCount]
	lappend doms [lindex $blkxtrsp 7]
$domexm addEntity [lindex $blkxtrsp 8]
	lappend ncells [[lindex $blkxtrsp 8] getCellCount]
	lappend doms [lindex $blkxtrsp 8]
$domexm addEntity [lindex $blkxtrsp 9]
	lappend ncells [[lindex $blkxtrsp 9] getCellCount]
	lappend doms [lindex $blkxtrsp 9]
	
lappend adjdoms [lindex $blkxtrsp 0]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 1]
lappend adjbcs 4
lappend adjdoms [lindex $blkxtrsp 1]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 2]
lappend adjbcs 4
lappend adjdoms [lindex $blkxtrsp 2]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 3]
lappend adjbcs 4
lappend adjdoms [lindex $blkxtrsp 3]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 4]
lappend adjbcs 4
lappend adjdoms [lindex $blkxtrsp 4]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 5]
lappend adjbcs 4
lappend adjdoms [lindex $blkxtrsp 5]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 6]
lappend adjbcs 4
lappend adjdoms [lindex $blkxtrsp 6]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 7]
lappend adjbcs 4
lappend adjdoms [lindex $blkxtrsp 7]
lappend adjbcs 2

lappend adjdoms [lindex $blkxtrsp 8]
lappend adjbcs 4

set blk12sp [$blk12 split -J [list $I9]]

$domexm addEntity [lindex $blk12sp 0]
	lappend ncells [[lindex $blk12sp 0] getCellCount]
	lappend doms [lindex $blk12sp 0]
$domexm addEntity [lindex $blk12sp 1]
	lappend ncells [[lindex $blk12sp 1] getCellCount]
	lappend doms [lindex $blk12sp 1]

lappend adjdoms [lindex $blk12sp 0]
lappend adjbcs 1

##=====================================================SMOOTHER====================================

#source [file join $scriptDir "smoother.glf"]


