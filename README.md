2D CRM Section Structured Mesher
================================

These scripts written to generate multi-block structured grid for the CRM high-lift 2D section. Grid specifications are in the same folder. In overall, seven grid refinement levels are defined based on the flow properties.

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
#airfoil configuration selection 
#Currently only 2-D CRM-HL wing section is supported!
#DONT CHANGE THIS!
set airfoil 1

#Grid Levels: vary from 6 to 0 according to the first line of the grid_specification.txt till the last line as the coarsest level!
#values from 6 to 0 (coarse --> fine)
set res_lev 5

# switch to run elliptic solver over local strcutured domains in the first layer (e.g. close to the configuration)
# values 1 or 0. Runs only if global is off.
set local_smth 0

# number of iterations to run the local elliptic solver.
# >1000 Recommended, Default: 3000
set lsmthiter 3000

# running elliptic solver over all domains excluding boundary layer's domains.
# values 1 or 0.
set global_smth 1

# number of iterations to run the global elliptic solver over domains.
# >1000 Recommended, Default: 2000
set gsmthiter 4000

#general chrdwise growth ratio for node distribution over the wing, flap, and slat!
set srfgr 1.15

#chrdwise growth ratio for node distribution over the wing's lower surface!
set srfgrwl 1.1

#chrdwise growth ratio for node distribution over the slat's upper surface!
set srfgrfu 1.18

#CAE solver for which the mesh is generated! Exp. SU2 or CGNS 
set cae_solver CGNS

#initial growth ratios for node distribitons.
#--------------------------------------------
#region 1 connector 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr 1.09

#region 2 connector 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr 1.09

#region 3 connector 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr 1.09
```

![result](https://github.com/pdpdhp/multielementmesher/blob/master/grid.png)

