2D CRM Section Structured Mesher
================================

These scripts written to generate multi-block structured grid for the CRM high-lift 2D section. In overall, seven grid refinement levels are defined based on the flow properties and grid guideline specifications.

### Scripts
topoprepare.glf:
Divides the domain and prepare the multi-element airfoil for multi-block structured grid.

mesher.glf:
Generates the mesh and calls on the extrusion.glf in order to extrude the first layer of structured domains.

extrusion.glf:
Extrudes the outer boundary of first layer of structured layer until it gets to the final c-type shape.

smoother.glf:
Runs the elliptic solver over domains.

output.txt:
Provides summary info including number of domains, number of cells, minimum area and script's run-time.

grid_specification.txt:
Provides grid guideline and specifications used to generate the multi-block structured grids.

flow_propertise.txt:
Indicates info of the flow condition.

### Parameters

These parameters on the top of the mesher.glf can be used to customize the grid:

```Tcl
#Grid Levels: varies from the first line of the grid_specification.txt to the last line as the coarsest level!
#Default values from 6 to 0!
set res_lev 6

# running structured solver over domains surrounding the config! (YES/NO)
set local_smth NO

# number of iterations to run the local elliptic solver over domains! 
# >1000 Recommended, Default: 2000
set lsmthiter 2000

# running elliptic solver over domains surrounding the config! (YES/NO)
set global_smth YES

# number of iterations to run the global elliptic solver over domains! 
# >1000 Recommended, Default: 3000
set gsmthiter 3000

#General chrdwise growth ratio for node distribution over the wing, flap, and slat!
set srfgr 1.15

#chrdwise growth ratio for node distribution over the wing's lower surface!
set srfgrwl 1.1

#chrdwise growth ratio for node distribution over the slat's upper surface!
set srfgrfu 1.18

# specify the CAE solver you want the mesh to be generated! Exp. SU2 or CGNS 
set cae_solver CGNS

# enable CAE export (YES/NO)
set cae_export YES

# saving native format (YES/NO)
set save_native YES

#initial growth ratios for node distributions!
#--------------------------------------------
# region 1 con 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr 1.09

# region 2 con 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr 1.09

# region 3 con 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr 1.09
```

![result](https://github.com/pdpdhp/multielementmesher/blob/master/grid.png)

