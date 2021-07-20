# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

proc ParamDefualt {fdef} {

	set fdefinterp [interp create -safe]

	set fp [open $fdef r]
	set defscript [read $fp]
	close $fp

	$fdefinterp eval $defscript

	global airfoil res_lev GRD_TYP UNS_ALG UNS_CTYP SIZE_DCY global_smth gsmthiter \
		local_smth lsmthiter model_2D model_Q2D span fixed_snodes span_dimension cae_solver \
			POLY_DEG HO_GEN cae_export save_native srfgr srfgrwl srfgrfu r1c1gr r2c3gr r3c1gr \
			TARG_YPR TARG_GR CHR_SPC TE_SRT TE_PT1 TE_PT2 EXP_FAC IMP_FAC VOL_FAC EXTR_STP TARG_YPH \
							TARG_GRH defParas meshparacol

	set defParas [list airfoil res_lev GRD_TYP UNS_ALG UNS_CTYP SIZE_DCY global_smth gsmthiter local_smth \
				lsmthiter model_2D model_Q2D span fixed_snodes span_dimension cae_solver \
					POLY_DEG HO_GEN cae_export save_native srfgr srfgrwl srfgrfu \
						r1c1gr r2c3gr r3c1gr TARG_YPR TARG_GR CHR_SPC TE_SRT \
						TE_PT1 TE_PT2 EXP_FAC IMP_FAC VOL_FAC EXTR_STP TARG_YPH \
							TARG_GRH]

	foreach para $defParas {
		set parav [$fdefinterp eval "set ${para}"]
			set ${para} $parav
			lappend meshparacol [list $parav]
	}
	
	return 0
}
