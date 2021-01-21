
package require PWI_Glyph 3.18.3

set scriptDir [file dirname [info script]]

set xtr1 90
set xtr2 44

# =====================================================OUTTER DOMAIN EXTRUSION====================================

set edgxtr [pw::Edge createFromConnectors [list [lindex $conu_tail 0] [lindex $conu_tail 1] [lindex $conu_tail 2] [lindex $con_consp 1] [lindex $conl_tail 0]\
						[lindex $conl_tail 1] [lindex $conl_tail 2] [lindex $conl_tail 3]]]
set blkxtr [pw::DomainStructured create]
$blkxtr addEdge $edgxtr
set sxtr [pw::Application begin ExtrusionSolver [list $blkxtr]]
$blkxtr setExtrusionBoundaryCondition Begin Splay 0.015
$blkxtr setExtrusionBoundaryConditionStepSuppression Begin 0
$blkxtr setExtrusionBoundaryCondition End Splay 0.015
$blkxtr setExtrusionBoundaryConditionStepSuppression End 0
$blkxtr setExtrusionSolverAttribute NormalInitialStepSize $texrv
$blkxtr setExtrusionSolverAttribute SpacingGrowthFactor 1.05
$blkxtr setExtrusionSolverAttribute NormalMaximumStepSize 0.0
$blkxtr setExtrusionSolverAttribute NormalExplicitSmoothing 0.09
$blkxtr setExtrusionSolverAttribute NormalImplicitSmoothing 20.0
$blkxtr setExtrusionSolverAttribute NormalKinseyBarthSmoothing 0.0
$blkxtr setExtrusionSolverAttribute NormalVolumeSmoothing 0.01
$sxtr run $xtr1
$sxtr end

set blkxtredge [[$blkxtr getEdge 3] getConnector 1]

set xtr1i [expr int([$blkxtredge getDimension]/2)]

set stepxtr [pw::Examine create DomainLengthJ]
$stepxtr addEntity $blkxtr
$stepxtr examine
set stepxtrv [$stepxtr getValue $blkxtr [list $xtr1i $xtr1]]

set end1x1 [[$blkxtr getEdge 2] getConnector 1]
set end1x1s [pw::Examine create ConnectorEdgeLength]
$end1x1s addEntity $end1x1
$end1x1s examine
set end1x1sv [$end1x1s getMaximum]

set end2x1 [[$blkxtr getEdge 4] getConnector 1]
set end2x1s [pw::Examine create ConnectorEdgeLength]
$end2x1s addEntity $end2x1
$end2x1s examine
set end2x1sv [$end2x1s getMaximum]

# =====================================================OUTTER DOMAIN EXTRUSION====================================

set edgxtr2 [pw::Edge createFromConnectors [list $blkxtredge]]
set blkxtr2 [pw::DomainStructured create]
$blkxtr2 addEdge $edgxtr2
set sxtr2 [pw::Application begin ExtrusionSolver [list $blkxtr2]]
$blkxtr2 setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
$blkxtr2 setExtrusionBoundaryCondition Begin Splay 0.015
$blkxtr2 setExtrusionBoundaryConditionStepSuppression Begin 0
$blkxtr2 setExtrusionBoundaryCondition End Splay 0.015
$blkxtr2 setExtrusionBoundaryConditionStepSuppression End 0
$blkxtr2 setExtrusionSolverAttribute NormalInitialStepSize $stepxtrv
$blkxtr2 setExtrusionSolverAttribute SpacingGrowthFactor 1.12
$blkxtr2 setExtrusionSolverAttribute NormalMaximumStepSize 50.0
$blkxtr2 setExtrusionSolverAttribute NormalExplicitSmoothing 0.1
$blkxtr2 setExtrusionSolverAttribute NormalImplicitSmoothing 0.2
$blkxtr2 setExtrusionSolverAttribute NormalKinseyBarthSmoothing 1.5
$blkxtr2 setExtrusionSolverAttribute NormalVolumeSmoothing 0.13
$sxtr2 run $xtr2
$sxtr2 end

set end1x2 [[$blkxtr2 getEdge 2] getConnector 1]
[$end1x2 getDistribution 1] setBeginSpacing $end2x1sv
set end2x2 [[$blkxtr2 getEdge 4] getConnector 1]
[$end2x2 getDistribution 1] setBeginSpacing $end1x1sv

