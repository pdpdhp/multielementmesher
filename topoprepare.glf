package require PWI_Glyph 3.18.3

pw::Application reset

set scriptDir [file dirname [info script]]

#grid tolerance
pw::Grid setNodeTolerance 1.0e-20
pw::Grid setConnectorTolerance 1.0e-20
pw::Grid setGridPointTolerance 1.0e-20

pw::Connector setCalculateDimensionMaximum 100000
pw::Application setCAESolver $cae_solver 2

set domexm [pw::Examine create DomainArea]
set ncells []
set doms []
set adjdoms []
set adjbcs []

if {$airfoil==1} {
	puts "2-D CRM-HL wing section: fully structured multi-block grid generator!"
} elseif {$airfoil==2} {
	puts "2-D 30P-30N airfoil configuration: this part hasn't finished yet, please switch to 1!"
} else {

puts "Please specify the right airfoil configuration!"

}

if {$airfoil==1} {
	#Import Geometry
	set tmp_model [pw::Application begin DatabaseImport]
	  $tmp_model initialize -strict -type Automatic $scriptDir/crmhl-2dcut.igs
	  $tmp_model read
	  $tmp_model convert
	$tmp_model end
	unset tmp_model
} else {
	#Import Geometry
	set tmp_model [pw::Application begin DatabaseImport]
	  $tmp_model initialize -strict -type Automatic $scriptDir/2010_30p30n_thik_te_18inches.igs
	  $tmp_model read
	  $tmp_model convert
	$tmp_model end
	unset tmp_model
	set alldegs [pw::Database getAll -type pw::Curve]
	set datascale [pw::Application begin Modify $alldegs]
	pw::Entity transform [pwu::Transform scaling -anchor {0 0 0} {0.055555556 0.055555556 0.055555556}] [$datascale getEntities]
	$datascale end
	pw::Display zoomToFit -animate 1
}

set allquilts [pw::Database getAll -type pw::Quilt]
set allmodels [pw::Database getAll -type pw::Model]
set alldegs [pw::Database getAll -type pw::Curve]
	
set slatcons [list [lindex $alldegs 9] [lindex $alldegs 8]]
pw::Curve join $slatcons

set wingcons [list [lindex $alldegs 6] [lindex $alldegs 7]]
pw::Curve join $wingcons

set flapcons [list [lindex $alldegs 4] [lindex $alldegs 5]]
pw::Curve join $flapcons

pw::Display setCurrentLayer 20
set config_cons [pw::Connector createOnDatabase $alldegs]

for {set i 0} {$i < [llength $config_cons]} {incr i} {
	[lindex $config_cons $i] setDimensionFromSpacing $chord_sg
}

set wte [lindex $config_cons 2]
set fte [lindex $config_cons 3]
set ste [lindex $config_cons 1]

set su [lindex $config_cons 5]
set sl [lindex $config_cons 4]

set f [lindex $config_cons 7]

set w [lindex $config_cons 6]
set wc [lindex $config_cons 0]

set wingcons [$w split [$w getParameter -arc 0.54]]
set wu [lindex $wingcons 0]
set wl [lindex $wingcons 1]

set flapcons [$f split [$f getParameter -arc 0.52]]
set fu [lindex $flapcons 0]
set fl [lindex $flapcons 1]

$sl delete

set lslat_seg [pw::SegmentConic create]
$lslat_seg addPoint [[$ste getNode End] getXYZ]
$lslat_seg addPoint [[$su getNode End] getXYZ]
set lslat_con [pw::Connector create]
$lslat_con addSegment $lslat_seg
$lslat_con setLayer 20

$lslat_con project -type ClosestPoint -interior [lindex $alldegs 10]

set sl $lslat_con
$sl setDimensionFromSpacing $chord_sg

$ste delete

set slatte_seg [pw::SegmentConic create]
$slatte_seg addPoint [[$sl getNode Begin] getXYZ]
$slatte_seg addPoint [[$su getNode Begin] getXYZ]
set slatte_con [pw::Connector create]
$slatte_con addSegment $slatte_seg
$slatte_con setLayer 20

$slatte_con project -type ClosestPoint -interior [lindex $alldegs 1]

set ste $slatte_con

$wc delete

set wc_seg [pw::SegmentConic create]
$wc_seg addPoint [[$wte getNode End] getXYZ]
$wc_seg addPoint [[$wl getNode End] getXYZ]
set wc_con [pw::Connector create]
$wc_con addSegment $wc_seg
$wc_con setLayer 20

$wc_con project -type ClosestPoint -interior [lindex $alldegs 0]

set wc $wc_con

$wc setDimensionFromSpacing $chord_sg

set wcsrf [pw::DistributionGrowth create]
$wcsrf setBeginSpacing $ler_sg
$wcsrf setEndSpacing [expr $ler_sg*5]
set laySpcBegin $ler_sg
set laySpcEnd [expr $ler_sg*5]

set midSpc [expr 100*$chord_sg]
set laySpcGR $srfgr

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$wcsrf setMiddleMode ContinueGrowth
$wcsrf setMiddleSpacing $midSpc
$wcsrf setBeginLayers $i
$wcsrf setBeginRate $laySpcGR
$wcsrf setEndLayers $j
$wcsrf setEndRate $laySpcGR
$wc setDistribution 1 $wcsrf
$wc setSubConnectorDimensionFromDistribution 1

set upsrf [pw::DistributionGrowth create]
$upsrf setBeginSpacing $ler_sg
$upsrf setEndSpacing $ler_sg
set laySpcBegin $ler_sg
set laySpcEnd $ler_sg

set midSpc [expr 100*$chord_sg]
set laySpcGR $srfgr

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$upsrf setMiddleMode ContinueGrowth
$upsrf setMiddleSpacing $midSpc
$upsrf setBeginLayers $i
$upsrf setBeginRate $laySpcGR
$upsrf setEndLayers $j
$upsrf setEndRate $laySpcGR
$wu setDistribution 1 $upsrf
$wu setSubConnectorDimensionFromDistribution 1

set lowsrf [pw::DistributionGrowth create]
$lowsrf setBeginSpacing $ler_sg
$lowsrf setEndSpacing [expr $ler_sg*5]
set laySpcBegin $ler_sg
set laySpcEnd [expr $ler_sg*5]

set midSpc [expr 50*$chord_sg]
set laySpcGR $srfgr

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$lowsrf setMiddleMode ContinueGrowth
$lowsrf setMiddleSpacing $midSpc
$lowsrf setBeginLayers $i
$lowsrf setBeginRate $laySpcGR
$lowsrf setEndLayers $j
$lowsrf setEndRate $laySpcGR
$wl setDistribution 1 $lowsrf
$wl setSubConnectorDimensionFromDistribution 1

#flap
set upsrff [pw::DistributionGrowth create]
$upsrff setBeginSpacing $ler_sg
$upsrff setEndSpacing $ler_sg
set laySpcBegin $ler_sg
set laySpcEnd $ler_sg

set midSpc [expr 100*$chord_sg]
set laySpcGR $srfgr

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$upsrff setMiddleMode ContinueGrowth
$upsrff setMiddleSpacing $midSpc
$upsrff setBeginLayers $i
$upsrff setBeginRate $laySpcGR
$upsrff setEndLayers $j
$upsrff setEndRate $laySpcGR
$fu setDistribution 1 $upsrff
$fu setSubConnectorDimensionFromDistribution 1

$su addBreakPoint -arc 0.75

#slat_up
set sltsrfu1 [pw::DistributionGrowth create]
set sltsrfu2 [pw::DistributionGrowth create]

set laySpcBegin1 $ler_sg
set laySpcEnd1 $ler_sg

set laySpcBegin2 $ler_sg
set laySpcEnd2 $ter_sg

set midSpc [expr 3*$chord_sg]
set laySpcGR $srfgr

for {set i 0} {$laySpcBegin1 <= $midSpc} {incr i} {
	set laySpcBegin1 [expr $laySpcBegin1*$laySpcGR]
}

for {set j 0} {$laySpcEnd1 <= $midSpc} {incr j} {
	set laySpcEnd1 [expr $laySpcEnd1*$laySpcGR]
}

for {set p 0} {$laySpcBegin2 <= $midSpc} {incr p} {
	set laySpcBegin2 [expr $laySpcBegin2*$laySpcGR]
}

for {set q 0} {$laySpcEnd2 <= $midSpc} {incr q} {
	set laySpcEnd2 [expr $laySpcEnd2*$laySpcGR]
}

$sltsrfu1 setMiddleMode ContinueGrowth
$sltsrfu1 setMiddleSpacing $midSpc
$sltsrfu1 setBeginLayers $i
$sltsrfu1 setBeginRate $laySpcGR
$sltsrfu1 setEndLayers $j
$sltsrfu1 setEndRate $laySpcGR
$su setDistribution 1 $sltsrfu1
$su setSubConnectorDimensionFromDistribution 1

$sltsrfu1 setBeginSpacing $ler_sg
$sltsrfu1 setEndSpacing $ler_sg

$sltsrfu2 setMiddleMode ContinueGrowth
$sltsrfu2 setMiddleSpacing $midSpc
$sltsrfu2 setBeginLayers $p
$sltsrfu2 setBeginRate $laySpcGR
$sltsrfu2 setEndLayers $q
$sltsrfu2 setEndRate $laySpcGR
$su setDistribution 2 $sltsrfu2
$su setSubConnectorDimensionFromDistribution 2

$sltsrfu2 setBeginSpacing $ler_sg
$sltsrfu2 setEndSpacing $ter_sg

$su setDimensionFromDistribution

#slat low
set sltsrf [pw::DistributionGrowth create]
$sltsrf setBeginSpacing $ler_sg
$sltsrf setEndSpacing $ter_sg
set laySpcBegin $ler_sg
set laySpcEnd $ter_sg

set midSpc [expr 3*$chord_sg]
set laySpcGR $srfgr

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$sltsrf setMiddleMode ContinueGrowth
$sltsrf setMiddleSpacing $midSpc
$sltsrf setBeginLayers $i
$sltsrf setBeginRate $laySpcGR
$sltsrf setEndLayers $j
$sltsrf setEndRate $laySpcGR
$sl setDistribution 1 $sltsrf
$sl setSubConnectorDimensionFromDistribution 1

set up_dis [pw::DistributionGeneral create [list $wu 1]]
$up_dis setBeginSpacing $ler_sg
$up_dis setEndSpacing $ler_sg
$wu setDistribution 1 $up_dis

$wte setDimension $tpts2_sg

set low_dis [pw::DistributionGeneral create [list $wl 1]]
$low_dis setBeginSpacing $ler_sg
$low_dis setEndSpacing [expr $ler_sg*5]
$wl setDistribution 1 $low_dis
[$wl getDistribution 1] reverse

set cov_dis [pw::DistributionGeneral create [list $wc 1]]
$cov_dis setBeginSpacing $ler_sg
$cov_dis setEndSpacing [expr $ler_sg*5]
$wc setDistribution 1 $cov_dis

set upf_dis [pw::DistributionGeneral create [list $fu 1]]
$upf_dis setBeginSpacing $ler_sg
$upf_dis setEndSpacing $ler_sg
$fu setDistribution 1 $upf_dis

$fte setDimension $tpts2_sg

$ste setDimension $tpts1_sg

#matching
set con_alsp [$wl split [$wl getParameter -closest {0.08 0.0 0.0}]]
[lindex $con_alsp 0] setDimension [$sl getDimension]
set reg2_b3c [pw::DistributionGeneral create [list $sl]]
$reg2_b3c setBeginSpacing 0
$reg2_b3c setEndSpacing 0
$reg2_b3c setVariable [[[lindex $con_alsp 0] getDistribution 1] getVariable]
[lindex $con_alsp 0] setDistribution -lockEnds 1 $reg2_b3c
[[lindex $con_alsp 0] getDistribution 1] setBeginSpacing $ler_sg
[[lindex $con_alsp 0] getDistribution 1] setEndSpacing $ter_sg

set lowsrf0 [pw::DistributionGrowth create]
$lowsrf0 setBeginSpacing $ter_sg
$lowsrf0 setEndSpacing $ler_sg
set laySpcBegin $ler_sg
set laySpcEnd [expr $ler_sg*5]

set midSpc [expr 100*$chord_sg]
set laySpcGR $srfgrwl

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$lowsrf0 setMiddleMode ContinueGrowth
$lowsrf0 setMiddleSpacing $midSpc
$lowsrf0 setBeginLayers $i
$lowsrf0 setBeginRate $laySpcGR
$lowsrf0 setEndLayers $j
$lowsrf0 setEndRate $laySpcGR
[lindex $con_alsp 1] setDistribution 1 $lowsrf0
[lindex $con_alsp 1] setSubConnectorDimensionFromDistribution 1

set reg2_b3c2 [pw::DistributionGeneral create [list $sl]]
$reg2_b3c2 setBeginSpacing 0
$reg2_b3c2 setEndSpacing 0
$reg2_b3c2 setVariable [[[lindex $con_alsp 1] getDistribution 1] getVariable]
[lindex $con_alsp 1] setDistribution -lockEnds 1 $reg2_b3c2
[[lindex $con_alsp 1] getDistribution 1] setBeginSpacing $ter_sg
[[lindex $con_alsp 1] getDistribution 1] setEndSpacing [expr $ler_sg*5]

#airfoil BL extrusion
set a_edge [pw::Edge createFromConnectors [list $wu [lindex $con_alsp 0] [lindex $con_alsp 1] $wc $wte]]
set a_dom [pw::DomainStructured create]
$a_dom addEdge $a_edge
set a_extrusion [pw::Application begin ExtrusionSolver [list $a_dom]]
$a_dom setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
$a_dom setExtrusionSolverAttribute NormalInitialStepSize $dsg
$a_dom setExtrusionSolverAttribute SpacingGrowthFactor $grg
$a_dom setExtrusionSolverAttribute NormalMaximumStepSize 0.0004
$a_dom setExtrusionSolverAttribute Mode NormalHyperbolic
$a_dom setExtrusionSolverAttribute StopAtHeight 0.005
$a_dom setExtrusionSolverAttribute NormalExplicitSmoothing $exp_sg
$a_dom setExtrusionSolverAttribute NormalImplicitSmoothing $imp_sg
$a_dom setExtrusionSolverAttribute NormalVolumeSmoothing $vol_sg
$a_extrusion run $stp_sg
$a_extrusion end

set susp [$su split [list [$su getParameter -arc 0.75]]]

#slat BL extrusion
set s_edge [pw::Edge createFromConnectors [list [lindex $susp 0] [lindex $susp 1] $sl $ste]]
set s_dom [pw::DomainStructured create]
$s_dom addEdge $s_edge
set s_extrusion [pw::Application begin ExtrusionSolver [list $s_dom]]
$s_dom setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
$s_dom setExtrusionSolverAttribute NormalInitialStepSize $dsg
$s_dom setExtrusionSolverAttribute SpacingGrowthFactor $grg
$s_dom setExtrusionSolverAttribute NormalMaximumStepSize 0.0004
$s_dom setExtrusionSolverAttribute Mode NormalHyperbolic
$s_dom setExtrusionSolverAttribute StopAtHeight 0.005
$s_dom setExtrusionSolverAttribute NormalExplicitSmoothing $exp_sg
$s_dom setExtrusionSolverAttribute NormalImplicitSmoothing $imp_sg
$s_dom setExtrusionSolverAttribute NormalVolumeSmoothing $vol_sg
$s_extrusion run $stp_sg
$s_extrusion end

set wexcon [[$a_dom getEdge 2] getConnector 1]
set con_flapsp [$fu split [$fu getParameter -closest [$wexcon getXYZ -arc 1]]]

[lindex $con_flapsp 1] setDimension [$wc getDimension]
set fuseg1 [pw::DistributionGeneral create [list $wc]]
$fuseg1 setBeginSpacing $ler_sg
$fuseg1 setEndSpacing [[lindex $con_flapsp 1] getAverageSpacing]
$fuseg1 setVariable [[[lindex $con_flapsp 1] getDistribution 1] getVariable]
[lindex $con_flapsp 1] setDistribution -lockEnds 1 $fuseg1

#flap
set upsrff1 [pw::DistributionGrowth create]
$upsrff1 setBeginSpacing $ler_sg
$upsrff1 setEndSpacing $ler_sg
set laySpcBegin $ler_sg
set laySpcEnd $ler_sg

set midSpc [expr 100*$chord_sg]
set laySpcGR $srfgrfu

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$upsrff1 setMiddleMode ContinueGrowth
$upsrff1 setMiddleSpacing $midSpc
$upsrff1 setBeginLayers $i
$upsrff1 setBeginRate $laySpcGR
$upsrff1 setEndLayers $j
$upsrff1 setEndRate $laySpcGR
[lindex $con_flapsp 0] setDistribution 1 $upsrff1
[lindex $con_flapsp 0] setSubConnectorDimensionFromDistribution 1

set fusp [[lindex $con_flapsp 0] split [list [[lindex $con_flapsp 0] getParameter -arc 0.0032]]]

set lowsrff [pw::DistributionGrowth create]
$lowsrff setBeginSpacing [[lindex $con_flapsp 1] getAverageSpacing]
$lowsrff setEndSpacing $ler_sg
set laySpcBegin [[lindex $con_flapsp 1] getAverageSpacing]
set laySpcEnd $ter_sg

set midSpc [expr 100*$chord_sg]
set laySpcGR $srfgrfu

for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
	set laySpcBegin [expr $laySpcBegin*$laySpcGR]
}

for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
	set laySpcEnd [expr $laySpcEnd*$laySpcGR]
}

$lowsrff setMiddleMode ContinueGrowth
$lowsrff setMiddleSpacing $midSpc
$lowsrff setBeginLayers $i
$lowsrff setBeginRate $laySpcGR
$lowsrff setEndLayers $j
$lowsrff setEndRate $laySpcGR
$fl setDistribution 1 $lowsrff
$fl setSubConnectorDimensionFromDistribution 1

set flsp [$fl split -I [expr [$fl getDimension] - [[lindex $fusp 0] getDimension] + 1]]

#flap extrusion
set f_edge [pw::Edge createFromConnectors [list [lindex $fusp 0] [lindex $fusp 1] [lindex $con_flapsp 1] [lindex $flsp 0] [lindex $flsp 1] $fte]]
set f_dom [pw::DomainStructured create]
$f_dom addEdge $f_edge
set f_extrusion [pw::Application begin ExtrusionSolver [list $f_dom]]
$f_dom setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
$f_dom setExtrusionSolverAttribute NormalInitialStepSize $dsg
$f_dom setExtrusionSolverAttribute SpacingGrowthFactor $grg
$f_dom setExtrusionSolverAttribute NormalMaximumStepSize 0.0004
$f_dom setExtrusionSolverAttribute Mode NormalHyperbolic
$f_dom setExtrusionSolverAttribute StopAtHeight 0.005
$f_dom setExtrusionSolverAttribute NormalExplicitSmoothing $exp_sg
$f_dom setExtrusionSolverAttribute NormalImplicitSmoothing $imp_sg
$f_dom setExtrusionSolverAttribute NormalVolumeSmoothing $vol_sg
$f_extrusion run $stp_sg
$f_extrusion end

set wcon [[$a_dom getEdge 3] getConnector 1]
set wconsp [$wcon split -I [list [expr [$wcon getDimension]-$tpts2_sg+1] [expr [$wcon getDimension]-$tpts2_sg-[$wu getDimension]+2]\
					[$wc getDimension]]]
set wc [lindex $wconsp 0]
set wl [lindex $wconsp 1]
set wu [lindex $wconsp 2]
set wte [lindex $wconsp 3]

set scon [[$s_dom getEdge 3] getConnector 1]
set sconsp [$scon split -I [list [[lindex $susp 1] getDimension] [expr [[lindex $susp 1] getDimension] + [[lindex $susp 0] getDimension]-1]\
			[expr [[lindex $susp 1] getDimension] + [[lindex $susp 0] getDimension] + $tpts1_sg -2]]]
set ste [lindex $sconsp 2]
set sl [lindex $sconsp 3]
set su [lindex $sconsp 1]
set sle [lindex $sconsp 0]

set fcon [[$f_dom getEdge 3] getConnector 1]
set fconsp [$fcon split -I [list [expr [$fcon getDimension]-$tpts2_sg+1]\
	[expr [$fcon getDimension]-[[lindex $fusp 1] getDimension]-[[lindex $fusp 0] getDimension]-[[lindex $con_flapsp 1] getDimension]-$tpts2_sg+4]]]
set fu [lindex $fconsp 1]
set fl [lindex $fconsp 0]
set fte [lindex $fconsp 2]

set ptA {0.88571221 0.30586792 0}
set ptB {0.77940487 -0.63194054 0}
set ptC {500.77940487 -5.63194054 0}
set ptD {500.77940487 -50.63194054 0}

set ptAs [[[lindex $sconsp 0] getNode Begin] getXYZ]
set ptBs {0.728742627189183 -0.22 0}
set ptDs {500.77940487 -40.25092185 0}

set ptAsu [[$su getNode End] getXYZ]
set ptBsu {0.85550659 0.134600874663324 0.0}
set ptCsu {500.77940487 -17.2149769207833 0.0}

set ptAsu2 [[$sl getNode Begin] getXYZ]
set ptBsu2 {0.85550659 0.094999364 0.0}
set ptCsu2 {500.77940487 -25.759813 0.0}

set ptAwu1 [[$wu getNode End] getXYZ]
set ptBwu1 {1.14149 -0.09484753 0.0}
set ptCwu1 {500.77940487 -30.296267 0.0}

set ptAwu2 [[$wc getNode Begin] getXYZ]
set ptBwu2 {1.1219531 -0.10870092 0.0}
set ptCwu2 {500.77940487 -34.8654388929955 0.0}

set con_seg [pw::SegmentConic create]
$con_seg addPoint $ptA
$con_seg addPoint $ptB
$con_seg setRho 0.3
$con_seg setShoulderPoint {-0.24874029 -0.041643586 0}
set con_con [pw::Connector create]
$con_con addSegment $con_seg

set conu_seg [pw::SegmentSpline create]
set conl_seg [pw::SegmentSpline create]
set cons_seg [pw::SegmentSpline create]
set consu_seg [pw::SegmentSpline create]
set consu2_seg [pw::SegmentSpline create]
set conwu1_seg [pw::SegmentSpline create]
set conwu2_seg [pw::SegmentSpline create]
set confu1_seg [pw::SegmentSpline create]
set confu2_seg [pw::SegmentSpline create]
set conwups [pw::SegmentSpline create]
set confups [pw::SegmentSpline create]

$conu_seg addPoint $ptA
$conu_seg addPoint $ptC
$conu_seg setSlope Free
$conu_seg setSlopeOut 1 {45 3 0}
$conu_seg setSlopeIn 2 {-167 -1.7 0}
set conu_con [pw::Connector create]
$conu_con addSegment $conu_seg

$conl_seg addPoint $ptB
$conl_seg addPoint $ptD
$conl_seg setSlope Free
$conl_seg setSlopeOut 1 {78.5 -22 0}
$conl_seg setSlopeIn 2 {-167 17 0}
set conl_con [pw::Connector create]
$conl_con addSegment $conl_seg

set con_conj [pw::Connector join [list $con_con $conl_con $conu_con]]
$con_conj removeAllBreakPoints

set con_consp [$con_conj split [list [$con_conj getParameter -arc 0.49847561] [$con_conj getParameter -arc 0.49866256]]]

set con_alsp [$wl split -I [list [expr [$wl getDimension] - [$sl getDimension]+1]]]

set con_flapsp [$fu split -I [list [$wc getDimension] ]]

set con_flsp [$fl split -I [[lindex $flsp 1] getDimension]]
set con_fusp [[lindex $con_flapsp 1] split -I [expr [[lindex $con_flapsp 1] getDimension] - [[lindex $fusp 0] getDimension] + 1]]

set ptAfu1 [[[lindex $con_fusp 1] getNode Begin] getXYZ]
set ptBfu1 {1.60191884390277 -0.375531959413752 0.0}
set ptCfu1 {500.77940487 -37.3547872468103 0.0}
set ptDfu1 { 1.1109934 -0.099161894 0.0}

set ptAfu2 [[[lindex $con_flsp 0] getNode End] getXYZ]
set ptBfu2 {1.23609367689048 -0.291353543166955 0.0}
set ptCfu2 {500.77940487 -39.0603268185674 0.0}

set reg1_seg1 [pw::SegmentSpline create]
$reg1_seg1 addPoint $ptAsu
$reg1_seg1 addPoint [[[lindex $con_consp 1] getNode Begin] getXYZ]
$reg1_seg1 setSlope Free
$reg1_seg1 setSlopeOut 1 {0.00028003821120525102 0.02684384864778316 0}
$reg1_seg1 setSlopeIn 2 {0.037098073008139776 -0.016074381487379531 0}
set reg1_con1 [pw::Connector create]
$reg1_con1 addSegment $reg1_seg1

set reg1_seg3 [pw::SegmentSpline create]
$reg1_seg3 addPoint [[$su getNode Begin] getXYZ]
$reg1_seg3 addPoint [[[lindex $con_consp 2] getNode Begin] getXYZ]
$reg1_seg3 setSlope Free
$reg1_seg3 setSlopeOut 1 {-0.030579007654961118 -0.020151477573753768 0}
$reg1_seg3 setSlopeIn 2 {0.070819637087692067 0.025425207590922511 0}
set reg1_con3 [pw::Connector create]
$reg1_con3 addSegment $reg1_seg3

set reg2_seg2 [pw::SegmentSpline create]
$reg2_seg2 addPoint [[$wu getNode Begin] getXYZ]
$reg2_seg2 addPoint $ptAsu2
$reg2_seg2 setSlope Free
$reg2_seg2 setSlopeOut 1 {-0.004512455948548915 0.001193482028081558 0}
$reg2_seg2 setSlopeIn 2 {0.0021718439174988786 0.00061682602282782861 0}
set reg2_con2 [pw::Connector create]
$reg2_con2 addSegment $reg2_seg2

set reg2_seg3 [pw::SegmentSpline create]
$reg2_seg3 addPoint [[[lindex $con_alsp 0] getNode End] getXYZ]
$reg2_seg3 addPoint $ptAs
$reg2_seg3 setSlope Free
$reg2_seg3 setSlopeOut 1 {-0.0082443748496585922 -0.036104390867539346 0}
$reg2_seg3 setSlopeIn 2 {0.021024602933046796 0.032170920390927164 0}
set reg2_con3 [pw::Connector create]
$reg2_con3 addSegment $reg2_seg3

set reg3_seg1 [pw::SegmentSpline create]
$reg3_seg1 addPoint [[[lindex $con_flapsp 1] getNode End] getXYZ]
$reg3_seg1 addPoint $ptDfu1
$reg3_seg1 setSlope Free
$reg3_seg1 setSlopeOut 1 {0.013385311179039405 0.0039214879376518463 0}
$reg3_seg1 setSlopeIn 2 {-0.010822518001545101 -0.0116094778673662 0}
set reg3_con1 [pw::Connector create]
$reg3_con1 addSegment $reg3_seg1

set reg3_seg2 [pw::SegmentSpline create]
$reg3_seg2 addPoint [[[lindex $con_flapsp 0] getNode End] getXYZ]
$reg3_seg2 addPoint $ptAwu2
$reg3_seg2 setSlope Free
$reg3_seg2 setSlopeOut 1 {-0.00013204093405483341 0.0029775187070013344 0}
$reg3_seg2 setSlopeIn 2 {0.0012119499756009233 -0.0012885473263002239 0}
set reg3_con2 [pw::Connector create]
$reg3_con2 addSegment $reg3_seg2

set reg2_seg4 [pw::SegmentSpline create]
$reg2_seg4 addPoint $ptAs
$reg2_seg4 addPoint {0.182078184753842 -0.154042771909779 0}
$reg2_seg4 setSlope Free
$reg2_seg4 setSlopeOut 1 {0.040572631328093578 0.00050582301756901815 0}
$reg2_seg4 setSlopeIn 2 {-0.093429937604193394 0.019757455368251992 0}
set reg2_con4 [pw::Connector create]
$reg2_con4 addSegment $reg2_seg4

set conlowsp [[lindex $con_consp 2] split [list [[lindex $con_consp 2] getParameter -closest [[$reg2_con4 getNode End] getXYZ]]]]

set conupsp [[lindex $con_alsp 0] split -I [list [lindex [[lindex $con_alsp 0] closestCoordinate [$reg2_con4 getPosition -arc 1]] 0] ]]

set reg1_seg4 [pw::SegmentSpline create]
$reg1_seg4 addPoint [[[lindex $conupsp 1] getNode Begin] getXYZ]
$reg1_seg4 addPoint [[$reg2_con4 getNode End] getXYZ]
$reg1_seg4 addPoint [[[lindex $conlowsp 0] getNode End] getXYZ]
$reg1_seg4 setSlope Free
$reg1_seg4 setSlopeOut 1 {0.0018776472493075291 -0.030436883048756767 0}
$reg1_seg4 setSlopeIn 2 {0.0097246552739590209 0.026447732700055002 0}
$reg1_seg4 setSlopeOut 2 {-0.0097246552739589931 -0.026447732700054988 0}
$reg1_seg4 setSlopeIn 3 {0.050731978220743108 0.068518000192601791 0}
set reg1_con4 [pw::Connector create]
$reg1_con4 addSegment $reg1_seg4

set reg1_con1sp [$reg1_con4 split [$reg1_con4 getParameter -closest [[$reg2_con4 getNode End] getXYZ]]]
