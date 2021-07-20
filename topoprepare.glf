# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

proc Topo_Prep_Mesh { } {
	
	global chord_sg ler_sg srfgr srfgrwl srfgrfu r1c1gr r2c3gr r3c1gr tpts2_sg tpts1_sg ter_sg dsg grg exp_sg imp_sg vol_sg stp_sg
	global doms adjdoms adjbcs fixdoms fixbcs conu_tail con_consp conl_tail conlowspsp texrv
	global dom_blk3 blk4 blk5 blk33 r3_blk4 blk322 r3_blk3 blk31 blk321 r1_blk2 blk3 blk1 blk12sp blk2 blk22 domexm
	global confu2_con wu su con_fusp
	global bldoms conslatbc domslatbc conwingbc domwingbc conflapbc domflapbc confarbc domfarbc ncells

	upvar 1 HO_GEN hopara
	upvar 1 GRD_TYP grid_type
	upvar 1 res_lev reflev
	
	set domexm [pw::Examine create DomainArea]
	set ncells []
	set doms []
	set adjdoms []
	set adjbcs []
	set fixdoms []
	set fixbcs []
	
	set bldoms []
	
	#CAE Boundary Condition
	set conslatbc []
	set domslatbc []
	set conwingbc []
	set domwingbc []
	set conflapbc []
	set domflapbc []
	set confarbc []
	set domfarbc []

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

	set midSpc [expr 5*$chord_sg]
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

	set midSpc [expr 5*$chord_sg]
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

	set midSpc [expr 5*$chord_sg]
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
	set laySpcEnd2 [expr $ler_sg/5]

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
	$sltsrfu2 setEndSpacing [expr $ler_sg/5]

	$su setDimensionFromDistribution

	set susp [$su split [list [$su getParameter -arc 0.992]]]

	#slat low
	set sltsrf [pw::DistributionGrowth create]
	$sltsrf setBeginSpacing $ler_sg
	$sltsrf setEndSpacing [expr $ler_sg/5]
	set laySpcBegin $ler_sg
	set laySpcEnd [expr $ler_sg/5]

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

	set wcendSpc [pw::Examine create ConnectorEdgeLength]
	$wcendSpc addEntity $wc
	$wcendSpc examine
	set wcfv [$wcendSpc getValue $wc [expr [$wc getDimension]-1]]

	set upf_dis [pw::DistributionGeneral create [list $fu 1]]
	$upf_dis setBeginSpacing $ler_sg
	$upf_dis setEndSpacing $ler_sg
	$fu setDistribution 1 $upf_dis

	$fte setDimension $tpts2_sg

	$ste setDimension $tpts1_sg

	pw::Entity project -type ClosestPoint $ste [lindex $alldegs 1]

	pw::Entity project -type ClosestPoint $sl [lindex $alldegs 10]

	set slatlow_sp [$sl split -I [list [expr [$sl getDimension]-[[lindex $susp 1] getDimension]+1]]]

	set sl [lindex $slatlow_sp 0]
	set sl_edge [lindex $slatlow_sp 1]

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
	$lowsrf0 setEndSpacing [expr $ter_sg/2]
	set laySpcBegin $ter_sg
	set laySpcEnd [expr $ter_sg/2]

	set midSpc [expr 5*$chord_sg]
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

	set con_alsp_sp [[lindex $con_alsp 1] split -I [list [lindex [[lindex $con_alsp 1] closestCoordinate [[lindex $con_alsp 1] getPosition -arc 0.9975]] 0]]]

	if {[string compare $hopara YES]==0} {
		set maxGRextr 0.0
	} else {
		set maxGRextr 0.0004
	}

	#airfoil BL extrusion
	set a_edge [pw::Edge createFromConnectors [list $wu [lindex $con_alsp 0] [lindex $con_alsp_sp 1] [lindex $con_alsp_sp 0] $wc $wte]]
	set a_dom [pw::DomainStructured create]
	$a_dom addEdge $a_edge
	set a_extrusion [pw::Application begin ExtrusionSolver [list $a_dom]]
	$a_dom setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
	$a_dom setExtrusionSolverAttribute NormalInitialStepSize $dsg
	$a_dom setExtrusionSolverAttribute SpacingGrowthFactor $grg
	$a_dom setExtrusionSolverAttribute NormalMaximumStepSize $maxGRextr
	$a_dom setExtrusionSolverAttribute Mode NormalHyperbolic
	$a_dom setExtrusionSolverAttribute StopAtHeight 0.005
	$a_dom setExtrusionSolverAttribute NormalExplicitSmoothing $exp_sg
	$a_dom setExtrusionSolverAttribute NormalImplicitSmoothing $imp_sg
	$a_dom setExtrusionSolverAttribute NormalVolumeSmoothing $vol_sg
	$a_extrusion run $stp_sg
	$a_extrusion end

	set conwingbc [list $wte $wu [lindex $con_alsp 0] [lindex $con_alsp_sp 0] [lindex $con_alsp_sp 1] $wc]

	#slat BL extrusion
	set s_edge [pw::Edge createFromConnectors [list $ste $sl $sl_edge [lindex $susp 0] [lindex $susp 1]]]
	set s_dom [pw::DomainStructured create]
	$s_dom addEdge $s_edge
	set s_extrusion [pw::Application begin ExtrusionSolver [list $s_dom]]
	$s_dom setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
	$s_dom setExtrusionSolverAttribute NormalInitialStepSize $dsg
	$s_dom setExtrusionSolverAttribute SpacingGrowthFactor $grg
	$s_dom setExtrusionSolverAttribute NormalMaximumStepSize $maxGRextr
	$s_dom setExtrusionSolverAttribute Mode NormalHyperbolic
	$s_dom setExtrusionSolverAttribute StopAtHeight 0.005
	$s_dom setExtrusionSolverAttribute NormalExplicitSmoothing $exp_sg
	$s_dom setExtrusionSolverAttribute NormalImplicitSmoothing $imp_sg
	$s_dom setExtrusionSolverAttribute NormalVolumeSmoothing $vol_sg
	$s_extrusion run $stp_sg
	$s_extrusion end

	set conslatbc [list $ste $sl $sl_edge [lindex $susp 1] [lindex $susp 0]]

	set wexcon [[$a_dom getEdge 2] getConnector 1]
	set con_flapsp [$fu split [$fu getParameter -closest [$wexcon getXYZ -arc 1]]]

	[lindex $con_flapsp 1] setDimension [$wc getDimension]
	set fuseg1 [pw::DistributionGeneral create [list $wc]]
	$fuseg1 setBeginSpacing $ler_sg
	$fuseg1 setEndSpacing [expr $wcfv*2]
	$fuseg1 setVariable [[[lindex $con_flapsp 1] getDistribution 1] getVariable]
	[lindex $con_flapsp 1] setDistribution -lockEnds 1 $fuseg1

	set fupexamine [pw::Examine create ConnectorEdgeLength]
	$fupexamine addEntity [lindex $con_flapsp 1]
	$fupexamine examine
	set fupf [$fupexamine getValue [lindex $con_flapsp 1] [expr [[lindex $con_flapsp 1] getDimension]-1]]

	#flap
	set upsrff1 [pw::DistributionGrowth create]
	$upsrff1 setBeginSpacing $ler_sg
	$upsrff1 setEndSpacing $ler_sg
	set laySpcBegin $ler_sg
	set laySpcEnd $ler_sg

	set midSpc [expr 3*$chord_sg]
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
	$lowsrff setBeginSpacing [expr $fupf*2]
	$lowsrff setEndSpacing $ler_sg
	set laySpcBegin [expr $fupf*2]
	set laySpcEnd $ler_sg

	set midSpc [expr 3*$chord_sg]
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
	$f_dom setExtrusionSolverAttribute NormalMaximumStepSize $maxGRextr
	$f_dom setExtrusionSolverAttribute Mode NormalHyperbolic
	$f_dom setExtrusionSolverAttribute StopAtHeight 0.005
	$f_dom setExtrusionSolverAttribute NormalExplicitSmoothing $exp_sg
	$f_dom setExtrusionSolverAttribute NormalImplicitSmoothing $imp_sg
	$f_dom setExtrusionSolverAttribute NormalVolumeSmoothing $vol_sg
	$f_extrusion run $stp_sg
	$f_extrusion end

	set conflapbc [list $fte [lindex $fusp 0] [lindex $fusp 1] [lindex $con_flapsp 1] [lindex $flsp 0] [lindex $flsp 1]]

	set wcon [[$a_dom getEdge 3] getConnector 1]
	set wconsp [$wcon split -I [list [expr [$wcon getDimension]-$tpts2_sg+1] [expr [$wcon getDimension]-$tpts2_sg-[$wu getDimension]+2]\
						[$wc getDimension]]]
	set wc [lindex $wconsp 0]
	set wl [lindex $wconsp 1]
	set wu [lindex $wconsp 2]
	set wte [lindex $wconsp 3]

	set scon [[$s_dom getEdge 3] getConnector 1]
	set sconsp [$scon split -I [list [$sl getDimension] [expr [$sl getDimension] + [$sl_edge getDimension]-1]\
				 [expr [$sl getDimension] + [$sl_edge getDimension] + [[lindex $susp 1] getDimension] -2]\
					 [expr [$sl getDimension] + [$sl_edge getDimension] + [[lindex $susp 1] getDimension] + [[lindex $susp 0] getSubConnectorDimension 2] -3]\
					 [expr [$sl getDimension] + [$sl_edge getDimension] + [[lindex $susp 1] getDimension] + [[lindex $susp 0] getDimension] -3]]]
	set sl [lindex $sconsp 0]
	set sledg [lindex $sconsp 1]
	set suedg [lindex $sconsp 2]
	set sle [lindex $sconsp 3]
	set su [lindex $sconsp 4]
	set ste [lindex $sconsp 5]

	set fcon [[$f_dom getEdge 3] getConnector 1]
	set fconsp [$fcon split -I [list [expr [$fcon getDimension]-$tpts2_sg+1]\
		[expr [$fcon getDimension]-[[lindex $fusp 1] getDimension]-[[lindex $fusp 0] getDimension]-[[lindex $con_flapsp 1] getDimension]-$tpts2_sg+4]]]
	set fu [lindex $fconsp 1]
	set fl [lindex $fconsp 0]
	set fte [lindex $fconsp 2]

	set xdownstream 7000
	set ptA {0.88571221 0.30586792 0}
	set ptB {0.77940487 -0.63194054 0}
	set ptC [list $xdownstream {*}{-5.63194054 0}]
	set ptD [list $xdownstream {*}{-50.63194054 0}]

	set ptAs [[[lindex $sconsp 0] getNode Begin] getXYZ]
	set ptAAs [[$sl getNode End] getXYZ]
	set ptAAAs [[$sledg getNode End] getXYZ]
	set ptBs {0.728742627189183 -0.22 0}
	set ptDs [list $xdownstream {*}{-40.25092185 0}]

	set ptAsu [[$su getNode End] getXYZ]
	set ptBsu {0.85550659 0.134600874663324 0.0}
	set ptCsu [list $xdownstream {*}{-17.2149769207833 0.0}]

	set ptAsu2 [[$sl getNode Begin] getXYZ]
	set ptBsu2 {0.85550659 0.094999364 0.0}
	set ptCsu2 [list $xdownstream {*}{-25.759813 0.0}]

	set ptAwu1 [[$wu getNode End] getXYZ]
	set ptBwu1 {1.14149 -0.09484753 0.0}
	set ptCwu1 [list $xdownstream {*}{-30.296267 0.0}]

	set ptAwu2 [[$wc getNode Begin] getXYZ]
	set ptBwu2 {1.1219531 -0.10870092 0.0}
	set ptCwu2 [list $xdownstream {*}{-34.8654388929955 0.0}]

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

	set con_consp [$con_conj split [list [$con_conj getParameter -closest {-0.20732979 0.048201124 -2.7755576e-17}] [$con_conj getParameter -closest {-0.23401671 -0.12687592 0.0}]]]

	set con_alsp [$wl split -I [list [expr [$wl getDimension] - [$sl getDimension] +1]]]

	set con_flapsp [$fu split -I [list [$wc getDimension] ]]

	set con_flsp [$fl split -I [[lindex $flsp 1] getDimension]]
	set con_fusp [[lindex $con_flapsp 1] split -I [expr [[lindex $con_flapsp 1] getDimension] - [[lindex $fusp 0] getDimension] + 1]]

	set ptAfu1 [[[lindex $con_fusp 1] getNode Begin] getXYZ]
	set ptBfu1 {1.60191884390277 -0.375531959413752 0.0}
	set ptCfu1 {$xdownstream -37.3547872468103 0.0}
	set ptDfu1 { 1.1109934 -0.099161894 0.0}

	set ptAfu2 [[[lindex $con_flsp 0] getNode End] getXYZ]
	set ptBfu2 {1.23609367689048 -0.291353543166955 0.0}
	set ptCfu2 {$xdownstream -39.0603268185674 0.0}

	set reg1_seg1 [pw::SegmentSpline create]
	$reg1_seg1 addPoint $ptAsu
	$reg1_seg1 addPoint [[[lindex $con_consp 1] getNode Begin] getXYZ]
	$reg1_seg1 setSlope Free
	$reg1_seg1 setSlopeOut 1 {0.00028003821120518857 0.026843848647783202 0}
	$reg1_seg1 setSlopeIn 2 {0.013191584685044888 -0.022679380051977963 0}
	set reg1_con1 [pw::Connector create]
	$reg1_con1 addSegment $reg1_seg1

	set reg1_seg3 [pw::SegmentSpline create]
	$reg1_seg3 addPoint [[$su getNode Begin] getXYZ]
	$reg1_seg3 addPoint [[[lindex $con_consp 2] getNode Begin] getXYZ]
	$reg1_seg3 setSlope Free
	$reg1_seg3 setSlopeOut 1 {-0.025995484382943079 -0.024638410649165776 0}
	$reg1_seg3 setSlopeIn 2 {0.054057496843488484 0.037097650635995488 0}
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
	$reg2_seg3 addPoint $ptAAs
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
	$reg2_seg4 addPoint $ptAAAs
	$reg2_seg4 addPoint {0.182078184753842 -0.154042771909779 0}
	$reg2_seg4 setSlope Free
	$reg2_seg4 setSlopeOut 1 {0.040572631328093578 0.00050582301756901815 0}
	$reg2_seg4 setSlopeIn 2 {-0.093429937604193394 0.019757455368251992 0}
	set reg2_con4 [pw::Connector create]
	$reg2_con4 addSegment $reg2_seg4

	set conlowsp [[lindex $con_consp 2] split [list [[lindex $con_consp 2] getParameter -closest [[$reg2_con4 getNode End] getXYZ]]]]

	set conupsp [[lindex $con_alsp 0] split -I [list [lindex [[lindex $con_alsp 0] closestCoordinate [$reg2_con4 getPosition -arc 1]] 0]\
						 									[[lindex $con_alsp_sp 1] getDimension]]]

	set reg1_seg4 [pw::SegmentSpline create]
	$reg1_seg4 addPoint [[[lindex $conupsp 1] getNode End] getXYZ]
	$reg1_seg4 addPoint [[$reg2_con4 getNode End] getXYZ]
	$reg1_seg4 addPoint [[[lindex $conlowsp 0] getNode End] getXYZ]
	$reg1_seg4 setSlope Free
	$reg1_seg4 setSlopeOut 1 {0.0018776472493075291 -0.030436883048756767 0}
	$reg1_seg4 setSlopeIn 2 {0.0097246552739590209 0.026447732700055002 0}
	$reg1_seg4 setSlopeOut 2 {-0.0097246552739589931 -0.026447732700054988 0}
	$reg1_seg4 setSlopeIn 3 {0.050731978220743108 0.068518000192601791 0}
	set reg1_con4 [pw::Connector create]
	$reg1_con4 addSegment $reg1_seg4

	$reg2_con4 delete

	set conlowspsp [[lindex $conlowsp 0] split [[lindex $conlowsp 0] getParameter -arc 0.41]]

	set reg1_seg5 [pw::SegmentSpline create]
	$reg1_seg5 addPoint [[$sle getNode Begin] getXYZ]
	$reg1_seg5 addPoint [[[lindex $conlowspsp 0] getNode End] getXYZ]
	$reg1_seg5 setSlope Free
	$reg1_seg5 setSlopeOut 1 {0.0013509262461380584 -0.024687772260316904 0}
	$reg1_seg5 setSlopeIn 2 {0.054849943959117561 0.049915701087925424 0}
	set reg1_con5 [pw::Connector create]
	$reg1_con5 addSegment $reg1_seg5

	# MESHING

	# Boundary blocks division:
	#----------------------------------------------------------------------------
	set a_domsp [$a_dom split -I [list [$wte getDimension] [expr [$wu getDimension]+[$wte getDimension]-1]\
			 [expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]-2]\
				 [expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]+[[lindex $conupsp 2] getDimension]+\
					[[lindex $conupsp 1] getDimension]-4] [expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]\
					+[[lindex $conupsp 2] getDimension]+[[lindex $conupsp 1] getDimension]+[[lindex $conupsp 0] getDimension]-5]]]

	set domwingbc [list [lindex $a_domsp 0] [lindex $a_domsp 1] [lindex $a_domsp 2] [lindex $a_domsp 3] [lindex $a_domsp 4] [lindex $a_domsp 5]]

	set s_domsp [$s_dom split -I [list [$ste getDimension] [expr [$ste getDimension]+[$su getDimension]+[$sle getDimension]-2]\
							 [expr [$ste getDimension]+[$su getDimension]+[$sle getDimension]+[$suedg getDimension]-3]\
								 [expr [$ste getDimension]+[$su getDimension]+[$sle getDimension]+[$suedg getDimension]+[$sledg getDimension]-4] ]]

	$domexm addEntity [lindex $s_domsp 0]
	lappend ncells [[lindex $s_domsp 0] getCellCount]
	lappend bldoms [lindex $s_domsp 0]

	$domexm addEntity [lindex $s_domsp 1]
	lappend ncells [[lindex $s_domsp 1] getCellCount]
	lappend bldoms [lindex $s_domsp 1]

	$domexm addEntity [lindex $s_domsp 2]
	lappend ncells [[lindex $s_domsp 2] getCellCount]
	lappend bldoms [lindex $s_domsp 2]

	$domexm addEntity [lindex $s_domsp 3]
	lappend ncells [[lindex $s_domsp 3] getCellCount]
	lappend bldoms [lindex $s_domsp 3]

	$domexm addEntity [lindex $s_domsp 4]
	lappend ncells [[lindex $s_domsp 4] getCellCount]
	lappend bldoms [lindex $s_domsp 4]

	set domslatbc [list [lindex $s_domsp 0] [lindex $s_domsp 4] [lindex $s_domsp 3] [lindex $s_domsp 2] [lindex $s_domsp 1]]

	set f_domsp [$f_dom split -I [list [$fte getDimension] [expr [$fte getDimension]+[[lindex $con_fusp 1] getDimension]-1]\
		[expr [$fte getDimension]+[[lindex $con_fusp 0] getDimension]+[[lindex $con_fusp 1] getDimension] - 2]\
		[expr [$fte getDimension]+[[lindex $con_fusp 0] getDimension]+[[lindex $con_fusp 1] getDimension]+[[lindex $con_flapsp 0] getDimension]-3]\
		[expr [$fte getDimension]+[[lindex $con_fusp 0] getDimension]+[[lindex $con_fusp 1] getDimension]+[[lindex $con_flapsp 0] getDimension]+\
								[[lindex $con_flsp 1] getDimension]-4]]]

	$domexm addEntity [lindex $f_domsp 0]
	lappend ncells [[lindex $f_domsp 0] getCellCount]
	lappend bldoms [lindex $f_domsp 0]

	$domexm addEntity [lindex $f_domsp 1]
	lappend ncells [[lindex $f_domsp 1] getCellCount]
	lappend bldoms [lindex $f_domsp 1]

	$domexm addEntity [lindex $f_domsp 2]
	lappend ncells [[lindex $f_domsp 2] getCellCount]
	lappend bldoms [lindex $f_domsp 2]

	$domexm addEntity [lindex $f_domsp 3]
	lappend ncells [[lindex $f_domsp 3] getCellCount]
	lappend bldoms [lindex $f_domsp 3]

	$domexm addEntity [lindex $f_domsp 4]
	lappend ncells [[lindex $f_domsp 4] getCellCount]
	lappend bldoms [lindex $f_domsp 4]

	$domexm addEntity [lindex $f_domsp 5]
	lappend ncells [[lindex $f_domsp 5] getCellCount]
	lappend bldoms [lindex $f_domsp 5]

	set domflapbc [list [lindex $f_domsp 0] [lindex $f_domsp 1] [lindex $f_domsp 2] [lindex $f_domsp 3] [lindex $f_domsp 4] [lindex $f_domsp 5]]

	set wte1cs [[[lindex $a_domsp 0] getEdge 2] getConnector 1]
	set wte2cs $wexcon
	set wucs [[[lindex $a_domsp 1] getEdge 2] getConnector 1]
	set wlcs [[[lindex $a_domsp 2] getEdge 2] getConnector 1]
	set wccs [[[lindex $a_domsp 3] getEdge 2] getConnector 1]

	set stulcs [[[lindex $s_domsp 2] getEdge 2] getConnector 1]
	set ste1cs [[[lindex $s_domsp 0] getEdge 4] getConnector 1]
	set ste2cs [[[lindex $s_domsp 0] getEdge 2] getConnector 1]

	set fte2cs [[[lindex $f_domsp 1] getEdge 2] getConnector 1]
	set fte1cs [[[lindex $f_domsp 5] getEdge 4] getConnector 1]
	set ftlu1cs [[[lindex $f_domsp 1] getEdge 2] getConnector 1]
	set ftlu2cs [[[lindex $f_domsp 2] getEdge 2] getConnector 1]

	#=======================================================REGION 1======================================

	# ./1 blk 2 Region 1
	#-----------------
	[lindex $con_consp 1] setDimension [$su getDimension]

	set reg1_b2c1 [pw::DistributionGeneral create [list $su 1]]
	$reg1_b2c1 setBeginSpacing 0
	$reg1_b2c1 setEndSpacing 0
	$reg1_b2c1 setVariable [[[lindex $con_consp 1] getDistribution 1] getVariable]
	[lindex $con_consp 1] setDistribution -lockEnds 1 $reg1_b2c1
	[[lindex $con_consp 1] getDistribution 1] reverse

	set reg1c1s [pw::Examine create ConnectorEdgeLength]
	$reg1c1s addEntity $ste1cs
	$reg1c1s examine
	set reg1c1sv [$reg1c1s getMaximum]

	set reg1_b2v1 [pw::DistributionGrowth create]
	$reg1_b2v1 setBeginSpacing $reg1c1sv
	set laySpcBegin $reg1c1sv

	set maxedgeln [pw::Examine create ConnectorEdgeLength]
	$maxedgeln addEntity $su
	$maxedgeln examine
	set midSpc [expr [$maxedgeln getMaximum]]
	set laySpcGR $r1c1gr


	for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
		set laySpcBegin [expr $laySpcBegin*$laySpcGR]
	}

	$reg1_b2v1 setMiddleMode ContinueGrowth
	$reg1_b2v1 setMiddleSpacing $midSpc
	$reg1_b2v1 setBeginLayers $i
	$reg1_b2v1 setBeginRate $laySpcGR
	$reg1_con1 setDistribution 1 $reg1_b2v1
	$reg1_con1 setSubConnectorDimensionFromDistribution 1

	set texr [pw::Examine create ConnectorEdgeLength]
	$texr addEntity $reg1_con1
	$texr examine
	set texrv [$texr getValue $reg1_con1 [expr [$reg1_con1 getDimension]-1]]

	$reg1_con3 setDimension [$reg1_con1 getDimension]
	$reg1_con3 setDistribution 1 [[$reg1_con1 getDistribution 1] copy]
	set reg1_b2c3 [pw::DistributionGeneral create [list $reg1_con1 1]]
	$reg1_b2c3 setBeginSpacing 0
	$reg1_b2c3 setEndSpacing 0
	$reg1_b2c3 setVariable [[$reg1_con3 getDistribution 1] getVariable]
	$reg1_con3 setDistribution -lockEnds 1 $reg1_b2c3

	set reg1c3s [pw::Examine create ConnectorEdgeLength]
	$reg1c3s addEntity $stulcs
	$reg1c3s examine
	set reg1c3sv [$reg1c3s getMaximum]

	[$reg1_con3 getDistribution 1] setBeginSpacing $reg1c3sv
	[$reg1_con3 getDistribution 1] setEndSpacing $texrv

	# 1. DOM OVER SLAT
	set r1_blk2 [pw::DomainStructured createFromConnectors [list [lindex $con_consp 1] $reg1_con1 $su $reg1_con3]]
	lappend doms $r1_blk2
	lappend adjdoms $r1_blk2
	lappend adjdoms $r1_blk2
	lappend adjbcs 2
	lappend adjbcs 4

	#=======================================================REGION 2======================================

	set r2c2start [pw::Examine create ConnectorEdgeLength]
	$r2c2start addEntity $wucs
	$r2c2start examine
	set r2c2s [$r2c2start getMaximum]

	set r2c2end [pw::Examine create ConnectorEdgeLength]
	$r2c2end addEntity $ste2cs
	$r2c2end examine
	set r2c2e [$r2c2end getMaximum]


	# ./2 blk 3 Region 2
	#-----------------

	set r3v2start [pw::Examine create ConnectorEdgeLength]
	$r3v2start addEntity $wte
	$r3v2start examine
	set r3v2s [$r3v2start getMaximum]

	set r2c3start [pw::Examine create ConnectorEdgeLength]
	$r2c3start addEntity $wlcs
	$r2c3start examine
	set r2c3s [$r2c3start getMaximum]

	set r2c3end [pw::Examine create ConnectorEdgeLength]
	$r2c3end addEntity $stulcs
	$r2c3end examine
	set r2c3e [$r2c3end getMaximum]

	set reg2c3spc [pw::DistributionGrowth create]
	$reg2c3spc setBeginSpacing $r2c3s
	$reg2c3spc setEndSpacing $r2c3e
	set laySpcBegin $r2c3s
	set laySpcEnd $r2c3e

	set midSpc [expr $chord_sg]
	set laySpcGR1 $r2c3gr
	set laySpcGR2 $r2c3gr

	for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
		set laySpcBegin [expr $laySpcBegin*$laySpcGR]
	}

	for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
		set laySpcEnd [expr $laySpcEnd*$laySpcGR]
	}

	$reg2c3spc setMiddleMode ContinueGrowth
	$reg2c3spc setMiddleSpacing $midSpc
	$reg2c3spc setBeginLayers $i
	$reg2c3spc setBeginRate $laySpcGR1
	$reg2c3spc setEndLayers $j
	$reg2c3spc setEndRate $laySpcGR2
	$reg2_con3 setDistribution 1 $reg2c3spc
	$reg2_con3 setSubConnectorDimensionFromDistribution 1

	[$reg2_con3 getDistribution 1] setBeginSpacing $r2c3s
	[$reg2_con3 getDistribution 1] setEndSpacing $r2c3e

	$reg2_con2 setDimension [$reg2_con3 getDimension]
	[$reg2_con2 getDistribution 1] setBeginSpacing $r3v2s
	[$reg2_con2 getDistribution 1] setEndSpacing $r2c2e

	# 2. BTW WING AND SLAT
	set dom_blk3 [pw::DomainStructured createFromConnectors [list [lindex $con_alsp 1] $reg2_con3 $sl $reg2_con2]]
	$domexm addEntity $dom_blk3
	if {[string compare $grid_type STR]==0} {
		lappend ncells [$dom_blk3 getCellCount]
	}
	lappend doms $dom_blk3
	lappend adjdoms $dom_blk3
	lappend fixdoms $dom_blk3
	lappend adjbcs 4
	lappend fixbcs 2

	#=====================================================REGION 3===================================

	set r3v1start [pw::Examine create ConnectorEdgeLength]
	$r3v1start addEntity $fte1cs
	$r3v1start examine
	set r3v1s [$r3v1start getMaximum]

	set r3v2end [pw::Examine create ConnectorEdgeLength]
	$r3v2end addEntity $ftlu2cs
	$r3v2end examine
	set r3v2e [$r3v2end getMaximum]

	set r3v3start [pw::Examine create ConnectorEdgeLength]
	$r3v3start addEntity [lindex $con_flsp 1]
	$r3v3start examine
	set r3v3s [$r3v3start getValue [lindex $con_flsp 1] [expr [[lindex $con_flsp 1] getDimension]-1]]

	set reg3_b2v1 [pw::DistributionGrowth create]
	$reg3_b2v1 setBeginSpacing $r3v3s
	set laySpcBegin $r3v3s

	set maxedgeln [pw::Examine create ConnectorEdgeLength]
	$maxedgeln addEntity [lindex $con_fusp 0]
	$maxedgeln examine
	set midSpc [expr [$maxedgeln getMaximum]*0.1]
	set laySpcGR $r3c1gr

	for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
		set laySpcBegin [expr $laySpcBegin*$laySpcGR]
	}

	$reg3_b2v1 setMiddleMode ContinueGrowth
	$reg3_b2v1 setMiddleSpacing $midSpc
	$reg3_b2v1 setBeginLayers $i
	$reg3_b2v1 setBeginRate $laySpcGR
	$reg3_con1 setDistribution 1 $reg3_b2v1
	$reg3_con1 setSubConnectorDimensionFromDistribution 1

	$reg3_con2 setDimension [$reg3_con1 getDimension]
	[$reg3_con2 getDistribution 1] setBeginSpacing $r3v3s
	[$reg3_con2 getDistribution 1] setEndSpacing $r3v2s

	$reg3_con1 delete

	# ./2 blk 3 Region 3
	#-----------------

	#cons matching
	set r3v3end [pw::Examine create ConnectorEdgeLength]
	$r3v3end addEntity $wccs
	$r3v3end examine
	set r3v3e [$r3v3end getMaximum]

	set r3v3endm [pw::Examine create ConnectorEdgeLength]
	$r3v3endm addEntity $wc
	$r3v3endm examine
	set r3v3m [$r3v3endm getValue $wc [expr [$wc getDimension]-1]]

	#=======================================================Spliting Tails==============================
	set plow1 {0.55783684 -0.57192536 0.0}
	set plow2 {0.57828053 -0.57796003 2.7755576e-17}
	set plow3 {0.89423268 -0.66407866 0.0}

	set pup1 {0.87841013 0.30573454 -2.7755576e-17}
	set pup2 {1.1371937 0.32232921 -2.7755576e-17}

	set conl_tail [[lindex $conlowsp 1] split [list [[lindex $conlowsp 1] getParameter -closest $plow1] [[lindex $conlowsp 1] getParameter -closest $plow2]\
													 [[lindex $conlowsp 1] getParameter -closest $plow3]]]

	set conu_tail [[lindex $con_consp 0] split [list [[lindex $con_consp 0] getParameter -closest $pup1] [[lindex $con_consp 0] getParameter -closest $pup2]]]

	set reg2_seg5 [pw::SegmentSpline create]
	$reg2_seg5 addPoint [[[lindex $con_flsp 1] getNode End] getXYZ]
	$reg2_seg5 addPoint {0.77195588304284 -0.0253690926350217 -0}
	$reg2_seg5 addPoint [[[lindex $conl_tail 1] getNode End] getXYZ]
	$reg2_seg5 setSlope Free
	$reg2_seg5 setSlopeOut 1 {-0.0064386909455151908 -0.0042006839916895354 0}
	$reg2_seg5 setSlopeIn 2 {0.022144067099189035 0.023520195045794601 0}
	$reg2_seg5 setSlopeOut 2 {-0.022144067099189035 -0.023520195045794601 0}
	$reg2_seg5 setSlopeIn 3 {0.07755790499773163 0.16353618762694061 0}
	set reg2_con5 [pw::Connector create]
	$reg2_con5 addSegment $reg2_seg5

	set reg2_con5sp [$reg2_con5 split [list [$reg2_con5 getParameter -arc 0.064]]]

	[lindex $reg2_con5sp 1] setDimension [expr [$reg2_con3 getDimension]+[$sledg getDimension]+[$suedg getDimension]+\
									[$reg1_con3 getDimension]+ [[lindex $conupsp 0] getDimension] -4]

	set reg3_seg3 [pw::SegmentSpline create]
	$reg3_seg3 addPoint [[[lindex $reg2_con5sp 0] getNode End] getXYZ]
	$reg3_seg3 addPoint [[$wc getNode End] getXYZ]
	$reg3_seg3 setSlope Free
	$reg3_seg3 setSlopeOut 1 {-0.034045825017717468 0.015497335397455899 0}
	$reg3_seg3 setSlopeIn 2 {0.0096443017051907054 -0.00043180642509504583 0}
	set reg3_con3 [pw::Connector create]
	$reg3_con3 addSegment $reg3_seg3

	$reg3_con3 setDimension [$reg3_con2 getDimension]

	[$reg3_con3 getDistribution 1] setBeginSpacing $r3v3s
	[$reg3_con3 getDistribution 1] setEndSpacing $r3v3m

	set wccon1 [[[lindex $a_domsp 5] getEdge 1] getConnector 1]
	set wccon2 [[[lindex $a_domsp 5] getEdge 3] getConnector 1]

	set covspc [pw::Examine create ConnectorEdgeLength]
	$covspc addEntity $wccon2
	$covspc examine
	set covspcv [$covspc getValue $wccon2 1]

	set reg5dis [pw::DistributionGrowth create]
	$reg5dis setBeginSpacing [expr $r3v3s*2]
	$reg5dis setEndSpacing $covspcv
	set laySpcBegin $r3v3s
	set laySpcEnd $covspcv

	set maxedgeln [pw::Examine create ConnectorEdgeLength]
	$maxedgeln addEntity [lindex $con_flapsp 0]
	$maxedgeln examine
	set midSpc [expr [$maxedgeln getAverage]*0.5]
	set laySpcGR $r3c1gr

	for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
		set laySpcBegin [expr $laySpcBegin*$laySpcGR]
	}

	for {set j 0} {$laySpcEnd <= $midSpc} {incr j} {
		set laySpcEnd [expr $laySpcEnd*$laySpcGR]
	}

	$reg5dis setMiddleMode ContinueGrowth
	$reg5dis setMiddleSpacing $midSpc
	$reg5dis setBeginLayers $i
	$reg5dis setBeginRate $laySpcGR
	$reg5dis setEndLayers $j
	$reg5dis setEndRate $laySpcGR
	[lindex $reg2_con5sp 0] setDistribution 1 $reg3_b2v1
	[lindex $reg2_con5sp 0] setSubConnectorDimensionFromDistribution 1

	$wccon1 setDimension [expr [[lindex $reg2_con5sp 0] getDimension] + [[lindex $con_flapsp 0] getDimension] - 1]
	$wccon2 setDimension [expr [[lindex $reg2_con5sp 0] getDimension] + [[lindex $con_flapsp 0] getDimension] - 1]

	$domexm addEntity [lindex $a_domsp 0]
	lappend ncells [[lindex $a_domsp 0] getCellCount]
	lappend bldoms [lindex $a_domsp 0]

	$domexm addEntity [lindex $a_domsp 1]
	lappend ncells [[lindex $a_domsp 1] getCellCount]
	lappend bldoms [lindex $a_domsp 1]

	$domexm addEntity [lindex $a_domsp 2]
	lappend ncells [[lindex $a_domsp 2] getCellCount]
	lappend bldoms [lindex $a_domsp 2]

	$domexm addEntity [lindex $a_domsp 3]
	lappend ncells [[lindex $a_domsp 3] getCellCount]
	lappend bldoms [lindex $a_domsp 3]

	$domexm addEntity [lindex $a_domsp 4]
	lappend ncells [[lindex $a_domsp 4] getCellCount]
	lappend bldoms [lindex $a_domsp 4]

	$domexm addEntity [lindex $a_domsp 5]
	lappend ncells [[lindex $a_domsp 5] getCellCount]
	lappend bldoms [lindex $a_domsp 5]

	# 3. BTW FLAP AND WING
	set r3_blk3 [pw::DomainStructured createFromConnectors [list [lindex $con_flapsp 0] $wc $reg3_con2 $reg3_con3 [lindex $reg2_con5sp 0]]]
	lappend doms $r3_blk3
	lappend adjdoms $r3_blk3
	lappend adjdoms $r3_blk3
	lappend adjdoms $r3_blk3
	lappend adjbcs 4
	lappend adjbcs 3
	lappend adjbcs 2

	set reg2_seg6 [pw::SegmentSpline create]
	$reg2_seg6 addPoint [[[lindex $con_flsp 1] getNode Begin] getXYZ]
	$reg2_seg6 addPoint [[[lindex $conl_tail 2] getNode End] getXYZ]
	$reg2_seg6 setSlope Free
	$reg2_seg6 setSlopeOut 1 {-0.066879034131930415 -0.088484837118707388 0}
	$reg2_seg6 setSlopeIn 2 {0.058434107540432101 0.17100602440825402 0}
	set reg2_con6 [pw::Connector create]
	$reg2_con6 addSegment $reg2_seg6

	set reg2_con6sp [$reg2_con6 split [list [$reg2_con6 getParameter -arc 0.049]]]

	[lindex $reg2_con6sp 0] setDimension [[lindex $reg2_con5 0] getDimension]
	set r2c6seg [pw::DistributionGeneral create [list [lindex $reg2_con5 0]]]
	$r2c6seg setBeginSpacing 0
	$r2c6seg setEndSpacing 0
	$r2c6seg setVariable [[[lindex $reg2_con6sp 0] getDistribution 1] getVariable]
	[lindex $reg2_con6sp 0] setDistribution -lockEnds 1 $r2c6seg

	set r2c6sp0 [pw::Examine create ConnectorEdgeLength]
	$r2c6sp0 addEntity [lindex $reg2_con6sp 0]
	$r2c6sp0 examine
	set r2c6sp0v [$r2c6sp0 getValue [lindex $reg2_con6sp 0] [expr [[lindex $reg2_con6sp 0] getDimension]-1]]

	[lindex $reg2_con6sp 1] setDimension [expr [[lindex $reg2_con5sp 1] getDimension]]

	set reg2_seg7 [pw::SegmentSpline create]
	$reg2_seg7 addPoint [[[lindex $reg2_con5sp 0] getNode End] getXYZ]
	$reg2_seg7 addPoint [[[lindex $reg2_con6sp 0] getNode End] getXYZ]
	$reg2_seg7 setSlope Free
	$reg2_seg7 setSlopeOut 1 {0.059779768597580496 -0.027100804953559106 0}
	$reg2_seg7 setSlopeIn 2 {-0.049548514726682424 0.040377825058861422 0}
	set reg2_con7 [pw::Connector create]
	$reg2_con7 addSegment $reg2_seg7

	$reg2_con7 setDimension [[lindex $con_flsp 1] getDimension]
	set r2c7seg [pw::DistributionGeneral create [list [lindex $con_flsp 1]]]
	$r2c7seg setBeginSpacing 0
	$r2c7seg setEndSpacing 0
	$r2c7seg setVariable [[$reg2_con7 getDistribution 1] getVariable]
	$reg2_con7 setDistribution -lockEnds 1 $r2c7seg
	[$reg2_con7 getDistribution 1] reverse

	# 4. BELOW FLAP
	set r3_blk4 [pw::DomainStructured createFromConnectors [list [lindex $reg2_con5sp 0] [lindex $con_flsp 1] [lindex $reg2_con6sp 0] $reg2_con7]]
	lappend doms $r3_blk4
	lappend adjdoms $r3_blk4
	lappend adjdoms $r3_blk4
	lappend adjdoms $r3_blk4
	lappend adjbcs 2
	lappend adjbcs 3
	lappend adjbcs 4

	set end_seg [pw::SegmentSpline create]
	$end_seg addPoint [[[lindex $conu_tail 0] getNode Begin] getXYZ]
	$end_seg addPoint [[[lindex $conl_tail 3] getNode End] getXYZ]
	set end_con [pw::Connector create]
	$end_con addSegment $end_seg

	$end_con setDimension [expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension] + \
				[$wte getDimension] + [$reg3_con2 getDimension] + [$fte getDimension] +\
				[[lindex $con_flsp 0] getDimension] + [[lindex $con_fusp 1] getDimension] + [$reg2_con3 getDimension]+[$sledg getDimension]+[$suedg getDimension]\
				 +[[lindex $conupsp 0] getDimension]+[$reg1_con3 getDimension]+[[lindex $reg2_con5sp 0] getDimension]-13)]

	[$end_con getDistribution 1] setBeginSpacing $texrv
	[$end_con getDistribution 1] setEndSpacing $texrv

	set end_consp [$end_con split -I [list [expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension]-2)]\
	[expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension] + [$wte getDimension] + [$reg3_con2 getDimension]-4)]\
		[expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension] + [$wte getDimension] + [$reg3_con2 getDimension] +\
								[[lindex $con_flsp 0] getDimension] + [[lindex $con_fusp 1] getDimension] + [$fte getDimension]-7)]]]

	$conwu1_seg addPoint $ptAwu1
	$conwu1_seg addPoint {1.15790403901117 -0.09940953982774 0}
	$conwu1_seg addPoint {1.89488504626128 -0.227310186528001 0}
	$conwu1_seg addPoint [[[lindex $end_consp 0] getNode End] getXYZ]
	$conwu1_seg setSlope Free
	$conwu1_seg setSlopeOut 1 {0.096308946593529843 0.0016008999472437863 0}
	$conwu1_seg setSlopeIn 2 {-0.15508690685936988 0.068900490314906998 0}
	$conwu1_seg setSlopeOut 2 {0.1550869068593701 -0.068900490314906998 0}
	$conwu1_seg setSlopeIn 3 {-0.50883952130049015 0.043478209434036991 0}
	$conwu1_seg setSlopeOut 3 {0.50883952130048993 -0.043478209434037018 0}
	$conwu1_seg setSlopeIn 4 {-7003.6871790195137 6.9944648029272525 0}
	set conwu1_con [pw::Connector create]
	$conwu1_con addSegment $conwu1_seg

	$confu1_seg addPoint $ptAfu1
	$confu1_seg addPoint {1.66609550379898 -0.425721309513789 0.0}
	$confu1_seg addPoint [[[lindex $end_consp 1] getNode End] getXYZ]
	$confu1_seg setSlope Free
	$confu1_seg setSlopeOut 1 {0.057366242422751457 -0.052835705339539074 0}
	$confu1_seg setSlopeIn 2 {-0.31830905400692 0.064073167703865008 0}
	$confu1_seg setSlopeOut 2 {0.31830905400692 -0.064073167703865008 0}
	$confu1_seg setSlopeIn 3 {-7003.8797243488943 15.791674839111575 0}
	set confu1_con [pw::Connector create]
	$confu1_con addSegment $confu1_seg

	$confu2_seg addPoint $ptAfu2
	$confu2_seg addPoint {1.67060124202279 -0.48311020943268 0.000171277868638}
	$confu2_seg addPoint [[[lindex $end_consp 2] getNode End] getXYZ]
	$confu2_seg setSlope Free
	$confu2_seg setSlopeOut 1 {0.042512205918592949 -0.083968361186473411 5.7092622879333298e-05}
	$confu2_seg setSlopeIn 2 {-0.28536755074811015 0.070930598778093989 -5.7092622879332993e-05}
	$confu2_seg setSlopeOut 2 {0.28536755074810993 -0.070930598778094045 5.7092622879333007e-05}
	$confu2_seg setSlopeIn 3 {-6998.7799151064346 18.866814377263314 5.7092622879333298e-05}
	set confu2_con [pw::Connector create]
	$confu2_con addSegment $confu2_seg

	set wigu_tail [$conwu1_con split [list [$conwu1_con getParameter -closest {1.1280577 -0.084106942 8.6736174e-19}]]]

	[lindex $conu_tail 2] setDimension [$wu getDimension]
	set tail1seg [pw::DistributionGeneral create [list $wu]]
	$tail1seg setBeginSpacing 0
	$tail1seg setEndSpacing 0
	$tail1seg setVariable [[[lindex $conu_tail 2] getDistribution 1] getVariable]
	[lindex $conu_tail 2] setDistribution -lockEnds 1 $tail1seg
	[[lindex $conu_tail 2] getDistribution 1] reverse

	[lindex $conl_tail 0] setDimension [[lindex $conupsp 1] getDimension]
	set tail2seg [pw::DistributionGeneral create [list [lindex $conupsp 1]]]
	$tail2seg setBeginSpacing 0
	$tail2seg setEndSpacing 0
	$tail2seg setVariable [[[lindex $conl_tail 0] getDistribution 1] getVariable]
	[lindex $conl_tail 0] setDistribution -lockEnds 1 $tail2seg
	[[lindex $conl_tail 0] getDistribution 1] reverse

	[lindex $conl_tail 1] setDimension [expr [$reg3_con3 getDimension]]
	set tail3seg [pw::DistributionGeneral create [list $reg3_con3 [lindex $conupsp 0]]]
	$tail3seg setBeginSpacing 0
	$tail3seg setEndSpacing 0
	$tail3seg setVariable [[[lindex $conl_tail 1] getDistribution 1] getVariable]
	[lindex $conl_tail 1] setDistribution -lockEnds 1 $tail3seg
	[[lindex $conl_tail 1] getDistribution 1] reverse

	[lindex $conl_tail 2] setDimension [$reg2_con7 getDimension]
	set tail4seg [pw::DistributionGeneral create [list $reg2_con7]]
	$tail4seg setBeginSpacing 0
	$tail4seg setEndSpacing 0
	$tail4seg setVariable [[[lindex $conl_tail 2] getDistribution 1] getVariable]
	[lindex $conl_tail 2] setDistribution -lockEnds 1 $tail4seg

	[lindex $wigu_tail 0] setDimension [[lindex $con_fusp 0] getDimension]
	set tail5seg [pw::DistributionGeneral create [list [lindex $con_fusp 0]]]
	$tail5seg setBeginSpacing 0
	$tail5seg setEndSpacing 0
	$tail5seg setVariable [[[lindex $wigu_tail 0] getDistribution 1] getVariable]
	[lindex $wigu_tail 0] setDistribution -lockEnds 1 $tail5seg

	[lindex $conu_tail 1] setDimension [[lindex $wigu_tail 0] getDimension]
	set tail6seg [pw::DistributionGeneral create [list [lindex $wigu_tail 0]]]
	$tail6seg setBeginSpacing 0
	$tail6seg setEndSpacing 0
	$tail6seg setVariable [[[lindex $conu_tail 1] getDistribution 1] getVariable]
	[lindex $conu_tail 1] setDistribution -lockEnds 1 $tail6seg
	[[lindex $conu_tail 1] getDistribution 1] reverse

	#tail 1
	set tt0 [pw::Examine create ConnectorEdgeLength]
	$tt0 addEntity [lindex $conu_tail 1]
	$tt0 examine
	set tt0v [$tt0 getValue [lindex $conu_tail 1] 1]

	set maxmidspc [list 1000 1300 1800 5000 10000 20000 30000]

	set tt1 [pw::DistributionGrowth create]
	$tt1 setBeginSpacing $tt0v
	set laySpcBegin $tt0v
	set midSpc [expr [$tt0 getMaximum]*[lindex $maxmidspc $reflev]]
	set laySpcGR 1.07

	for {set i 0} {$laySpcBegin <= $midSpc} {incr i} {
		set laySpcBegin [expr $laySpcBegin*$laySpcGR]
	}

	$tt1 setMiddleMode ContinueGrowth
	$tt1 setMiddleSpacing $midSpc
	$tt1 setBeginLayers $i
	$tt1 setBeginRate $laySpcGR
	[lindex $conu_tail 0] setDistribution 1 $tt1
	[lindex $conu_tail 0] setSubConnectorDimensionFromDistribution 1
	[[lindex $conu_tail 0] getDistribution 1] reverse

	set tt00 [pw::Examine create ConnectorEdgeLength]
	$tt00 addEntity $fte1cs
	$tt00 examine
	set tt00v [$tt00 getValue $fte1cs [expr [$fte1cs getDimension]-1]]

	set tt000 [pw::Examine create ConnectorEdgeLength]
	$tt000 addEntity $fte2cs
	$tt000 examine
	set tt000v [$tt000 getValue $fte2cs [expr [$fte2cs getDimension]-1]]

	#tail 2
	[lindex $wigu_tail 1] setDimension [[lindex $conu_tail 0] getDimension]
	set tail7seg [pw::DistributionGeneral create [list [lindex $conu_tail 0]]]
	$tail7seg setBeginSpacing 0
	$tail7seg setEndSpacing 0
	$tail7seg setVariable [[[lindex $wigu_tail 1] getDistribution 1] getVariable]
	[lindex $wigu_tail 1] setDistribution -lockEnds 1 $tail7seg
	[[lindex $wigu_tail 1] getDistribution 1] reverse
	[[lindex $wigu_tail 1] getDistribution 1] setBeginSpacing $tt00v
	[[lindex $wigu_tail 0] getDistribution 1] setEndSpacing $tt00v

	#tail 3
	$confu1_con setDimension [[lindex $wigu_tail 1] getDimension]
	$confu1_con setDistribution 1 [[[lindex $wigu_tail 1] getDistribution 1] copy]
	[$confu1_con getDistribution 1] setBeginSpacing $tt000v

	#tail 4
	$confu2_con setDimension [$confu1_con getDimension]
	set tail10seg [pw::DistributionGeneral create [list $confu1_con]]
	$tail10seg setBeginSpacing 0
	$tail10seg setEndSpacing 0
	$tail10seg setVariable [[$confu2_con getDistribution 1] getVariable]
	$confu2_con setDistribution 1 $tail10seg
	[$confu2_con getDistribution 1] setBeginSpacing $tt00v

	#tail 5
	[lindex $conl_tail 3] setDimension [$confu2_con getDimension]
	set tail9seg [pw::DistributionGeneral create [list $confu2_con]]
	$tail9seg setBeginSpacing 0
	$tail9seg setEndSpacing 0
	$tail9seg setVariable [[[lindex $conl_tail 3] getDistribution 1] getVariable]
	[lindex $conl_tail 3] setDistribution -lockEnds 1 $tail9seg

	$reg1_con5 setDimension [$reg1_con3 getDimension]
	set midseg2 [pw::DistributionGeneral create [list $reg1_con3]]
	$midseg2 setBeginSpacing 0
	$midseg2 setEndSpacing 0
	$midseg2 setVariable [[$reg1_con5 getDistribution 1] getVariable]
	$reg1_con5 setDistribution 1 $midseg2
	[$reg1_con5 getDistribution 1] setEndSpacing $texrv

	[lindex $conlowspsp 0] setDimension [$sle getDimension]
	set mid2seg [pw::DistributionGeneral create [list $sle]]
	$mid2seg setBeginSpacing 0
	$mid2seg setEndSpacing 0
	$mid2seg setVariable [[[lindex $conlowspsp 0] getDistribution 1] getVariable]
	[lindex $conlowspsp 0] setDistribution -lockEnds 1 $mid2seg
	[[lindex $conlowspsp 0] getDistribution 1] reverse

	[lindex $conlowspsp 1] setDimension [[lindex $conupsp 2] getDimension]
	set mid2seg [pw::DistributionGeneral create [list [lindex $conupsp 2]]]
	$mid2seg setBeginSpacing 0
	$mid2seg setEndSpacing 0
	$mid2seg setVariable [[[lindex $conlowspsp 1] getDistribution 1] getVariable]
	[lindex $conlowspsp 1] setDistribution -lockEnds 1 $mid2seg
	[[lindex $conlowspsp 1] getDistribution 1] reverse

	set slespc [pw::Examine create ConnectorEdgeLength]
	$slespc addEntity [lindex $conlowspsp 1]
	$slespc examine
	set slespcv [$slespc getValue [lindex $conlowspsp 1] 1]

	[[lindex $conlowspsp 0] getDistribution 1] setEndSpacing $slespcv

	$reg1_con4 setDimension [expr [$reg2_con3 getDimension]+[$sledg getDimension]+[$suedg getDimension]+[$reg1_con5 getDimension]-3]
	set mid3seg [pw::DistributionGeneral create [list $reg2_con3 $sledg $suedg $reg1_con5]]
	$mid3seg setBeginSpacing 0
	$mid3seg setEndSpacing 0
	$mid3seg setVariable [[$reg1_con4 getDistribution 1] getVariable]
	$reg1_con4 setDistribution -lockEnds 1 $mid3seg

	#=====================================================SPACINGS===================================
	set ts0 [pw::Examine create ConnectorEdgeLength]
	$ts0 addEntity [lindex $conu_tail 1]
	$ts0 examine
	set ts0v [$ts0 getValue [lindex $conu_tail 1] [expr [[lindex $conu_tail 1] getDimension] -1]]

	set ts1 [pw::Examine create ConnectorEdgeLength]
	$ts1 addEntity [lindex $conu_tail 2]
	$ts1 examine
	set ts1v [$ts1 getValue [lindex $conu_tail 2] [expr [[lindex $conu_tail 2] getDimension] -1]]

	set ts2 [pw::Examine create ConnectorEdgeLength]
	$ts2 addEntity [lindex $conl_tail 0]
	$ts2 examine
	set ts2v [$ts2 getValue [lindex $conl_tail 0] 1]

	set ts3 [pw::Examine create ConnectorEdgeLength]
	$ts3 addEntity [lindex $conl_tail 1]
	$ts3 examine
	set ts3v [$ts3 getValue [lindex $conl_tail 1] 1]

	set ts6 [pw::Examine create ConnectorEdgeLength]
	$ts6 addEntity [lindex $conl_tail 2]
	$ts6 examine
	set ts6v [$ts6 getValue [lindex $conl_tail 2] 1]

	set ts4 [pw::Examine create ConnectorEdgeLength]
	$ts4 addEntity [lindex $conl_tail 2]
	$ts4 examine
	set ts4v [$ts4 getValue [lindex $conl_tail 2] [expr [[lindex $conl_tail 2] getDimension] -1]]

	[[lindex $conl_tail 0] getDistribution 1] setEndSpacing $ts3v
	[[lindex $conl_tail 3] getDistribution 1] setBeginSpacing $ts4v
	[[lindex $conl_tail 1] getDistribution 1] setEndSpacing $ts6v

	$conwups addPoint [[[lindex $conu_tail 2] getNode Begin] getXYZ]
	$conwups addPoint [[$wu getNode End] getXYZ]
	$conwups setSlope Free
	$conwups setSlopeOut 1 {0.0070737862287199027 -0.073714839558578521 0}
	$conwups setSlopeIn 2 {0.021087198341749103 0.038234843591719435 0}
	set conwup [pw::Connector create]
	$conwup addSegment $conwups
	$conwup setDimension [expr int ([$reg2_con2 getDimension]+[$ste getDimension]+[$reg1_con1 getDimension]-2)]
	[$conwup getDistribution 1] setBeginSpacing $texrv
	[$conwup getDistribution 1] setEndSpacing $r3v2s
	[[lindex $wigu_tail 0] getDistribution 1] setBeginSpacing $r3v2s

	$confups addPoint [[[lindex $wigu_tail 0] getNode End] getXYZ]
	$confups addPoint [[[lindex $con_fusp 0] getNode End] getXYZ]
	$confups setSlope Free
	$confups setSlopeOut 1 {-0.0041514327332810019 -0.010146243817996295 0}
	$confups setSlopeIn 2 {0.023335818788357665 0.0081820871141068396 0}
	set confup [pw::Connector create]
	$confup addSegment $confups
	$confup setDimension [expr int ([$reg3_con2 getDimension]+[$wte getDimension]-1)]
	[$confup getDistribution 1] setBeginSpacing $r3v2s
	[$confup getDistribution 1] setEndSpacing $tt00v

	$reg1_con4 addBreakPoint -Y [lindex [$reg1_con4 getPosition -grid [expr [$reg2_con3 getDimension]+1]] 1]
	$reg1_con4 addBreakPoint -Y [lindex [$reg1_con4 getPosition -grid [expr [$reg2_con3 getDimension]+[$sledg getDimension]+[$suedg getDimension]-2]] 1]

	set midScpexm [pw::Examine create ConnectorEdgeLength]
	$midScpexm addEntity $reg1_con4
	$midScpexm examine
	set midSpcVal [$midScpexm getValue $reg1_con4 [$reg2_con3 getDimension]]

	[$reg1_con4 getDistribution 1] setEndSpacing $midSpcVal
	[$reg1_con4 getDistribution 3] setBeginSpacing $midSpcVal
	[$reg1_con4 getDistribution 3] setEndSpacing $texrv

	set segmidcon [pw::SegmentSpline create]
	$segmidcon addPoint [[[lindex $conupsp 0] getNode End] getXYZ]
	$segmidcon addPoint [[[lindex $conl_tail 0] getNode End] getXYZ]
	$segmidcon setPoint 2 {0.738223367226841 -0.0416443542487878 -0}
	$segmidcon addPoint [[[lindex $conl_tail 0] getNode End] getXYZ]
	$segmidcon setSlope Free
	$segmidcon setSlopeOut 1 {0.0026610095105451537 -0.0030644481871643127 0}
	$segmidcon setSlopeIn 2 {0.0011803843908849698 0.018251427194276498 0}
	$segmidcon setSlopeOut 2 {-0.0011803843908849698 -0.018251427194276505 0}
	$segmidcon setSlopeIn 3 {0.081475347378032748 0.16433617575903792 0}
	set reg2_con8 [pw::Connector create]
	$reg2_con8 addSegment $segmidcon

	set r1con4dims [$reg1_con4 getSubConnectorDimension]
	$reg2_con8 setDimension [$reg1_con4 getDimension]

	$reg2_con8 addBreakPoint -arc [expr [$reg1_con4 getLength -grid [lindex $r1con4dims 0]]/[$reg1_con4 getLength -arc 1]]
	$reg2_con8 addBreakPoint -arc [expr [$reg1_con4 getLength -grid [expr [lindex $r1con4dims 1]+[lindex $r1con4dims 0]]]/[$reg1_con4 getLength -arc 1]]

	$reg2_con8 setSubConnectorDimension $r1con4dims

	set reg28dis1 [pw::DistributionGeneral create [list [list $reg1_con4 1]]]
	$reg28dis1 setBeginSpacing 0
	$reg28dis1 setEndSpacing 0
	$reg28dis1 setVariable [[$reg2_con8 getDistribution 1] getVariable]
	$reg2_con8 setDistribution 1 $reg28dis1

	set reg28dis2 [pw::DistributionGeneral create [list [list $reg1_con4 2]]]
	$reg28dis2 setBeginSpacing 0
	$reg28dis2 setEndSpacing 0
	$reg28dis2 setVariable [[$reg2_con8 getDistribution 2] getVariable]
	$reg2_con8 setDistribution 2 $reg28dis2

	set reg28dis3 [pw::DistributionGeneral create [list [list $reg1_con4 3]]]
	$reg28dis3 setBeginSpacing 0
	$reg28dis3 setEndSpacing 0
	$reg28dis3 setVariable [[$reg2_con8 getDistribution 3] getVariable]
	$reg2_con8 setDistribution 3 $reg28dis3
	[$reg2_con8 getDistribution 3] setEndSpacing $texrv

	set r2c2spc1 [pw::Examine create ConnectorEdgeLength]
	$r2c2spc1 addEntity $reg2_con8
	$r2c2spc1 examine
	set r2c2spcv1 [$r2c2spc1 getValue $reg2_con8 1]

	set r2c2spc2 [pw::Examine create ConnectorEdgeLength]
	$r2c2spc2 addEntity $reg2_con8
	$r2c2spc2 examine
	set r2c2spcv2 [$r2c2spc2 getValue $reg2_con8 [expr [lindex $r1con4dims 0]+1]]

	[lindex $reg2_con5sp 1] addBreakPoint -arc [expr [$reg1_con4 getLength -grid [lindex $r1con4dims 0]]/[$reg1_con4 getLength -arc 1] + 0.04]
	[lindex $reg2_con5sp 1] addBreakPoint -arc [expr [$reg1_con4 getLength -grid [expr [lindex $r1con4dims 1]+[lindex $r1con4dims 0]]]/[$reg1_con4 getLength -arc 1] + 0.04]

	[lindex $reg2_con5sp 1] setSubConnectorDimension [list [expr [lindex $r1con4dims 0]+[[lindex $conupsp 0] getDimension]-1] [lindex $r1con4dims 1] [lindex $r1con4dims 2]]

	set mid1seg1 [pw::DistributionGeneral create [list [list $reg2_con8 1] [list [lindex $conupsp 0] 1]]]
	$mid1seg1 setBeginSpacing 0
	$mid1seg1 setEndSpacing 0
	$mid1seg1 setVariable [[[lindex $reg2_con5sp 1] getDistribution 1] getVariable]
	[lindex $reg2_con5sp 1] setDistribution 1 $mid1seg1
	[[lindex $reg2_con5sp 1] getDistribution 1] reverse

	set mid1seg2 [pw::DistributionGeneral create [list [list $reg2_con8 2]]]
	$mid1seg2 setBeginSpacing 0
	$mid1seg2 setEndSpacing 0
	$mid1seg2 setVariable [[[lindex $reg2_con5sp 1] getDistribution 2] getVariable]
	[lindex $reg2_con5sp 1] setDistribution 2 $mid1seg2
	[[lindex $reg2_con5sp 1] getDistribution 2] reverse

	set mid1seg3 [pw::DistributionGeneral create [list [list $reg2_con8 3]]]
	$mid1seg3 setBeginSpacing 0
	$mid1seg3 setEndSpacing 0
	$mid1seg3 setVariable [[[lindex $reg2_con5sp 1] getDistribution 3] getVariable]
	[lindex $reg2_con5sp 1] setDistribution 3 $mid1seg3

	[[lindex $reg2_con5sp 1] getDistribution 1] setBeginSpacing $r3v3s
	[[lindex $reg2_con5sp 1] getDistribution 1] setEndSpacing $r2c2spcv2
	[[lindex $reg2_con5sp 1] getDistribution 3] setBeginSpacing $r2c2spcv2
	[[lindex $reg2_con5sp 1] getDistribution 3] setEndSpacing $texrv

	[lindex $reg2_con6sp 1] addBreakPoint -arc [expr [[lindex $reg2_con5sp 1] getLength -grid [expr [lindex $r1con4dims 0]+\
												[[lindex $conupsp 0] getDimension]-1]]/[[lindex $reg2_con5sp 1] getLength -arc 1]]
	[lindex $reg2_con6sp 1] addBreakPoint -arc [expr [[lindex $reg2_con5sp 1] getLength -grid [expr [lindex $r1con4dims 1]+\
										[lindex $r1con4dims 0]+[[lindex $conupsp 0] getDimension]]]/[[lindex $reg2_con5sp 1] getLength -arc 1]]

	[lindex $reg2_con6sp 1] setSubConnectorDimension [list [expr [lindex $r1con4dims 0]+[[lindex $conupsp 0] getDimension]-1] [lindex $r1con4dims 1] [lindex $r1con4dims 2]]

	set r2c6seg1 [pw::DistributionGeneral create [list [lindex $reg2_con5sp 1] 1]]
	$r2c6seg1 setBeginSpacing 0
	$r2c6seg1 setEndSpacing 0
	$r2c6seg1 setVariable [[[lindex $reg2_con6sp 1] getDistribution 1] getVariable]
	[lindex $reg2_con6sp 1] setDistribution 1 $r2c6seg1

	set r2c6seg2 [pw::DistributionGeneral create [list [lindex $reg2_con5sp 1] 2]]
	$r2c6seg2 setBeginSpacing 0
	$r2c6seg2 setEndSpacing 0
	$r2c6seg2 setVariable [[[lindex $reg2_con6sp 1] getDistribution 2] getVariable]
	[lindex $reg2_con6sp 1] setDistribution 2 $r2c6seg2

	set r2c6seg3 [pw::DistributionGeneral create [list [lindex $reg2_con5sp 1] 3]]
	$r2c6seg3 setBeginSpacing 0
	$r2c6seg3 setEndSpacing 0
	$r2c6seg3 setVariable [[[lindex $reg2_con6sp 1] getDistribution 3] getVariable]
	[lindex $reg2_con6sp 1] setDistribution 3 $r2c6seg3

	[[lindex $reg2_con6sp 1] getDistribution 1] setBeginSpacing $r2c6sp0v
	[[lindex $reg2_con6sp 1] getDistribution 1] setEndSpacing $r2c2spcv2
	[[lindex $reg2_con6sp 1] getDistribution 3] setBeginSpacing $r2c2spcv2
	[[lindex $reg2_con6sp 1] getDistribution 3] setEndSpacing $texrv

	set slatdown [pw::Examine create ConnectorEdgeLength]
	$slatdown addEntity [lindex $conl_tail 0]
	$slatdown examine
	set slatdownv [$slatdown getValue [lindex $conl_tail 0] 1]

	[[lindex $conlowspsp 1] getDistribution 1] setEndSpacing $slatdownv

	set bwtfwspc [pw::Examine create ConnectorEdgeLength]
	$bwtfwspc addEntity [[[lindex $f_domsp 3] getEdge 2] getConnector 1]
	$bwtfwspc examine
	set bwtfwspcv [$bwtfwspc getValue [[[lindex $f_domsp 3] getEdge 2] getConnector 1] [expr [[[[lindex $f_domsp 3] getEdge 2] getConnector 1] getDimension]-1]]

	[[lindex $reg2_con5sp 0] getDistribution 1] setBeginSpacing $bwtfwspcv

	[[lindex $reg2_con6sp 0] getDistribution 1] setBeginSpacing $bwtfwspcv

	#=====================================================TAIL BLOCKs===================================
	# 5. OVER WING
	set edge11 [pw::Edge create]
		$edge11 addConnector $reg2_con2
		$edge11 addConnector $ste
		$edge11 addConnector $reg1_con1
	set edge12 [pw::Edge create]
		$edge12 addConnector [lindex $conu_tail 2]
	set edge13 [pw::Edge create]
		$edge13 addConnector $conwup
	set edge14 [pw::Edge create]
		$edge14 addConnector $wu
	set blk1 [pw::DomainStructured create]
		$blk1 addEdge $edge11
		$blk1 addEdge $edge12
		$blk1 addEdge $edge13
		$blk1 addEdge $edge14

	lappend doms $blk1
	lappend adjdoms $blk1
	lappend fixdoms $blk1
	lappend adjbcs 1
	lappend fixbcs 3

	# 6. WING TAIL
	set edge112 [pw::Edge create]
		$edge112 addConnector $conwup
	set edge122 [pw::Edge create]
		$edge122 addConnector [lindex $conu_tail 1]
		$edge122 addConnector [lindex $conu_tail 0]
	set edge132 [pw::Edge create]
		$edge132 addConnector [lindex $end_consp 0]
	set edge142 [pw::Edge create]
		$edge142 addConnector [lindex $wigu_tail 1]
		$edge142 addConnector [lindex $wigu_tail 0]
	set blk12 [pw::DomainStructured create]
		$blk12 addEdge $edge112
		$blk12 addEdge $edge122
		$blk12 addEdge $edge132
		$blk12 addEdge $edge142

	set blk12sp [$blk12 split -J [list [[lindex $conu_tail 1] getDimension]]]
	set blk12sp1con [[[lindex $blk12sp 0] getEdge 3] getConnector 1]
	[$blk12sp1con getDistribution 1] setEndSpacing $texrv
	[$blk12sp1con getDistribution 1] setBeginSpacing $r3v2s

	lappend doms [lindex $blk12sp 0]
	lappend doms [lindex $blk12sp 1]
	lappend adjdoms [lindex $blk12sp 0]
	lappend fixdoms [lindex $blk12sp 0]
	lappend adjbcs 4
	lappend fixbcs 1

	# 7. OVER FLAP
	set edge21 [pw::Edge create]
		$edge21 addConnector [lindex $wigu_tail 0]
	set edge22 [pw::Edge create]
		$edge22 addConnector $confup
	set edge23 [pw::Edge create]
		$edge23 addConnector [lindex $con_fusp 0]
	set edge24 [pw::Edge create]
		$edge24 addConnector $reg3_con2
		$edge24 addConnector $wte
	set blk2 [pw::DomainStructured create]
		$blk2 addEdge $edge21
		$blk2 addEdge $edge22
		$blk2 addEdge $edge23
		$blk2 addEdge $edge24

	lappend doms $blk2
	lappend adjdoms $blk2
	lappend adjdoms $blk2
	lappend adjbcs 1
	lappend adjbcs 4

	# 7. FLAP TAIL
	set edge212 [pw::Edge create]
		$edge212 addConnector [lindex $wigu_tail 1]
	set edge222 [pw::Edge create]
		$edge222 addConnector [lindex $end_consp 1]
	set edge232 [pw::Edge create]
		$edge232 addConnector $confu1_con
	set edge242 [pw::Edge create]
		$edge242 addConnector $confup
	set blk22 [pw::DomainStructured create]
		$blk22 addEdge $edge212
		$blk22 addEdge $edge222
		$blk22 addEdge $edge232
		$blk22 addEdge $edge242

	lappend doms $blk22
	lappend adjdoms $blk22
	lappend adjbcs 3

	# 8. FLAP TE
	set edge41 [pw::Edge create]
		$edge41 addConnector [lindex $con_flsp 0]
		$edge41 addConnector $fte
		$edge41 addConnector [lindex $con_fusp 1]
	set edge42 [pw::Edge create]
		$edge42 addConnector $confu1_con
	set edge43 [pw::Edge create]
		$edge43 addConnector [lindex $end_consp 2]
	set edge44 [pw::Edge create]
		$edge44 addConnector $confu2_con
	set blk4 [pw::DomainStructured create]
		$blk4 addEdge $edge41
		$blk4 addEdge $edge42
		$blk4 addEdge $edge43
		$blk4 addEdge $edge44

	$domexm addEntity $blk4

	if {[string compare $grid_type STR]==0} {
		lappend ncells [$blk4 getCellCount]
	}

	lappend doms $blk4
	lappend adjdoms $blk4
	lappend adjdoms $blk4
	lappend adjbcs 2
	lappend adjbcs 4

	lappend confarbc [[$blk4 getEdge 3] getConnector 1]
	lappend domfarbc $blk4

	# 9. SLAT LE DOWN
	set edge31 [pw::Edge create]
		$edge31 addConnector $reg1_con3
	set edge32 [pw::Edge create]
		$edge32 addConnector $sle
	set edge33 [pw::Edge create]
		$edge33 addConnector $reg1_con5
	set edge34 [pw::Edge create]
		$edge34 addConnector [lindex $conlowspsp 0]
	set blk3 [pw::DomainStructured create]
		$blk3 addEdge $edge31
		$blk3 addEdge $edge32
		$blk3 addEdge $edge33
		$blk3 addEdge $edge34

	lappend doms $blk3
	lappend adjdoms $blk3
	lappend adjdoms $blk3
	lappend adjbcs 1
	lappend adjbcs 3

	# 9. SLAT LE UP
	set edge311 [pw::Edge create]
		$edge311 addConnector $reg1_con5
		$edge311 addConnector $suedg
		$edge311 addConnector $sledg
		$edge311 addConnector $reg2_con3
	set edge312 [pw::Edge create]
		$edge312 addConnector [lindex $conupsp 2]
	set edge313 [pw::Edge create]
		$edge313 addConnector $reg1_con4
	set edge314 [pw::Edge create]
		$edge314 addConnector [lindex $conlowspsp 1]
	set blk31 [pw::DomainStructured create]
		$blk31 addEdge $edge311
		$blk31 addEdge $edge312
		$blk31 addEdge $edge313
		$blk31 addEdge $edge314

	lappend doms $blk31
	lappend adjdoms $blk31
	lappend adjdoms $blk31
	lappend adjbcs 1
	lappend adjbcs 3

	# 9. BELOW WING
	set edge312 [pw::Edge create]
		$edge312 addConnector $reg1_con4
	set edge322 [pw::Edge create]
		$edge322 addConnector [lindex $conl_tail 0]
	set edge332 [pw::Edge create]
		$edge332 addConnector $reg2_con8
	set edge342 [pw::Edge create]
		$edge342 addConnector [lindex $conupsp 1]
	set blk321 [pw::DomainStructured create]
		$blk321 addEdge $edge312
		$blk321 addEdge $edge322
		$blk321 addEdge $edge332
		$blk321 addEdge $edge342

	lappend doms $blk321
	lappend adjdoms $blk321
	lappend adjdoms $blk321
	lappend adjbcs 1
	lappend adjbcs 3

	# 9. BTW WING AND FLAP / DOWN
	set edge313 [pw::Edge create]
		$edge313 addConnector [lindex $reg2_con5sp 1]
	set edge323 [pw::Edge create]
		$edge323 addConnector [lindex $conl_tail 1]
	set edge333 [pw::Edge create]
		$edge333 addConnector $reg2_con8
		$edge333 addConnector [lindex $conupsp 0]
	set edge343 [pw::Edge create]
		$edge343 addConnector $reg3_con3
	set blk322 [pw::DomainStructured create]
		$blk322 addEdge $edge313
		$blk322 addEdge $edge323
		$blk322 addEdge $edge333
		$blk322 addEdge $edge343

	lappend doms $blk322
	lappend adjdoms $blk322
	lappend adjdoms $blk322
	lappend adjdoms $blk322
	lappend adjbcs 4
	lappend adjbcs 3
	lappend adjbcs 1

	# 10 BELOW FLAP
	set edge313 [pw::Edge create]
		$edge313 addConnector [lindex $reg2_con5sp 1]
	set edge323 [pw::Edge create]
		$edge323 addConnector $reg2_con7
	set edge333 [pw::Edge create]
		$edge333 addConnector [lindex $reg2_con6sp 1]
	set edge343 [pw::Edge create]
		$edge343 addConnector [lindex $conl_tail 2]
	set blk33 [pw::DomainStructured create]
		$blk33 addEdge $edge313
		$blk33 addEdge $edge323
		$blk33 addEdge $edge333
		$blk33 addEdge $edge343

	lappend doms $blk33
	lappend adjdoms $blk33
	lappend adjdoms $blk33
	lappend adjdoms $blk33
	lappend adjbcs 1
	lappend adjbcs 2
	lappend adjbcs 3

	# 11 FLAP TAIL DOWN
	set edge51 [pw::Edge create]
		$edge51 addConnector $confu2_con
	set edge52 [pw::Edge create]
		$edge52 addConnector [lindex $end_consp 3]
	set edge53 [pw::Edge create]
		$edge53 addConnector [lindex $conl_tail 3]
	set edge54 [pw::Edge create]
		$edge54 addConnector [lindex $reg2_con6sp 0]
		$edge54 addConnector [lindex $reg2_con6sp 1]
	set blk5 [pw::DomainStructured create]
		$blk5 addEdge $edge51
		$blk5 addEdge $edge52
		$blk5 addEdge $edge53
		$blk5 addEdge $edge54

	lappend doms $blk5
	lappend adjdoms $blk5
	lappend adjdoms $blk5
	lappend adjbcs 4
	lappend adjbcs 1

}
