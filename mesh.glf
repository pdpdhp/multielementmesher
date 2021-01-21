package require PWI_Glyph 3.18.3

set scriptDir [file dirname [info script]]

#airfoil configuration selection
set airfoil 1

#Grid Level
set res_lev 6

#airfoil, flap, and slat growth ratio distribution
set srfgr 1.15

#lower wing surface growth ratio distribution
set srfgrwl 1.18

#upper flap surface growth ratio distribution
set srfgrfu 1.18

# region 1 con 1 growth ratio
set r1c1gr 1.09

# region 2 con 3 growth ratio
set r2c3gr 1.09

# region 3 con 1 growth ratio
set r3c1gr 1.09

#Importing Meshing Guidline
set fp [open "$scriptDir/grid_specification.txt" r]
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

if {$res_lev==0} {
			set ypg [lindex $y_p 0]
			set dsg [lindex $d_s 0]
			set grg [lindex $gr 0]
			set chord_sg [lindex $chord_s 0]
			set ter_sg [lindex $ter 0]
			set ler_sg [lindex $ler 0]
			set tpts1_sg [lindex $tpt1 0]
			set tpts2_sg [lindex $tpt2 0]
			set exp_sg [lindex $exp 0]
			set imp_sg [lindex $imp 0]
			set vol_sg [lindex $vol 0]
			set stp_sg [lindex $extr 0]
} elseif {$res_lev==1} {
			set ypg [lindex $y_p 1]
			set dsg [lindex $d_s 1]
			set grg [lindex $gr 1]
			set chord_sg [lindex $chord_s 1]
			set ter_sg [lindex $ter 1]
			set ler_sg [lindex $ler 1]
			set tpts1_sg [lindex $tpt1 1]
			set tpts2_sg [lindex $tpt2 1]
			set exp_sg [lindex $exp 1]
			set imp_sg [lindex $imp 1]
			set vol_sg [lindex $vol 1]
			set stp_sg [lindex $extr 1]
} elseif {$res_lev==2} {
			set ypg [lindex $y_p 2]
			set dsg [lindex $d_s 2]
			set grg [lindex $gr 2]
			set chord_sg [lindex $chord_s 2]
			set ter_sg [lindex $ter 2]
			set ler_sg [lindex $ler 2]
			set tpts1_sg [lindex $tpt1 2]
			set tpts2_sg [lindex $tpt2 2]
			set exp_sg [lindex $exp 2]
			set imp_sg [lindex $imp 2]
			set vol_sg [lindex $vol 2]
			set stp_sg [lindex $extr 2]
} elseif {$res_lev==3} {
			set ypg [lindex $y_p 3]
			set dsg [lindex $d_s 3]
			set grg [lindex $gr 3]
			set chord_sg [lindex $chord_s 3]
			set ter_sg [lindex $ter 3]
			set ler_sg [lindex $ler 3]
			set tpts1_sg [lindex $tpt1 3]
			set tpts2_sg [lindex $tpt2 3]
			set exp_sg [lindex $exp 3]
			set imp_sg [lindex $imp 3]
			set vol_sg [lindex $vol 3]
			set stp_sg [lindex $extr 3]
} elseif {$res_lev==4} {
			set ypg [lindex $y_p 4]
			set dsg [lindex $d_s 4]
			set grg [lindex $gr 4]
			set chord_sg [lindex $chord_s 4]
			set ter_sg [lindex $ter 4]
			set ler_sg [lindex $ler 4]
			set tpts1_sg [lindex $tpt1 4]
			set tpts2_sg [lindex $tpt2 4]
			set exp_sg [lindex $exp 4]
			set imp_sg [lindex $imp 4]
			set vol_sg [lindex $vol 4]
			set stp_sg [lindex $extr 4]
} elseif {$res_lev==5} {
			set ypg [lindex $y_p 5]
			set dsg [lindex $d_s 5]
			set grg [lindex $gr 5]
			set chord_sg [lindex $chord_s 5]
			set ter_sg [lindex $ter 5]
			set ler_sg [lindex $ler 5]
			set tpts1_sg [lindex $tpt1 5]
			set tpts2_sg [lindex $tpt2 5]
			set exp_sg [lindex $exp 5]
			set imp_sg [lindex $imp 5]
			set vol_sg [lindex $vol 5]
			set stp_sg [lindex $extr 5]
} elseif {$res_lev==6} {
			set ypg [lindex $y_p 6]
			set dsg [lindex $d_s 6]
			set grg [lindex $gr 6]
			set chord_sg [lindex $chord_s 6]
			set ter_sg [lindex $ter 6]
			set ler_sg [lindex $ler 6]
			set tpts1_sg [lindex $tpt1 6]
			set tpts2_sg [lindex $tpt2 6]
			set exp_sg [lindex $exp 6]
			set imp_sg [lindex $imp 6]
			set vol_sg [lindex $vol 6]
			set stp_sg [lindex $extr 6]
} else {

puts "Please specify the right resolution level for your grid!"

}

pw::Connector setCalculateDimensionMaximum 100000

puts "GRID GUIDELINE: Y+:$ypg Delta_S(m):$dsg GR:$grg Chordwise_Spacing(m):$chord_sg"

source [file join $scriptDir "topo_div.glf"]


## Boundary blocks division:
#----------------------------------------------------------------------------
set a_domsp [$a_dom split -I [list [$wte getDimension] [expr [$wu getDimension]+[$wte getDimension]-1]\
		 [expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]-2]\
			[expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]+[[lindex $con_alsp 0] getDimension]-3]]]

set s_domsp [$s_dom split -I [list [$su getDimension] [expr [$su getDimension]+[$sl getDimension]-1]]]

set f_domsp [$f_dom split -I [list [$fte getDimension] [expr [$fte getDimension]+[$fl getDimension]-1]\
						[expr [$fte getDimension]+[$fl getDimension]+[[lindex $con_flapsp 1] getDimension]-2]]]

set wte1cs [[[lindex $a_domsp 0] getEdge 2] getConnector 1]
set wte2cs $wexcon
set wucs [[[lindex $a_domsp 1] getEdge 2] getConnector 1]
set wlcs [[[lindex $a_domsp 2] getEdge 2] getConnector 1]
set wccs [[[lindex $a_domsp 3] getEdge 2] getConnector 1]

set ste1cs [[[lindex $s_domsp 2] getEdge 2] getConnector 1]
set ste2cs [[[lindex $s_domsp 2] getEdge 4] getConnector 1]
set stulcs [[[lindex $s_domsp 0] getEdge 2] getConnector 1]

set fte2cs [[[lindex $f_domsp 0] getEdge 2] getConnector 1]
set fte1cs [[[lindex $f_domsp 0] getEdge 4] getConnector 1]
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
#puts $reg1c1sv

set reg1_b2v1 [pw::DistributionGrowth create]
$reg1_b2v1 setBeginSpacing $reg1c1sv
set laySpcBegin $reg1c1sv

set maxedgeln [pw::Examine create ConnectorEdgeLength]
$maxedgeln addEntity $su
$maxedgeln examine
set midSpc [expr [$maxedgeln getMaximum]*1]
#puts $midSpc
set laySpcGR $r1c1gr

#

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
set texrv [$texr getMaximum]

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
#puts $reg1c3sv

[$reg1_con3 getDistribution 1] setBeginSpacing $reg1c3sv
[$reg1_con3 getDistribution 1] setEndSpacing $texrv

set r1_blk2 [pw::DomainStructured createFromConnectors [list [lindex $con_consp 1] $reg1_con1 $su $reg1_con3]]

#=======================================================REGION 2======================================

set r2c2start [pw::Examine create ConnectorEdgeLength]
$r2c2start addEntity $wucs
$r2c2start examine
set r2c2s [$r2c2start getMaximum]

set r2c2end [pw::Examine create ConnectorEdgeLength]
$r2c2end addEntity $ste2cs
$r2c2end examine
set r2c2e [$r2c2end getMaximum]

#$reg2_con1 delete

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

set midSpc [expr $chord_sg*3]
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

set dom_blk3 [pw::DomainStructured createFromConnectors [list [lindex $con_alsp 1] $reg2_con3 $sl $reg2_con2]]

###=====================================================REGION 3===================================

set r3v1start [pw::Examine create ConnectorEdgeLength]
$r3v1start addEntity $fte1cs
$r3v1start examine
set r3v1s [$r3v1start getMaximum]

set r3v2end [pw::Examine create ConnectorEdgeLength]
$r3v2end addEntity $ftlu2cs
$r3v2end examine
set r3v2e [$r3v2end getMaximum]

set r3v3start [pw::Examine create ConnectorEdgeLength]
$r3v3start addEntity $fl
$r3v3start examine
set r3v3s [$r3v3start getValue $fl 1]

set reg3_b2v1 [pw::DistributionGrowth create]
$reg3_b2v1 setBeginSpacing $r3v3s
set laySpcBegin $r3v3s

set maxedgeln [pw::Examine create ConnectorEdgeLength]
$maxedgeln addEntity [lindex $con_flapsp 0]
$maxedgeln examine
set midSpc [expr [$maxedgeln getMaximum]/5]
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
$reg3_con3 setDimension [$reg3_con2 getDimension]

set r3v3end [pw::Examine create ConnectorEdgeLength]
$r3v3end addEntity $wccs
$r3v3end examine
set r3v3e [$r3v3end getMaximum]

set r3v3endm [pw::Examine create ConnectorEdgeLength]
$r3v3endm addEntity $wc
$r3v3endm examine
set r3v3m [$r3v3endm getValue $wc [expr [$wc getDimension]-1]]

[$reg3_con3 getDistribution 1] setBeginSpacing $r3v3s
[$reg3_con3 getDistribution 1] setEndSpacing $r3v3m

set r3_blk3 [pw::DomainStructured createFromConnectors [list [lindex $con_flapsp 1] $wc $reg3_con2 $reg3_con3]]

#=======================================================Spliting Tails==============================

set conl_tail [[lindex $con_consp 2] split [list [[lindex $con_consp 2] getParameter -arc 0.00162] [[lindex $con_consp 2] getParameter -arc 0.00192]\
												 [[lindex $con_consp 2] getParameter -arc 0.0022]]]

set conu_tail [[lindex $con_consp 0] split [list [[lindex $con_consp 0] getParameter -arc 0.9978905] [[lindex $con_consp 0] getParameter -arc 0.997107]]]

set end_seg [pw::SegmentSpline create]
$end_seg addPoint [[[lindex $conu_tail 0] getNode Begin] getXYZ]
$end_seg addPoint [[[lindex $conl_tail 3] getNode End] getXYZ]
set end_con [pw::Connector create]
$end_con addSegment $end_seg

$end_con setDimension [expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension] + \
									[$wte getDimension] + [$reg3_con2 getDimension] + [$fte getDimension] +\
										[$reg2_con3 getDimension] + [$reg1_con3 getDimension] - 7)]

[$end_con getDistribution 1] setBeginSpacing $texrv
[$end_con getDistribution 1] setEndSpacing $texrv

set end_consp [$end_con split -I [list [expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension]-2)]\
[expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension] + [$wte getDimension] + [$reg3_con2 getDimension]-4)]\
	[expr int([$reg1_con1 getDimension] + [$ste getDimension] + [$reg2_con2 getDimension] + [$wte getDimension] + [$reg3_con2 getDimension] +\
															 [$fte getDimension]-5)]]]

$conwu1_seg addPoint $ptAwu1
$conwu1_seg addPoint {1.15790403901117 -0.0994095398277397 -0}
$conwu1_seg addPoint {1.89488504626128 -0.227310186528001 -0}
$conwu1_seg addPoint [[[lindex $end_consp 0] getNode End] getXYZ]
$conwu1_seg setSlope Free
$conwu1_seg setSlopeOut 1 {0.15429875738948096 0.0018578460287982448 0}
$conwu1_seg setSlopeIn 2 {-0.099726411117059932 0.044547903199580803 0}
$conwu1_seg setSlopeOut 2 {0.099726411117060154 -0.044547903199580297 0}
$conwu1_seg setSlopeIn 3 {-0.46495892332791011 0.083421935345691006 0}
$conwu1_seg setSlopeOut 3 {0.46495892332790989 -0.083421935345690978 0}
$conwu1_seg setSlopeIn 4 {-194.67646916251704 5.1227384904501996 0}
set conwu1_con [pw::Connector create]
$conwu1_con addSegment $conwu1_seg

$confu1_seg addPoint $ptAfu1
$confu1_seg addPoint {1.66609550379898 -0.425721309513789 0.0}
$confu1_seg addPoint [[[lindex $end_consp 1] getNode End] getXYZ]
$confu1_seg setSlope Free
$confu1_seg setSlopeOut 1 {0.085091985096509504 -0.088833605390293113 0}
$confu1_seg setSlopeIn 2 {-0.33503507526840992 0.082699480140915993 0}
$confu1_seg setSlopeOut 2 {0.33503507526840992 -0.082699480140916048 0}
$confu1_seg setSlopeIn 3 {-367.44728608302 15.5111315423481 0}
set confu1_con [pw::Connector create]
$confu1_con addSegment $confu1_seg

$confu2_seg addPoint $ptAfu2
$confu2_seg addPoint {1.66446510647908 -0.437999500724808 0.0}
$confu2_seg addPoint [[[lindex $end_consp 2] getNode End] getXYZ]
$confu2_seg setSlope Free
$confu2_seg setSlopeOut 1 {0.015561614666338208 -0.042080669328739551 0}
$confu2_seg setSlopeIn 2 {-0.38913011044445001 0.096397354523615975 0}
$confu2_seg setSlopeOut 2 {0.38913011044444978 -0.096397354523615975 0}
$confu2_seg setSlopeIn 3 {-367.44728608302 15.511131542348064 0}
set confu2_con [pw::Connector create]
$confu2_con addSegment $confu2_seg

set reg2_seg5 [pw::SegmentSpline create]
$reg2_seg5 addPoint [[$fl getNode Begin] getXYZ]
$reg2_seg5 addPoint [[[lindex $conl_tail 1] getNode End] getXYZ]
$reg2_seg5 setSlope Free
$reg2_seg5 setSlopeOut 1 {-0.040698374979289076 -0.053676991640367988 0}
$reg2_seg5  setSlopeIn 2 {0.023247689036467234 0.082002476421941722 0}
set reg2_con5 [pw::Connector create]
$reg2_con5 addSegment $reg2_seg5

set wigu_tail [$conwu1_con split [list [$conwu1_con getParameter -arc 0.0006]]]

[lindex $conu_tail 2] setDimension [$wu getDimension]
set tail1seg [pw::DistributionGeneral create [list $wu]]
$tail1seg setBeginSpacing 0
$tail1seg setEndSpacing 0
$tail1seg setVariable [[[lindex $conu_tail 2] getDistribution 1] getVariable]
[lindex $conu_tail 2] setDistribution -lockEnds 1 $tail1seg
[[lindex $conu_tail 2] getDistribution 1] reverse

[lindex $conl_tail 0] setDimension [[lindex $con_alsp 0] getDimension]
set tail2seg [pw::DistributionGeneral create [list [lindex $con_alsp 0]]]
$tail2seg setBeginSpacing 0
$tail2seg setEndSpacing 0
$tail2seg setVariable [[[lindex $conl_tail 0] getDistribution 1] getVariable]
[lindex $conl_tail 0] setDistribution -lockEnds 1 $tail2seg
[[lindex $conl_tail 0] getDistribution 1] reverse

[lindex $conl_tail 1] setDimension [$reg3_con3 getDimension]
set tail3seg [pw::DistributionGeneral create [list $reg3_con3]]
$tail3seg setBeginSpacing 0
$tail3seg setEndSpacing 0
$tail3seg setVariable [[[lindex $conl_tail 1] getDistribution 1] getVariable]
[lindex $conl_tail 1] setDistribution -lockEnds 1 $tail3seg
[[lindex $conl_tail 1] getDistribution 1] reverse

[lindex $conl_tail 2] setDimension [$fl getDimension]
set tail4seg [pw::DistributionGeneral create [list $fl]]
$tail4seg setBeginSpacing 0
$tail4seg setEndSpacing 0
$tail4seg setVariable [[[lindex $conl_tail 2] getDistribution 1] getVariable]
[lindex $conl_tail 2] setDistribution -lockEnds 1 $tail4seg

[lindex $wigu_tail 0] setDimension [[lindex $con_flapsp 0] getDimension]
set tail5seg [pw::DistributionGeneral create [list [lindex $con_flapsp 0]]]
$tail5seg setBeginSpacing 0
$tail5seg setEndSpacing 0
$tail5seg setVariable [[[lindex $wigu_tail 0] getDistribution 1] getVariable]
[lindex $wigu_tail 0] setDistribution -lockEnds 1 $tail5seg
[[lindex $wigu_tail 0] getDistribution 1] reverse

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

set tt1 [pw::DistributionGrowth create]
$tt1 setBeginSpacing $tt0v
set laySpcBegin $tt0v
set midSpc [expr [$tt0 getMaximum]*1000]
set laySpcGR 1.05

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
set tt00v [$tt00 getMaximum]

set tt000 [pw::Examine create ConnectorEdgeLength]
$tt000 addEntity $fte2cs
$tt000 examine
set tt000v [$tt000 getMaximum]

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
set tail8seg [pw::DistributionGeneral create [list [lindex $wigu_tail 1]]]
$tail8seg setBeginSpacing 0
$tail8seg setEndSpacing 0
$tail8seg setVariable [[$confu1_con getDistribution 1] getVariable]
$confu1_con setDistribution -lockEnds 1 $tail8seg
[$confu1_con getDistribution 1] setBeginSpacing $tt00v

#tail 4
$confu2_con setDimension [$confu1_con getDimension]
set tail10seg [pw::DistributionGeneral create [list $confu1_con]]
$tail10seg setBeginSpacing 0
$tail10seg setEndSpacing 0
$tail10seg setVariable [[$confu2_con getDistribution 1] getVariable]
$confu2_con setDistribution -lockEnds 1 $tail10seg
[$confu2_con getDistribution 1] setBeginSpacing $tt000v

#tail 5
[lindex $conl_tail 3] setDimension [$confu2_con getDimension]
set tail9seg [pw::DistributionGeneral create [list $confu2_con]]
$tail9seg setBeginSpacing 0
$tail9seg setEndSpacing 0
$tail9seg setVariable [[[lindex $conl_tail 3] getDistribution 1] getVariable]
[lindex $conl_tail 3] setDistribution -lockEnds 1 $tail9seg
#[[lindex $conl_tail 3] getDistribution 1] reverse

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

[[lindex $conu_tail 2] getDistribution 1] setBeginSpacing $ts0v
[[lindex $con_consp 1] getDistribution 1] setBeginSpacing $ts1v
[[lindex $con_consp 1] getDistribution 1] setEndSpacing $ts2v
[[lindex $conl_tail 0] getDistribution 1] setEndSpacing $ts3v
[[lindex $conl_tail 3] getDistribution 1] setBeginSpacing $ts4v
[[lindex $conl_tail 1] getDistribution 1] setEndSpacing $ts6v

set reg2_con5sp [$reg2_con5 split [list [$reg2_con5 getParameter -arc 0.4]]]

[lindex $reg2_con5sp 0] setDimension [$reg2_con3 getDimension]
set mid1seg [pw::DistributionGeneral create [list $reg2_con3]]
$mid1seg setBeginSpacing 0
$mid1seg setEndSpacing 0
$mid1seg setVariable [[[lindex $reg2_con5sp 0] getDistribution 1] getVariable]
[lindex $reg2_con5sp 0] setDistribution -lockEnds 1 $mid1seg
[[lindex $reg2_con5sp 0] getDistribution 1] reverse
[[lindex $reg2_con5sp 0] getDistribution 1] setBeginSpacing $r3v3s

[lindex $reg2_con5sp 1] setDimension [$reg1_con3 getDimension]
set mid2seg [pw::DistributionGeneral create [list $reg1_con3]]
$mid2seg setBeginSpacing 0
$mid2seg setEndSpacing 0
$mid2seg setVariable [[[lindex $reg2_con5sp 1] getDistribution 1] getVariable]
[lindex $reg2_con5sp 1] setDistribution -lockEnds 1 $mid2seg

set ts5 [pw::Examine create ConnectorEdgeLength]
$ts5 addEntity [lindex $reg2_con5sp 1]
$ts5 examine
set ts5v [$ts5 getValue [lindex $reg2_con5sp 1] 1]
[[lindex $reg2_con5sp 0] getDistribution 1] setEndSpacing $ts5v
[[lindex $reg2_con5sp 1] getDistribution 1] setEndSpacing $texrv

$conwups addPoint [[[lindex $conu_tail 2] getNode Begin] getXYZ]
$conwups addPoint [[$wu getNode End] getXYZ]
set conwup [pw::Connector create]
$conwup addSegment $conwups
$conwup setDimension [expr int ([$reg2_con2 getDimension]+[$ste getDimension]+[$reg1_con1 getDimension]-2)]
[$conwup getDistribution 1] setBeginSpacing $texrv
[$conwup getDistribution 1] setEndSpacing $r3v2s
[[lindex $wigu_tail 0] getDistribution 1] setBeginSpacing $r3v2s

$confups addPoint [[[lindex $wigu_tail 0] getNode End] getXYZ]
$confups addPoint [[$fu getNode Begin] getXYZ]
$confups setSlope Free
$confups setSlopeOut 1 {-0.0041514327332810019 -0.010146243817996295 0}
$confups setSlopeIn 2 {0.023335818788357665 0.0081820871141068396 0}
set confup [pw::Connector create]
$confup addSegment $confups
$confup setDimension [expr int ([$reg3_con2 getDimension]+[$wte getDimension]-1)]
[$confup getDistribution 1] setBeginSpacing $r3v2s
[$confup getDistribution 1] setEndSpacing $tt00v

#=====================================================TAIL BLOCKs===================================
# ./1 blk1-1
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

# ./1 blk1-2
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

# ./2 blk2-1
set edge21 [pw::Edge create]
	$edge21 addConnector [lindex $wigu_tail 0]
set edge22 [pw::Edge create]
	$edge22 addConnector $confup
set edge23 [pw::Edge create]
	$edge23 addConnector [lindex $con_flapsp 0]
set edge24 [pw::Edge create]
	$edge24 addConnector $reg3_con2
	$edge24 addConnector $wte
set blk2 [pw::DomainStructured create]
	$blk2 addEdge $edge21
	$blk2 addEdge $edge22
	$blk2 addEdge $edge23
	$blk2 addEdge $edge24

# ./2 blk2-2
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

# ./3 blk3
set edge31 [pw::Edge create]
	$edge31 addConnector $reg1_con3
	$edge31 addConnector $reg2_con3
set edge32 [pw::Edge create]
	$edge32 addConnector [lindex $con_alsp 0]
	$edge32 addConnector $reg3_con3
set edge33 [pw::Edge create]
	$edge33 addConnector [lindex $reg2_con5sp 0]
	$edge33 addConnector [lindex $reg2_con5sp 1]
set edge34 [pw::Edge create]
	$edge34 addConnector [lindex $conl_tail 1]
	$edge34 addConnector [lindex $conl_tail 0]
set blk3 [pw::DomainStructured create]
	$blk3 addEdge $edge31
	$blk3 addEdge $edge32
	$blk3 addEdge $edge33
	$blk3 addEdge $edge34

# ./4 blk4
set edge41 [pw::Edge create]
	$edge41 addConnector $fte
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
	
# ./5 blk5
set edge51 [pw::Edge create]
	$edge51 addConnector $fl
	$edge51 addConnector $confu2_con
set edge52 [pw::Edge create]
	$edge52 addConnector [lindex $end_consp 3]
set edge53 [pw::Edge create]
	$edge53 addConnector [lindex $conl_tail 3]
	$edge53 addConnector [lindex $conl_tail 2]
set edge54 [pw::Edge create]
	$edge54 addConnector [lindex $reg2_con5sp 1]
	$edge54 addConnector [lindex $reg2_con5sp 0]
set blk5 [pw::DomainStructured create]
	$blk5 addEdge $edge51
	$blk5 addEdge $edge52
	$blk5 addEdge $edge53
	$blk5 addEdge $edge54

##=========================================================solve domains======================================

#set dsolve [pw::Application begin EllipticSolver [list $r1_blk2 $dom_blk3 $r3_blk3 $blk1 $blk2 $blk3 $blk4 $blk5]]
#foreach ent [list $r1_blk2 $r1_blk2 $r1_blk2 $r1_blk2 $dom_blk3 $dom_blk3 $dom_blk3 $dom_blk3 $r3_blk3 $r3_blk3 $r3_blk3 $r3_blk3 $blk1 $blk1 $blk1 $blk1 $blk2 $blk2 $blk2 $blk2 $blk3 $blk3 $blk3 $blk3 $blk4 $blk4 $blk4 $blk4 $blk5 $blk5 $blk5 $blk5] bc [list 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4] {
#	$ent setEllipticSolverAttribute -edge $bc EdgeConstraint Floating
#}
#foreach ent [list $blk5 $blk2 $blk3 $blk4] bc [list 4 3 3 2] {
#	$ent setEllipticSolverAttribute -edge $bc EdgeConstraint Fixed
#}
#$dsolve setActiveSubGrids $r1_blk2 [list]
#$dsolve setActiveSubGrids $dom_blk3 [list]
#$dsolve setActiveSubGrids $r3_blk3 [list]
#$dsolve setActiveSubGrids $blk1 [list]
#$dsolve setActiveSubGrids $blk2 [list]
#$dsolve setActiveSubGrids $blk3 [list]
#$dsolve setActiveSubGrids $blk4 [list]
#$dsolve setActiveSubGrids $blk5 [list]
#$dsolve run 3000
#$dsolve end

## =====================================================OUTTER DOMAIN EXTRUSION====================================

source [file join $scriptDir "extr.glf"]