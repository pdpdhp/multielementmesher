# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

package require PWI_Glyph 3.18.3

proc Config_Prep { } {

	global guidelineDir MeshParameters defParas meshparacol res_lev HO_GEN

	if { $MeshParameters != "" } {
		puts "GRID VARIABLES ARE SET BY $MeshParameters"
		ParamDefualt $MeshParameters
	} else {
		puts "DEFAULT GRID VARIABLES ARE SET BY defaultMeshParameters.glf"
	}
	
	#updating gridflow.py with new sets of variables
	GridFlowprop_Update [lrange $defParas end-11 end] [lrange $meshparacol end-11 end] $guidelineDir
	
	MGuideLine $res_lev $HO_GEN $guidelineDir
	
}

proc CAD_Read { } {
	
	global cae_solver airfoil geoDir GRD_TYP model_Q2D model_2D
	
	upvar 1 symsepdd asep
	#grid tolerance
	pw::Grid setNodeTolerance 1.0e-20
	pw::Grid setConnectorTolerance 1.0e-20
	pw::Grid setGridPointTolerance 1.0e-20

	pw::Connector setCalculateDimensionMaximum 100000
	pw::Application setCAESolver $cae_solver 2
	
	if {[string compare $airfoil CRMHL-2D]==0} {
		if {[string compare $GRD_TYP STR]==0} {
			puts "STRUCTURED MULTIBLOCK GRID SELECTED | 2D CRM-HL WING SECTION IMPORTED."
			puts $asep
		} elseif {[string compare $GRD_TYP UNSTR]==0} {
			puts "UNSTRUCTURED GRID SELECTED | 2D CRM-HL WING SECTION IMPORTED."
			puts $asep
		}
	} elseif {[string compare $airfoil 30P30N]==0} {
		puts "2-D 30P-30N MULTI-ELEMENT AIRFOIL: this part hasn't finished yet, please switch to CRMHL-2D!"
		exit -1
	} else {
		puts "PLEASE SELECT THE RIGHT airfoil!"
		exit -1
	}

	if {[string compare $model_Q2D NO]==0 && [string compare $model_2D NO]==0} {
		puts "PLEASE SELECT EITHER 2D OR QUASI 2D MODEL!"
		exit -1
	}

	if {[string compare $airfoil CRMHL-2D]==0} {
		#Import Geometry
		set tmp_model [pw::Application begin DatabaseImport]
		  $tmp_model initialize -strict -type Automatic $geoDir/crmhl-2dcut.igs
		  $tmp_model read
		  $tmp_model convert
		$tmp_model end
		unset tmp_model
		
	} else {
		#Import Geometry
		set tmp_model [pw::Application begin DatabaseImport]
		  $tmp_model initialize -strict -type Automatic $geoDir/2010_30p30n_thik_te_18inches.igs
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

}

proc Local_Smooth { } {
	
	global doms adjdoms adjbcs fixdoms fixbcs lsmthiter
	
	upvar symsepd sep
	upvar symsepdd asep
	
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
	
	puts $sep
	puts "LOCAL ELLIPTIC SOLVER FINISHED $lsmthiter ITERATIONS OVER [llength $doms] STRUCTURED DOMAINS."
	puts $asep
}

#-------------------------------------- RESET APPLICATION--------------------------------------
pw::Application reset
pw::Application clearModified

set scriptDir [file dirname [info script]]
set guidelineDir [file join $scriptDir guideline]
set geoDir [file join $scriptDir geo]

source [file join $scriptDir "ParamRead.glf"]
source [file join $guidelineDir "GridParamUpdate.glf"]
source [file join $scriptDir "MeshGuideline.glf"]
source [file join $scriptDir "topoprepare.glf"]
source [file join $scriptDir "extrusion.glf"]
source [file join $scriptDir "smoother.glf"]
source [file join $scriptDir "unstrdiag.glf"]
source [file join $scriptDir "cae_exporter.glf"]

ParamDefualt [file join $scriptDir "defaultMeshParameters.glf"]

set MeshParameters ""

set symsep [string repeat = 105]
set symsepd [string repeat . 105]
set symsepdd [string repeat - 105]

if {[llength $argv] != 0} {
	set MeshParameters [lindex $argv 0]
}

puts $symsepdd

#----------------------------------------------------------------------------
#READING AND UPDATING GRID PARAMETERS AND VARIABLES
Config_Prep

puts $symsepdd
puts "GRID GUIDELINE: Level: $res_lev | Y+: $ypg | Delta_S(m): $dsg | GR: $grg | Chordwise_Spacing(m): $chord_sg"
puts $symsep

set time_start [pwu::Time now]

#----------------------------------------------------------------------------
#READING CAD MODEL
CAD_Read

#----------------------------------------------------------------------------
#PREPARING THE TOPOLOGY FOR MESH AND GENERATING THE MESH
Topo_Prep_Mesh

#----------------------------------------------------------------------------
#LOCAL SMOOTHER
# running structured solver over structured domains 
# surrounding the configuration -- local_smth turns it off!
if {[string compare $local_smth YES]==0 && [string compare $GRD_TYP STR]==0 && \
			[string compare $global_smth NO]==0} {

	Local_Smooth

}

#----------------------------------------------------------------------------
#BOUNDARY EXTRUSION
Extr_Mesh

#----------------------------------------------------------------------------
#GLOBAL SMOOTHER
if {[string compare $global_smth YES]==0 && [string compare $GRD_TYP STR]==0} {
	Global_Smooth 
}

#----------------------------------------------------------------------------
#UNSTRUCTURED MESHER
if {[string compare $GRD_TYP UNSTR]==0} {
	
	Mesh_Unstr
	
	set domexm [pw::Examine create DomainArea]
	$domexm addEntity $bldoms
	$domexm addEntity $smthd
}

#DOMAIN EXAMINE
$domexm examine
set domexmv [$domexm getMinimum]

set fexmod [open "$scriptDir/CAE_export.out" w]

#----------------------------------------------------------------------------
#CAE EXPORT
CAE_Export

set time_end [pwu::Time now]
set runtime [pwu::Time subtract $time_end $time_start]
set tmin [expr int([lindex $runtime 0]/60)]
set tsec [expr [lindex $runtime 0]%60]
set tmsec [expr int(floor([lindex $runtime 1]/1000))]

puts $fexmod [string repeat - 50]
puts $fexmod "runtime: $tmin min $tsec sec $tmsec ms" 
puts $fexmod [string repeat - 50]
close $fexmod

puts "GRID INFO WRITTEN TO CAE_export.out"
puts $symsep
puts "COMPLETE!"
