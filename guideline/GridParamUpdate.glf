# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

proc GridFlowprop_Update {plablist meshvlist guidedir} {
	
	set k 20
		
	foreach label $plablist param $meshvlist {
		exec sed -i "0,/$label/{/$label/d;}" $guidedir/gridflowprop.py
		exec sed -i "$k a $label = \[$param\]" $guidedir/gridflowprop.py
		incr k 4
	} 
	
	exec python3 $guidedir/gridflowprop.py
	return 0
}
