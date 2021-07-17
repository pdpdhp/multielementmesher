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

package require PWI_Glyph 3.18.3

#MULTI-ELEMENT CONFIGURATION:
#--------------------------------------------
#multi-element airfoil selection (CRMHL-2D or 30P30N)
#Currently only 2D CRM-HL WING SECTION is supported!
set airfoil CRMHL-2D

#GRID REFINEMENT LEVEL:
#====================================================
#Grid Levels vary from the first line (finest, level 0) of the grid_specification.txt to the last line (coarsest, level 6)!
set res_lev 2

#GRID SYSTEM'S ARRANGEMENT: STRUCTURED OR UNSTRUCTRED
#====================================================
#PLEASE SELECT GRID SYSTEM: STR (for STRUCTURED) | UNSTR (for UNSTRUCTURED)
set GRD_TYP UNSTR

# UNSTRUCTURED SETTINGS:
#====================================================
#UNSTRUCTRED GRID PROPERTIES FOR GRD_TYP: UNSTR
#----------------------------------------------------
#UNSTRUCTURED SOLVER ALGORITHM: AdvancingFront | AdvancingFrontOrtho | Delaunay
set UNS_ALG AdvancingFrontOrtho

#UNSTRUCTRED SOLVER CELL TYPE: TriangleQuad | Triangle
set UNS_CTYP TriangleQuad

#GENERAL DECAY FACTOR FOR UNSTRUCTRED SOLVER
set SIZE_DCY 0.6

# STRUCTURED SETTINGS:
#====================================================
#GLOBAL AND LOCAL SMOOTHER FOR GRD_TYP: STR
#----------------------------------------------------
# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS EXCLUDING BOUNDARY LAYERS. (YES/NO)
set global_smth YES

# NUMBER OF ITERATIONS FOR GLOBAL ELLIPTIC SOLVER
# (>1000 is recommended)
set gsmthiter 1000

# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS | RUNS ONLY IF GLOBAL SMOOTHER IS OFF | INCLUDES NEAR CONFIG DOMAINS. (YES/NO)
set local_smth NO

# NUMBER OF ITERATIONS TO RUN LOCAL ELLIPTIC SOLVER.
# (>1000 is recommended)
set lsmthiter 2000

# GENERAL SETTINGS:
#==================================================
#GROWTH RATIOS:
#--------------------------------------------------
#general chordwise growth ratio for node distribution over the wing, flap, and slat.
set srfgr 1.25

#chordwise growth ratio for node distribution over the wing's lower surface.
set srfgrwl 1.2

#chordwise growth ratio for node distribution over the slat's upper surface.
set srfgrfu 1.2

# GRID DIMENSION:
#===================================================
#2D DIMENSIONAL MESH (YES/NO)
set model_2D YES

#QUASI 2D MESH | GENERATES AN EXTRUDED VERSION (YES/NO)
set model_Q2D NO

#SPAN DIMENSION FOR QUASI 2D MODEL IN -Y DIRECTION | MAXIMUM 3.0
set span 1.0

#Fix number of points in spanwise direction? If YES, indicate number of points below. (YES/NO)
set fixed_snodes YES

#Number of points in spanwise direction. If you opt NO above, This parameter will be ignored
# and will be set automatically based on maximum spacing over wing, slat and flap.
set span_dimension 4

#CAE EXPORT:
#===================================================
#CAE SOLVER SELECTION. (Exp. SU2 or CGNS)
set cae_solver CGNS

#POLYNOMIAL DEGREE FOR HIGH ORDER MESH EXPORT (Q1:Linear - Q4:quartic) | FOR SU2 ONLY Q1
set POLY_DEG Q2

#USING HIGH ORDER GRID GUIDELINE SPECIFICATION IN GUIDELINE DIR (YES/NO)
set HO_GEN NO

#ENABLES CAE EXPORT (YES/NO)
set cae_export NO

#SAVES NATIVE FORMATS (YES/NO)
set save_native YES

#INITIAL GROWTH RATIOS FOR NODE DISTRIBUTION:
#===================================================
# region 1 con 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr 1.09

# region 2 con 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr 1.09

# region 3 con 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr 1.09

##=============================================================================================================
#Importing Meshing Guidline generated based on the flow condition!

set scriptDir [file dirname [info script]]

set guidelineDir [file join $scriptDir guideline]

file mkdir $guidelineDir

set geoDir [file join $scriptDir geo]

file mkdir $geoDir

#Importing Meshing Guidline

if {[string compare $HO_GEN YES]==0} {
	set fp [open "$guidelineDir/grid_specification_HO.txt" r]
} else {
	set fp [open "$guidelineDir/grid_specification_metric.txt" r]
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

if {$res_lev<$NUM_REF} {
	set ypg [lindex $y_p $res_lev]
	set dsg [lindex $d_s $res_lev]
	set grg [lindex $gr $res_lev]
	set chord_sg [lindex $chord_s $res_lev]
	set ter_sg [lindex $ter $res_lev]
	set ler_sg [lindex $ler $res_lev]
	set tpts1_sg [lindex $tpt1 $res_lev]
	set tpts2_sg [lindex $tpt2 $res_lev]
	set exp_sg [lindex $exp $res_lev]
	set imp_sg [lindex $imp $res_lev]
	set vol_sg [lindex $vol $res_lev]
	set stp_sg [lindex $extr $res_lev]
} else {

	puts "PLEASE SELECT THE RIGHT REFINEMENT LEVEL ACCORDING TO YOUR GUIDELINE FILE: res_lev"
	break

}

set symsep [string repeat = 88]
set symsepd [string repeat . 88]
set symsepdd [string repeat - 88]

puts "GRID GUIDELINE: Y+: $ypg | Delta_S(m): $dsg | GR: $grg | Chordwise_Spacing(m): $chord_sg"
puts $symsep

set time_start [pwu::Time now]

source [file join $scriptDir "topoprepare.glf"]

# Boundary blocks division:
#----------------------------------------------------------------------------
set a_domsp [$a_dom split -I [list [$wte getDimension] [expr [$wu getDimension]+[$wte getDimension]-1]\
		 [expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]-2]\
			[expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]+[[lindex $conupsp 2] getDimension]+[[lindex $conupsp 1] getDimension]-4]\
				[expr [$wu getDimension]+[$wte getDimension]+[[lindex $con_alsp 1] getDimension]+[[lindex $conupsp 2] getDimension]+\
					[[lindex $conupsp 1] getDimension]+[[lindex $conupsp 0] getDimension]-5]]]

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
if {[string compare $GRD_TYP STR]==0} {
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
set midSpc [expr [$tt0 getMaximum]*[lindex $maxmidspc $res_lev]]
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

if {[string compare $GRD_TYP STR]==0} {
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

#=========================================================solve domains======================================
# running structured solver over structured domains surrounding the configuration -- local_smth turns it off!
if {[string compare $local_smth YES]==0 && [string compare $GRD_TYP STR]==0 && \
							[string compare $global_smth NO]==0} {
	set dsolve [pw::Application begin EllipticSolver $doms]
	set dom_dsolve []
	set bc_dsolve []
	for {set i 0} {$i<[llength $doms]} {incr i} {
		lappend dom_dsolve [lindex $doms $i]
		lappend dom_dsolve [lindex $doms $i]
		lappend dom_dsolve [lindex $doms $i]
		lappend dom_dsolve [lindex $doms $i]
		lappend bc_dsolve 1
		lappend bc_dsolve 2
		lappend bc_dsolve 3
		lappend bc_dsolve 4
	}
	
	foreach elm $dom_dsolve bc $bc_dsolve {
		$elm setEllipticSolverAttribute -edge $bc EdgeConstraint Floating
	}
	
	foreach elm $adjdoms bc $adjbcs {
		$elm setEllipticSolverAttribute -edge $bc EdgeSpacingCalculation Adjacent
	}
	
	foreach elm $fixdoms bc $fixbcs {
		$elm setEllipticSolverAttribute -edge $bc EdgeConstraint Fixed
	}
	
	foreach elm $doms {
		$dsolve setActiveSubGrids $elm [list]
	}
	
	$dsolve run $lsmthiter
	$dsolve end
	
	puts $symsepd
	puts "LOCAL ELLIPTIC SOLVER FINISHED $lsmthiter ITERATIONS OVER [llength $doms] STRUCTURED DOMAINS"
	puts $symsepdd
}

#=====================================================OUTTER DOMAIN EXTRUSION====================================

source [file join $scriptDir "extrusion.glf"]


if {[string compare $GRD_TYP UNSTR]==0} {
	pw::Display setCurrentLayer 40
	
	set diagcol [pw::Collection create]
	$diagcol set $smthd
	set diag [pw::Application begin Create]
	set triandoms [$diagcol do triangulate Initialized]
	$diag end
	pw::Entity delete $smthd
	
	set smthd [pw::Grid getAll -type pw::DomainUnstructured]
	
	set flaptail [pw::Examine create ConnectorEdgeLength]
	$flaptail addEntity $confu2_con
	$flaptail examine
	set flaptailv [$flaptail getValue $confu2_con [expr [$confu2_con getDimension]-1]]
	
	set fronttail [pw::Examine create ConnectorEdgeLength]
	$fronttail addEntity [[[lindex $smthd 8] getEdge 1] getConnector 1]
	$fronttail examine
	set fronttailv [$fronttail getValue [[[lindex $smthd 8] getEdge 1] getConnector 1] 1]
	
	set domfarbc []
	set confarbc []
	
	set downstreamcons []
	lappend downstreamcons [[[lindex $smthd 1] getEdge 1] getConnector 5]
	lappend domfarbc [lindex $smthd 1]
	
	lappend downstreamcons [[[lindex $smthd 2] getEdge 1] getConnector 3]
	lappend domfarbc [lindex $smthd 2]
	
	lappend downstreamcons [[[lindex $smthd 8] getEdge 1] getConnector 3]
	lappend domfarbc [lindex $smthd 8]
	
	foreach cons $downstreamcons {
		lappend confarbc $cons
		$cons setDimensionFromSpacing $flaptailv
		$cons replaceDistribution 1 [pw::DistributionTanh create]
		[$cons getDistribution 1] setBeginSpacing 0.0
		[$cons getDistribution 1] setEndSpacing 0.0
	}
	
	set upstreamcons []
	lappend upstreamcons [[[lindex $smthd 2] getEdge 1] getConnector 4]
	lappend upstreamcons [[[lindex $smthd 3] getEdge 1] getConnector 4]
	lappend upstreamcons [[[lindex $smthd 4] getEdge 1] getConnector 8]
	lappend upstreamcons [[[lindex $smthd 5] getEdge 1] getConnector 4]
	lappend upstreamcons [[[lindex $smthd 6] getEdge 1] getConnector 4]
	lappend upstreamcons [[[lindex $smthd 7] getEdge 1] getConnector 4]
	lappend upstreamcons [[[lindex $smthd 8] getEdge 1] getConnector 2]
	
	foreach cons $upstreamcons {
		lappend domfarbc [lindex $smthd [expr [lsearch $upstreamcons $cons]+2]]
		lappend confarbc $cons
		$cons setDimensionFromSpacing $fronttailv
		$cons replaceDistribution 1 [pw::DistributionTanh create]
		[$cons getDistribution 1] setBeginSpacing 0.0
		[$cons getDistribution 1] setEndSpacing 0.0
	}

	[[lindex $upstreamcons 0] getDistribution 1] setBeginSpacing $flaptailv
	[[lindex $upstreamcons 0] getDistribution 1] setEndSpacing $fronttailv
	[lindex $upstreamcons 0] setSubConnectorDimensionFromDistribution 1
	
	[[lindex $upstreamcons 6] getDistribution 1] setBeginSpacing $flaptailv
	[[lindex $upstreamcons 6] getDistribution 1] setEndSpacing $fronttailv
	[lindex $upstreamcons 6] setSubConnectorDimensionFromDistribution 1
	
	#size field defination
	set radius [list 1.5 4.5 13.5 40.5 121.5]
	
	set levspc [expr [$wu getAverageSpacing]*2]
	lappend decayfactor 0.99
	
	for {set i 0} {$i<6} {incr i} {
		lappend spcfactor [expr $levspc*(($i)**3+1)]
		lappend decayfactor [expr [lindex $decayfactor $i]-0.1]
	}
	
	for {set i 0} {$i<5} {incr i} {
		lappend sourcesh [pw::SourceShape create]
		[lindex $sourcesh $i] cylinder -radius [lindex $radius $i] -length 0

		[lindex $sourcesh $i] setTransform [list 1 -0 0 0 0 1 0 0 -0 -0 1 0 0.5 0 0 1]
		[lindex $sourcesh $i] setPivot Base
		[lindex $sourcesh $i] setSectionMinimum 0
		[lindex $sourcesh $i] setSectionMaximum 360
		[lindex $sourcesh $i] setSidesType Plane
		[lindex $sourcesh $i] setBaseType Plane
		[lindex $sourcesh $i] setTopType Plane
		[lindex $sourcesh $i] setEnclosingEntities {}
		[lindex $sourcesh $i] setSpecificationType AxisToPerimeter
		[lindex $sourcesh $i] setBeginSpacing [lindex $spcfactor $i]
		[lindex $sourcesh $i] setBeginDecay [lindex $decayfactor $i]
		[lindex $sourcesh $i] setEndSpacing [lindex $spcfactor [expr $i+1]]
		[lindex $sourcesh $i] setEndDecay [lindex $decayfactor [expr $i+1]]
	}
	
	set unstrsolve [pw::Application begin UnstructuredSolver $smthd]
	
	foreach dom $smthd {
		$dom setSizeFieldDecay $SIZE_DCY
			foreach edge [$dom getEdges] {
				for {set i 1} {$i <= [$edge getConnectorCount]} {incr i} {
					lappend unstrbcs [list $dom [$edge getConnector $i] [$edge getConnectorOrientation $i]]
				}
			}
	}
	
	set unstrbcondition [pw::TRexCondition create]
	$unstrbcondition setName adapts
	$unstrbcondition apply $unstrbcs
	$unstrbcondition setAdaptation On
	
	set UnsCol [pw::Collection create]
	$UnsCol set $smthd
	$UnsCol do setUnstructuredSolverAttribute Algorithm $UNS_ALG
	$UnsCol do setUnstructuredSolverAttribute IsoCellType $UNS_CTYP
	$unstrsolve run Initialize
	$unstrsolve end
	
	foreach dom $smthd {
		lappend ncells [$dom getCellCount]
	}

}


#=================================================CAE Export--=====================================================

set fexmod [open "$scriptDir/output.txt" w]

# gathering all domains
set alldoms [list {*}$bldoms {*}$smthd]

# creating general boundary conditions
set bcslat [pw::BoundaryCondition create]
	$bcslat setName slat
set bcwing [pw::BoundaryCondition create]
	$bcwing setName wing
set bcflap [pw::BoundaryCondition create]
	$bcflap setName flap
set bcfar [pw::BoundaryCondition create]
	$bcfar setName farfield

set dashes [string repeat - 50]

if {[string compare $cae_solver CGNS]==0} {
	pw::Application setCAESolverAttribute CGNS.FileType adf
	pw::Application setCAESolverAttribute ExportPolynomialDegree $POLY_DEG
}

if {[string compare $model_2D YES]==0} {
	
	#assigning BCs
	foreach con $conslatbc dom $domslatbc {
		$bcslat apply [list [list $dom $con]]
	}
	
	foreach con $conwingbc dom $domwingbc {
		$bcwing apply [list [list $dom $con]]
	}
	
	foreach con $conflapbc dom $domflapbc {
		$bcflap apply [list [list $dom $con]]
	}
	
	foreach con $confarbc dom $domfarbc {
		$bcfar apply [list [list $dom $con]]
	}
	
	set ncell [expr [join $ncells +]]
	set gorder [string length $ncell]

	if {$gorder<6} {
		set gridID "[string range $ncell 0 1]k"
	} elseif {$gorder>=6 && $gorder<7} {
		set gridID "[string range $ncell 0 2]k"
	} elseif {$gorder>=7 && $gorder<10} {
		set gridID "[string range [expr $ncell/1000000] 0 2]m[string range [expr int($ncell%1000000)] 0 2]k"
	} elseif {$gorder>=10 && $gorder<13} {
		set gridID "[string range [expr $ncell/1000000000] 0 2]b[string range [expr int($ncell%1000000000)] 0 2]m"
}

	append gridname lev $res_lev "_" $gridID
	
	puts $fexmod [string repeat - 50]
	
	if {[string compare $GRD_TYP UNSTR]==0} {
		puts $fexmod "2D MULTIBLOCK UNSTRUCTURED GRID | 2D CRM HIGH-LIFT CONFIG | GRID LEVEL $res_lev:"
		puts "2D GRID GENERATED FOR LEVEL $res_lev | TOTAL CELLS: $ncell CELLS"
		puts $symsepdd
	} else {
		puts $fexmod "2D MULTIBLOCK STRUCTURED GRID | 2D CRM HIGH-LIFT CONFIG | GRID LEVEL $res_lev:"
		puts "2D GRID GENERATED FOR LEVEL $res_lev | TOTAL CELLS: $ncell QUADS"
		puts $symsepdd
	}

	puts $fexmod [string repeat - 50]
	puts $fexmod "total domains: [llength $ncells]"
	puts $fexmod "total cells: $ncell cells"
	puts $fexmod "min area: [format "%*e" 5 $domexmv]"
	
	if {[string compare $cae_export YES]==0} {
		# creating export directory
		set exportDir [file join $scriptDir grids/2d]

		file mkdir $exportDir
		
		puts $fexmod [string repeat - 50]
		# CAE specificity in the output file!
		puts $fexmod "Current solver: [set curSolver [pw::Application getCAESolver]]"

		set validExts [pw::Application getCAESolverAttribute FileExtensions]
		puts $fexmod "Valid file extensions: '$validExts'"

		set defExt [lindex $validExts 0]

		set caex [pw::Application begin CaeExport $alldoms]

		set destType [pw::Application getCAESolverAttribute FileDestination]
		switch $destType {
			Filename { set dest [file join $exportDir "$gridname.$defExt"] }
			Folder   { set dest $exportDir }
			default  { return -code error "Unexpected FileDestination value" }
		}
		puts $fexmod "Exporting to $destType: '$dest'"
		puts $fexmod [string repeat - 50]

		# Initialize the CaeExport mode
		set status abort  ;
		if { ![$caex initialize $dest] } {
			puts $fexmod {$caex initialize failed!}
		} else {
			if { ![catch {$caex setAttribute FilePrecision Double}] } {
				puts $fexmod "setAttribute FilePrecision Double"
			}

			if { ![$caex verify] } {
				puts $fexmod {$caex verify failed!}
			} elseif { ![$caex canWrite] } {
				puts $fexmod {$caex canWrite failed!}
			} elseif { ![$caex write] } {
				puts $fexmod {$caex write failed!}
			} elseif { 0 != [llength [set feCnts [$caex getForeignEntityCounts]]] } {
			# print entity counts reported by the exporter
			set fmt {   %-22.22s | %6.6s |}
			puts $fexmod "Number of grid entities exported:"
			puts $fexmod [format $fmt {Entity Type} Count]
			puts $fexmod [format $fmt $dashes $dashes]
			dict for {key val} $feCnts {
				puts $fexmod [format $fmt $key $val]
			}
			set status end ;# all is okay now
			}
		}

		# Display any errors/warnings
		set errCnt [$caex getErrorCount]
		for {set ndx 1} {$ndx <= $errCnt} {incr ndx} {
			puts $fexmod "[$caex getErrorCode $ndx]: '[$caex getErrorInformation $ndx]'"
		}
		# abort/end the CaeExport mode
		$caex $status
	
		puts "info: 2D GRID: $gridname.$defExt EXPORTED IN GRID DIR."
	}

	if {[string compare $save_native YES]==0} {
		set exportDir [file join $scriptDir grids/2d]
		file mkdir $exportDir
		pw::Application save "$exportDir/$gridname.pw"
	
		puts "info: NATIVE FORMAT: $gridname.pw SAVED IN GRID DIR."
	}

}

if {[string compare $model_Q2D YES]==0} {
	pw::Application setCAESolver $cae_solver 3

	#grid tolerance
	pw::Grid setNodeTolerance 1.0e-10
	pw::Grid setConnectorTolerance 1.0e-10
	pw::Grid setGridPointTolerance 1.0e-10
	
	set fstr [pw::FaceStructured createFromDomains $alldoms]
	
	set spanSpc [pw::Examine create ConnectorEdgeLength]
	$spanSpc addEntity $wu
	$spanSpc addEntity $su
	$spanSpc addEntity [lindex $con_fusp 0]
	$spanSpc examine
	set spanSpcv [$spanSpc getMaximum]
	set trnstp [expr int($span/$spanSpcv)]
	
	for {set i 0} {$i<[llength $fstr]} {incr i} {
		lappend blk [pw::BlockStructured create]
		[lindex $blk $i] addFace [lindex $fstr $i]
	}

	set domtrn [pw::Application begin ExtrusionSolver $blk]
	
	foreach bl $blk {
		$bl setExtrusionSolverAttribute Mode Translate
		$bl setExtrusionSolverAttribute TranslateDirection {0 0 1}
		$bl setExtrusionSolverAttribute TranslateDistance $span
	}
	
	if {[string compare $fixed_snodes NO]==0} {
		$domtrn run $trnstp
		$domtrn end
	} else {
		$domtrn run [expr $span_dimension-1]
		if {[string compare [lindex [$domtrn getRunResult] 0] Completed]!=0} {
			puts "TRANSLATE EXTRUSION FAILED! PLEASE TRUN ON THE GLOBAL SMOOTHER WITH PROPER NUMBER OF ITERATIONS TO PREVENT THIS!"
			$domtrn end
			break
		}
		$domtrn end
	}
	
	pw::Entity transform [pwu::Transform rotation -anchor {0 0 0} {1 0 0} 90] [pw::Grid getAll]
	pw::Display hideAllLayers
	
	#assigning BCs
	#CAE Boundary Condition
	set domslatqbc []
	set blkslatqbc []
	set domwingqbc []
	set blkwingqbc []
	set domflapqbc []
	set blkflapqbc []
	set domrightqbc []
	set blkrightqbc []
	set domleftqbc []
	set blkleftqbc []
	
	array set dommwingqbc []
	array set dommrightqbc []
	array set dommleftqbc []
	array set dommfarqbc []
	set k 1
	
	for {set k 1} {$k<=[llength $blk]} {incr k} {
		set dommrightqbc($k) []
		set dommleftqbc($k) []
		set dommwingqbc($k) []
		set dommslatqbc($k) []
		set dommflapqbc($k) []
		set dommfarqbc($k) []
	}
	
	# finding proper domains and blocks corresponding to BCs
	#block 0
	set dommwingqbc(1) [[[lindex $blk 0] getFace 3] getDomains]
	set dommrightqbc(1) [[[lindex $blk 0] getFace 6] getDomains]
	set dommleftqbc(1) [[[lindex $blk 0] getFace 1] getDomains]
	
	foreach ent $dommwingqbc(1) {
		lappend domwingqbc $ent
		lappend blkwingqbc [lindex $blk 0]
	}
	
	foreach ent $dommrightqbc(1) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 0]
	}
	
	foreach ent $dommleftqbc(1) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 0]
	}
	
	#block 1
	set dommrightqbc(2) [[[lindex $blk 1] getFace 6] getDomains]
	set dommleftqbc(2) [[[lindex $blk 1] getFace 1] getDomains]
	set dommfarqbc(1) [[[lindex $blk 1] getFace 2] getDomains]
	set dommfarqbc(2) [[[lindex $blk 1] getFace 5] getDomains]
	
	foreach ent $dommrightqbc(2) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 1]
	}
	
	foreach ent $dommleftqbc(2) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 1]
	}
	
	foreach ent $dommfarqbc(1) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 1]
	}
	
	foreach ent $dommfarqbc(2) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 1]
	}
	
	#block 2
	set dommrightqbc(3) [[[lindex $blk 2] getFace 6] getDomains]
	set dommleftqbc(3) [[[lindex $blk 2] getFace 1] getDomains]
	set dommslatqbc(1) [[[lindex $blk 2] getFace 3] getDomains]
	
	foreach ent $dommrightqbc(3) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 2]
	}
	
	foreach ent $dommleftqbc(3) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 2]
	}
	
	foreach ent $dommslatqbc(1) {
		lappend domslatqbc $ent
		lappend blkslatqbc [lindex $blk 2]
	}
	
	#block 3
	set dommrightqbc(4) [[[lindex $blk 3] getFace 6] getDomains]
	set dommleftqbc(4) [[[lindex $blk 3] getFace 1] getDomains]
	set dommfarqbc(3) [[[lindex $blk 3] getFace 2] getDomains]
	
	foreach ent $dommrightqbc(4) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 3]
	}
	
	foreach ent $dommleftqbc(4) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 3]
	}
	
	foreach ent $dommfarqbc(3) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 3]
	}
	
	#block 4
	set dommrightqbc(5) [[[lindex $blk 4] getFace 6] getDomains]
	set dommleftqbc(5) [[[lindex $blk 4] getFace 1] getDomains]
	set dommslatqbc(2) [[[lindex $blk 4] getFace 3] getDomains]
	
	foreach ent $dommrightqbc(5) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 4]
	}
	
	foreach ent $dommleftqbc(5) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 4]
	}
	
	foreach ent $dommslatqbc(2) {
		lappend domslatqbc $ent
		lappend blkslatqbc [lindex $blk 4]
	}
	
	#block 5
	set dommrightqbc(6) [[[lindex $blk 5] getFace 6] getDomains]
	set dommleftqbc(6) [[[lindex $blk 5] getFace 1] getDomains]
	set dommfarqbc(4) [[[lindex $blk 5] getFace 5] getDomains]
	
	foreach ent $dommrightqbc(6) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 5]
	}
	
	foreach ent $dommleftqbc(6) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 5]
	}
	
	foreach ent $dommfarqbc(4) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 5]
	}
	
	#block 6
	set dommrightqbc(7) [[[lindex $blk 6] getFace 6] getDomains]
	set dommleftqbc(7) [[[lindex $blk 6] getFace 1] getDomains]
	set dommflapqbc(1) [[[lindex $blk 6] getFace 3] getDomains]
	
	foreach ent $dommrightqbc(7) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 6]
	}
	
	foreach ent $dommleftqbc(7) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 6]
	}
	
	foreach ent $dommflapqbc(1) {
		lappend domflapqbc $ent
		lappend blkflapqbc [lindex $blk 6]
	}
	
	#block 7
	set dommrightqbc(8) [[[lindex $blk 7] getFace 6] getDomains]
	set dommleftqbc(8) [[[lindex $blk 7] getFace 1] getDomains]
	set dommfarqbc(5) [[[lindex $blk 7] getFace 4] getDomains]
	
	foreach ent $dommrightqbc(8) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 7]
	}
	
	foreach ent $dommleftqbc(8) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 7]
	}
	
	foreach ent $dommfarqbc(5) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 7]
	}
	
	#block 8
	set dommrightqbc(9) [[[lindex $blk 8] getFace 6] getDomains]
	set dommleftqbc(9) [[[lindex $blk 8] getFace 1] getDomains]
	set dommfarqbc(6) [[[lindex $blk 8] getFace 5] getDomains]
	
	
	foreach ent $dommrightqbc(9) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 8]
	}
	
	foreach ent $dommleftqbc(9) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 8]
	}
	
	foreach ent $dommfarqbc(6) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 8]
	}
	
	
	#blcok 9
	set dommrightqbc(10) [[[lindex $blk 9] getFace 6] getDomains]
	set dommleftqbc(10) [[[lindex $blk 9] getFace 1] getDomains]
	set dommfarqbc(7) [[[lindex $blk 9] getFace 4] getDomains]
	
	foreach ent $dommrightqbc(10) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 9]
	}
	
	foreach ent $dommleftqbc(10) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 9]
	}
	
	foreach ent $dommfarqbc(7) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 9]
	}
	
	#block 10
	set dommrightqbc(11) [[[lindex $blk 10] getFace 6] getDomains]
	set dommleftqbc(11) [[[lindex $blk 10] getFace 1] getDomains]
	set dommfarqbc(8) [[[lindex $blk 10] getFace 5] getDomains]
	set dommfarqbc(9) [[[lindex $blk 10] getFace 2] getDomains]
	
	foreach ent $dommrightqbc(11) {
		lappend domrightqbc $ent
		lappend blkrightqbc [lindex $blk 10]
	}
	
	foreach ent $dommleftqbc(11) {
		lappend domleftqbc $ent
		lappend blkleftqbc [lindex $blk 10]
	}
	
	foreach ent $dommfarqbc(8) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 10]
	}

	foreach ent $dommfarqbc(9) {
		lappend domfarqbc $ent
		lappend blkfarqbc [lindex $blk 10]
	}
	
	#assigning domains to BCs
	foreach domain $domslatqbc block $blkslatqbc {
		$bcslat apply [list [list $block $domain]]
	}

	foreach domain $domwingqbc block $blkwingqbc {
		$bcwing apply [list [list $block $domain]]
	}
	
	foreach domain $domflapqbc block $blkflapqbc {
		$bcflap apply [list [list $block $domain]]
	}

	set bcright [pw::BoundaryCondition create]
	$bcright setName plane_right
	foreach domain $domrightqbc block $blkrightqbc {
		$bcright apply [list [list $block $domain]]
	}

	set bcleft [pw::BoundaryCondition create]
	$bcleft setName plane_left
	foreach domain $domleftqbc block $blkleftqbc {
		$bcleft apply [list [list $block $domain]]
	}
	
	foreach domain $domfarqbc block $blkfarqbc {
		$bcfar apply [list [list $block $domain]]
	}
	
	set wsf_surfaces [pw::Collection create]
	$wsf_surfaces set [list {*}$domwingqbc {*}$domslatqbc {*}$domflapqbc]
	$wsf_surfaces do setLayer 30
	
	if {[string compare $POLY_DEG Q1]!=0} {
		pw::Display setCurrentLayer 10
		set tmp_model [pw::Application begin DatabaseImport]
		  $tmp_model initialize -strict -type Automatic $geoDir/crmhl2dcut_extr.iges
		  $tmp_model read
		  $tmp_model convert
		$tmp_model end
		unset tmp_model
		
		set dq_database [pw::Layer getLayerEntities -type pw::Quilt 10]
		
		pw::Entity project -type ClosestPoint [list {*}$domwingqbc {*}$domslatqbc {*}$domflapqbc] $dq_database
	}
	
	#examine
	set blkexm [pw::Examine create BlockVolume]
	$blkexm addEntity $blk
	$blkexm examine
	set blkexmv [$blkexm getMinimum]
	
	foreach bl $blk {
		lappend blkncells [$bl getCellCount]
	}
	
	set blkncell [expr [join $blkncells +]]
	set blkorder [string length $blkncell]

	if {$blkorder<6} {
		set blkID "[string range $blkncell 0 1]k"
	} elseif {$blkorder>=6 && $blkorder<7} {
		set blkID "[string range $blkncell 0 2]k"
	} elseif {$blkorder>=7 && $blkorder<10} {
		set blkID "[string range [expr $blkncell/1000000] 0 2]m[string range [expr int($blkncell%1000000)] 0 2]k"
	} elseif {$blkorder>=10 && $blkorder<13} {
		set blkID "[string range [expr $blkncell/1000000000] 0 2]b[string range [expr int($blkncell%1000000000)] 0 2]m"
}

	append 3dgridname lev $res_lev "_" $blkID
	
	puts $fexmod [string repeat - 50]
	puts $fexmod "QUASI 2D MULTIBLOCK STRUCTURED GRID | 2D CRM HIGH-LIFT CONFIG | GRID LEVEL $res_lev:"
	puts $fexmod [string repeat - 50]
	puts $fexmod "total blocks: [llength $blkncells]"
	puts $fexmod "total cells: $blkncell cells"
	puts $fexmod "min volume: [format "%*e" 5 $blkexmv]"
	
	puts $symsepdd
	puts "QUASI 2D GRID GENERATED FOR LEVEL $res_lev | TOTAL CELLS: $blkncell HEX"
	puts $symsepdd
	
	if {[string compare $cae_export YES]==0} {
		# creating export directory
		set exportDir [file join $scriptDir grids/2dquasi]

		file mkdir $exportDir
		
		puts $fexmod [string repeat - 50]
		# CAE specificity in the output file!
		puts $fexmod "Current solver: [set curSolver [pw::Application getCAESolver]]"

		set validExts [pw::Application getCAESolverAttribute FileExtensions]
		puts $fexmod "Valid file extensions: '$validExts'"

		set defExt [lindex $validExts 0]

		set caex [pw::Application begin CaeExport $blk]

		set destType [pw::Application getCAESolverAttribute FileDestination]
		switch $destType {
			Filename { set dest [file join $exportDir "$3dgridname.$defExt"] }
			Folder   { set dest $exportDir }
			default  { return -code error "Unexpected FileDestination value" }
		}
		puts $fexmod "Exporting to $destType: '$dest'"
		puts $fexmod [string repeat - 50]

		# Initialize the CaeExport mode
		set status abort  ;
		if { ![$caex initialize $dest] } {
			puts $fexmod {$caex initialize failed!}
		} else {
			if { ![catch {$caex setAttribute FilePrecision Double}] } {
				puts $fexmod "setAttribute FilePrecision Double"
			}

			if { ![$caex verify] } {
				puts $fexmod {$caex verify failed!}
			} elseif { ![$caex canWrite] } {
				puts $fexmod {$caex canWrite failed!}
			} elseif { ![$caex write] } {
				puts $fexmod {$caex write failed!}
			} elseif { 0 != [llength [set feCnts [$caex getForeignEntityCounts]]] } {
			# print entity counts reported by the exporter
			set fmt {   %-22.22s | %6.6s |}
			puts $fexmod "Number of grid entities exported:"
			puts $fexmod [format $fmt {Entity Type} Count]
			puts $fexmod [format $fmt $dashes $dashes]
			dict for {key val} $feCnts {
				puts $fexmod [format $fmt $key $val]
			}
			set status end ;# all is okay now
			}
		}

		# Display any errors/warnings
		set errCnt [$caex getErrorCount]
		for {set ndx 1} {$ndx <= $errCnt} {incr ndx} {
			puts $fexmod "[$caex getErrorCode $ndx]: '[$caex getErrorInformation $ndx]'"
		}
		# abort/end the CaeExport mode
		$caex $status
	
		puts "info: QUASI 2D GRID: $3dgridname.$defExt EXPORTED IN GRID DIR."
	}

	if {[string compare $save_native YES]==0} {
		set exportDir [file join $scriptDir grids/2dquasi]
		file mkdir $exportDir
		pw::Application save "$exportDir/$3dgridname.pw"
		
		puts "info: NATIVE FORMAT: $3dgridname.pw SAVED IN GRID DIR."
	}
}

set time_end [pwu::Time now]
set runtime [pwu::Time subtract $time_end $time_start]
set tmin [expr int([lindex $runtime 0]/60)]
set tsec [expr [lindex $runtime 0]%60]
set tmsec [expr int(floor([lindex $runtime 1]/1000))]

puts $fexmod [string repeat - 50]
puts $fexmod "runtime: $tmin min $tsec sec $tmsec ms" 
puts $fexmod [string repeat - 50]
close $fexmod

puts $dashes
puts "GRID INFO WRITTEN TO output.txt"
puts $symsep
puts "COMPLETE!"
