# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================
proc Source_Unstr { } {
	global smthd wu
	
	#size field defination
	set base_rad [list 0.4 0.8 1.6 3.2 6.4]
	set top_rad [list 0.25 0.5 1.0 2.0 4.0]
	set cyn_len [list 1.5 4.5 13.5 40.5 121.5]
	
	set levspc [expr [$wu getAverageSpacing]*0.75]
	lappend cyndecayfactor 0.99
	
	for {set i 0} {$i<6} {incr i} {
		lappend cylinder_spcfactor [expr $levspc*(($i)**2.5+1)]
		lappend cyndecayfactor [expr [lindex $cyndecayfactor $i]-0.1]
	}
	
	
	for {set i 0} {$i<5} {incr i} {
		lappend cynsourcesh [pw::SourceShape create]
		[lindex $cynsourcesh $i] cylinder -radius \
			[lindex $base_rad $i] -topRadius [lindex $top_rad $i] -length [lindex $cyn_len $i]

		[lindex $cynsourcesh $i] setTransform \
				[list 0 0 1 0 0 1 0 0 -1 0 0 0 0.083520643853 -0.0109231602598 0 1]
		[lindex $cynsourcesh $i] setPivot Top
		[lindex $cynsourcesh $i] setSectionMinimum 0
		[lindex $cynsourcesh $i] setSectionMaximum 360
		[lindex $cynsourcesh $i] setSidesType Plane
		[lindex $cynsourcesh $i] setBaseType Sphere
		[lindex $cynsourcesh $i] setTopType Sphere
		[lindex $cynsourcesh $i] setEnclosingEntities {}
		[lindex $cynsourcesh $i] setSpecificationType AxisToPerimeter
		[lindex $cynsourcesh $i] setBeginSpacing [lindex $cylinder_spcfactor $i]
		[lindex $cynsourcesh $i] setBeginDecay [lindex $cyndecayfactor $i]
		[lindex $cynsourcesh $i] setEndSpacing [lindex $cylinder_spcfactor [expr $i+1]]
		[lindex $cynsourcesh $i] setEndDecay [lindex $cyndecayfactor [expr $i+1]]
	}

}

proc Mesh_Unstr { } {
	
	global smthd domfarbc confarbc ncells confu2_con wu
	
	upvar 1 SIZE_DCY glob_decay
	upvar 1 UNS_ALG uns_algorithm
	upvar 1 UNS_CTYP uns_celltype
	
	pw::Display setCurrentLayer 40
	
	pw::Application setGridPreference Unstructured
	
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
	
	Source_Unstr
	
	set unstrsolve [pw::Application begin UnstructuredSolver $smthd]
	
	foreach dom $smthd {
		$dom setSizeFieldDecay $glob_decay
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
	$UnsCol do setUnstructuredSolverAttribute Algorithm $uns_algorithm
	$UnsCol do setUnstructuredSolverAttribute IsoCellType $uns_celltype
	$unstrsolve run Initialize
	$unstrsolve end
	
	foreach dom $smthd {
		lappend ncells [$dom getCellCount]
	}
	
	[lindex $smthd 0] flipOrientation
	[lindex $smthd 3] flipOrientation
	[lindex $smthd 5] flipOrientation
	
	pw::Display setShowSources 0
}
