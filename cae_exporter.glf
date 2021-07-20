# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

proc CAE_Export { } {

	global wu su con_fusp scriptDir geoDir smthd bldoms model_2D model_Q2D ncells span span_dimension fixed_snodes save_native
	global conslatbc domslatbc conwingbc domwingbc conflapbc domflapbc confarbc domfarbc
	
	upvar 1 cae_solver cae_fmt
	upvar 1 POLY_DEG ply_degree
	upvar 1 GRD_TYP grid_type
	upvar 1 symsepdd asep
	upvar 1 res_lev grid_level
	upvar 1 domexmv min_area
	upvar 1 cae_export caeexprt
	upvar 1 fexmod outfile
	
	#==============================================CAE Export--==========================================

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

	if {[string compare $cae_fmt CGNS]==0} {
		pw::Application setCAESolverAttribute CGNS.FileType adf
		pw::Application setCAESolverAttribute ExportPolynomialDegree $ply_degree
		pw::Application setCAESolverAttribute ExportStepSizeRelaxationFactor 0.3
		pw::Application setCAESolverAttribute ExportConvergenceCostThreshold 0.99
		pw::Application setCAESolverAttribute ExportWCNWeightingFactor 0.6
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

		append gridname $grid_type "_" 2D "_" lev $grid_level "_" $gridID "_" Q1
		
		puts $outfile [string repeat - 50]
		
		if {[string compare $grid_type UNSTR]==0} {
			puts $outfile "2D UNSTRUCTURED GRID | 2D CRM HIGH-LIFT CONFIG | GRID LEVEL $grid_level:"
			puts "2D GRID GENERATED FOR LEVEL $grid_level | TOTAL CELLS: $ncell CELLS"
			puts $asep
		} else {
			puts $outfile "2D MULTIBLOCK STRUCTURED GRID | 2D CRM HIGH-LIFT CONFIG | GRID LEVEL $grid_level:"
			puts "2D GRID GENERATED FOR LEVEL $grid_level | TOTAL CELLS: $ncell QUADS"
			puts $asep
		}

		puts $outfile [string repeat - 50]
		puts $outfile "total domains: [llength $ncells]"
		puts $outfile "total cells: $ncell cells"
		puts $outfile "min area: [format "%*e" 5 $min_area]"
		
		if {[string compare $caeexprt YES]==0} {
			# creating export directory
			set exportDir [file join $scriptDir grids/2d]

			file mkdir $exportDir
			
			puts $outfile [string repeat - 50]
			# CAE specificity in the output file!
			puts $outfile "Current solver: [set curSolver [pw::Application getCAESolver]]"

			set validExts [pw::Application getCAESolverAttribute FileExtensions]
			puts $outfile "Valid file extensions: '$validExts'"

			set defExt [lindex $validExts 0]

			set caex [pw::Application begin CaeExport $alldoms]

			set destType [pw::Application getCAESolverAttribute FileDestination]
			switch $destType {
				Filename { set dest [file join $exportDir "$gridname.$defExt"] }
				Folder   { set dest $exportDir }
				default  { return -code error "Unexpected FileDestination value" }
			}
			puts $outfile "Exporting to $destType: '$dest'"
			puts $outfile [string repeat - 50]

			# Initialize the CaeExport mode
			set status abort  ;
			if { ![$caex initialize $dest] } {
				puts $outfile {$caex initialize failed!}
			} else {
				if { ![catch {$caex setAttribute FilePrecision Double}] } {
					puts $outfile "setAttribute FilePrecision Double"
				}

				if { ![$caex verify] } {
					puts $outfile {$caex verify failed!}
				} elseif { ![$caex canWrite] } {
					puts $outfile {$caex canWrite failed!}
				} elseif { ![$caex write] } {
					puts $outfile {$caex write failed!}
				} elseif { 0 != [llength [set feCnts [$caex getForeignEntityCounts]]] } {
				# print entity counts reported by the exporter
				set fmt {   %-22.22s | %6.6s |}
				puts $outfile "Number of grid entities exported:"
				puts $outfile [format $fmt {Entity Type} Count]
				puts $outfile [format $fmt $dashes $dashes]
				dict for {key val} $feCnts {
					puts $outfile [format $fmt $key $val]
				}
				set status end ;# all is okay now
				}
			}

			# Display any errors/warnings
			set errCnt [$caex getErrorCount]
			for {set ndx 1} {$ndx <= $errCnt} {incr ndx} {
				puts $outfile "[$caex getErrorCode $ndx]: '[$caex getErrorInformation $ndx]'"
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
		pw::Application setCAESolver $cae_fmt 3

		#grid tolerance
		pw::Grid setNodeTolerance 1.0e-07
		pw::Grid setConnectorTolerance 1.0e-07
		pw::Grid setGridPointTolerance 1.0e-07
		
		set spanSpc [pw::Examine create ConnectorEdgeLength]
		$spanSpc addEntity $wu
		$spanSpc addEntity $su
		$spanSpc addEntity [lindex $con_fusp 0]
		$spanSpc examine
		set spanSpcv [$spanSpc getMaximum]
		set trnstp [expr int($span/$spanSpcv)]
		
		if {[string compare $grid_type UNSTR]==0} {
			set fstr [pw::FaceUnstructured createFromDomains $alldoms]
			
			set blk [pw::BlockExtruded create]
			$blk addFace $fstr
			
			set domtrn [pw::Application begin ExtrusionSolver $blk]
			
			$blk setExtrusionSolverAttribute Mode Translate
			$blk setExtrusionSolverAttribute TranslateDirection {0 0 1}
			$blk setExtrusionSolverAttribute TranslateDistance $span
				
		} elseif {[string compare $grid_type STR]==0} {
			set fstr [pw::FaceStructured createFromDomains $alldoms]
			
			
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
			
		}
		
		if {[string compare $fixed_snodes NO]==0} {
			$domtrn run $trnstp
			$domtrn end
		} else {
			$domtrn run [expr $span_dimension-1]
			if {[string compare [lindex [$domtrn getRunResult] 0] Completed]!=0} {
				puts "TRANSLATE EXTRUSION FAILED! PLEASE TRUN ON THE GLOBAL SMOOTHER WITH PROPER NUMBER OF ITERATIONS TO PREVENT THIS!"
				$domtrn end
				exit -1
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
		
		if {[string compare $grid_type UNSTR]==0} {
			
			set dommleftqbc(1) [[$blk getFace 1] getDomains]
			
			foreach ent $dommleftqbc(1) {
				lappend domleftqbc $ent
				lappend blkleftqbc $blk
			}
			
			for {set i 2} {$i<8} {incr i} {
				lappend dommwingqbc(1) [[$blk getFace $i] getDomains]
			}
			
			foreach ent $dommwingqbc(1) {
				lappend domwingqbc $ent
				lappend blkwingqbc $blk
			}
			
			for {set i 8} {$i<18} {incr i} {
				lappend dommfarqbc(1) [[$blk getFace $i] getDomains]
			}
			
			foreach ent $dommfarqbc(1) {
				lappend domfarqbc $ent
				lappend blkfarqbc $blk
			}
			
			for {set i 18} {$i<24} {incr i} {
				lappend dommflapqbc(1) [[$blk getFace $i] getDomains]
			}
			
			foreach ent $dommflapqbc(1) {
				lappend domflapqbc $ent
				lappend blkflapqbc $blk
			}
			
			for {set i 24} {$i<29} {incr i} {
				lappend dommslatqbc(1) [[$blk getFace $i] getDomains]
			}
			
			foreach ent $dommslatqbc(1) {
				lappend domslatqbc $ent
				lappend blkslatqbc $blk
			}
			
			set dommrightqbc(1) [[$blk getFace 29] getDomains]
			
			foreach ent $dommrightqbc(1) {
				lappend domrightqbc $ent
				lappend blkrightqbc $blk
			}
			
		} elseif {[string compare $grid_type STR]==0} {
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
			set dommslatqbc(1) [[[lindex $blk 2] getFace 2] getDomains]
			
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
			set dommfarqbc(4) [[[lindex $blk 5] getFace 2] getDomains]
			
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
			set dommfarqbc(7) [[[lindex $blk 9] getFace 2] getDomains]
			
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
		
		set clay [pw::Display getCurrentLayer]
		
		pw::Display setCurrentLayer 10
		set tmp_model [pw::Application begin DatabaseImport]
		  $tmp_model initialize -strict -type Automatic $geoDir/crmhl2dcut_extr.iges
		  $tmp_model read
		  $tmp_model convert
		$tmp_model end
		unset tmp_model
		
		set dq_database [pw::Layer getLayerEntities -type pw::Quilt 10]
		
		pw::Entity project -type ClosestPoint [list {*}$domwingqbc {*}$domslatqbc {*}$domflapqbc] $dq_database

		pw::Display setCurrentLayer $clay
		pw::Display hideLayer 10
		
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

		append 3dgridname $grid_type "_" Q2D "_" lev $grid_level "_" $blkID "_" $ply_degree
		
		puts $outfile [string repeat - 50]
		
		if {[string compare $grid_type UNSTR]==0} {
			puts $outfile "QUASI 2D UNSTRUCTURED GRID | 2D CRM HIGH-LIFT CONFIG | GRID LEVEL $grid_level:"
			puts $asep
			puts "QUASI 2D GRID GENERATED FOR LEVEL $grid_level | TOTAL CELLS: $blkncell Cells"
			puts $asep
		} else {
			puts $outfile "QUASI 2D MULTIBLOCK STRUCTURED GRID | 2D CRM HIGH-LIFT CONFIG | GRID LEVEL $grid_level:"
			puts $asep
			puts "QUASI 2D GRID GENERATED FOR LEVEL $grid_level | TOTAL CELLS: $blkncell HEX"
			puts $asep
		}
		
		puts $outfile [string repeat - 50]
		puts $outfile "total blocks: [llength $blkncells]"
		puts $outfile "total cells: $blkncell cells"
		puts $outfile "min volume: [format "%*e" 5 $blkexmv]"
		
		
		if {[string compare $caeexprt YES]==0} {
			# creating export directory
			set exportDir [file join $scriptDir grids/2dquasi]

			file mkdir $exportDir
			
			puts $outfile [string repeat - 50]
			# CAE specificity in the output file!
			puts $outfile "Current solver: [set curSolver [pw::Application getCAESolver]]"

			set validExts [pw::Application getCAESolverAttribute FileExtensions]
			puts $outfile "Valid file extensions: '$validExts'"

			set defExt [lindex $validExts 0]

			set caex [pw::Application begin CaeExport $blk]

			set destType [pw::Application getCAESolverAttribute FileDestination]
			switch $destType {
				Filename { set dest [file join $exportDir "$3dgridname.$defExt"] }
				Folder   { set dest $exportDir }
				default  { return -code error "Unexpected FileDestination value" }
			}
			puts $outfile "Exporting to $destType: '$dest'"
			puts $outfile [string repeat - 50]

			# Initialize the CaeExport mode
			set status abort  ;
			if { ![$caex initialize $dest] } {
				puts $outfile {$caex initialize failed!}
			} else {
				if { ![catch {$caex setAttribute FilePrecision Double}] } {
					puts $outfile "setAttribute FilePrecision Double"
				}

				if { ![$caex verify] } {
					puts $outfile {$caex verify failed!}
				} elseif { ![$caex canWrite] } {
					puts $outfile {$caex canWrite failed!}
				} elseif { ![$caex write] } {
					puts $outfile {$caex write failed!}
				} elseif { 0 != [llength [set feCnts [$caex getForeignEntityCounts]]] } {
				# print entity counts reported by the exporter
				set fmt {   %-22.22s | %6.6s |}
				puts $outfile "Number of grid entities exported:"
				puts $outfile [format $fmt {Entity Type} Count]
				puts $outfile [format $fmt $dashes $dashes]
				dict for {key val} $feCnts {
					puts $outfile [format $fmt $key $val]
				}
				set status end ;# all is okay now
				}
			}

			# Display any errors/warnings
			set errCnt [$caex getErrorCount]
			for {set ndx 1} {$ndx <= $errCnt} {incr ndx} {
				puts $outfile "[$caex getErrorCode $ndx]: '[$caex getErrorInformation $ndx]'"
			}
			# abort/end the CaeExport mode
			$caex $status
		
			puts "info: QUASI 2D $ply_degree GRID: $3dgridname.$defExt EXPORTED IN GRID DIR."
		}

		if {[string compare $save_native YES]==0} {
			set exportDir [file join $scriptDir grids/2dquasi]
			file mkdir $exportDir
			pw::Application save "$exportDir/$3dgridname.pw"
			
			puts "info: NATIVE FORMAT: $3dgridname.pw SAVED IN GRID DIR."
		}
	}
}
