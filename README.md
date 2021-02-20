2D CRM Section Structured Mesher
================================

These scripts written to generate multi-block structured grid for the CRM high-lift 2D section. Grid specifications are in the same folder. In overall, seven grid refinement levels are defined based on the flow properties.

###Scripts
topoprepare.glf:
Divides the domain into different sections and prepare the configuration to generate the multi-block structured grid.

mesher.glf:
Generates the mesh and calls on the extrusion in order to extrude the generated domain into a c-type domain.

extrusion.glf:
Extrude the outer boundary of generated domain and gets to the final c-type shape.

smoother.glf:
runs the elliptic solver over domains surrounding the configuration and over the outer c-type domains separately.

output.txt:
provides number of domains, number of cells and run time.

grid_specification.txt:
provides grid guideline or specification for the different grid levels.

flow_propertise.txt:
specifies the flow condition.

###Parameters

These parameters in the mesher.glf can be used to customize the grid:

```Tcl
#Grid Levels: varies from the first line of the grid_specification.txt to the last line as the coarsest level!
#Values from 6 to 0!
set res_lev 6

# switch for running elliptic solver over domains surrounding the configuration!
# values: 1 or 0 for on and off! Recommended!
set slv_switch 1

# running elliptic solver over domains surrounding the config together with other domains!
# values: 1 or 0 for on and off!
set smth 1

# running elliptic solver over outer c-type domain!
# values: 1 or 0 for on and off! only if smoothing switch above is on, it can be considered!
set smth_b 1

#General chrdwise growth ratio for node distribution over the wing, flap, and slat!
set srfgr 1.15

#chrdwise growth ratio for node distribution over the wing's lower surface!
set srfgrwl 1.18

#chrdwise growth ratio for node distribution over the slat's upper surface!
set srfgrfu 1.18

# CAE solver! Exp. SU2 or CGNS 
set cae_solver CGNS

#initial growth ratios for node distribitons!
# region 1 con 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr 1.09

# region 2 con 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr 1.09

# region 3 con 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr 1.09
```

![result](https://github.com/pdpdhp/HelicalTwistedTube/blob/master/steps.png)

