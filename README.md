2D CRM Section Structured Mesher
================================

These scripts written to generate multi-block structured grid over the CRM high-lift 2D section. In overall, seven refinement levels are defined based on the flow properties and grid guideline specifications.

### Scripts
topoprepare.glf:
Divides the domain and prepare the multi-element airfoil for the multi-block structured grid.

mesher.glf:
Generates the mesh and calls on the extrusion.glf in order to extrude from first layer of structured domains.

extrusion.glf:
Extrudes from the outer boundary of the first layer of structured domains until it gets to the final c-type shape.

smoother.glf:
Runs the elliptic solver over domains.

output.txt:
Provides summary info including number of domains, number of cells, minimum area, script's run-time and CAE export.

grid_specification.txt:
Provides grid guideline specifications to generate the multi-block structured grid.

flow_propertise.txt:
Includes flow condition specifications.

### Parameters

These parameters on the top of the mesher.glf can be used to customize the grid:

```Tcl
#Grid Levels vary from the first line of the grid_specification.txt to the last line as the coarsest level!
#Default values from 6 to 0!
set res_lev 6

# running structured elliptic solver over local domains only if global is switched off (e.g. near the configuration) (YES/NO)
set local_smth YES

# number of iterations to run the local elliptic solver.
# (>1000 Recommended)
set lsmthiter 2000

# running elliptic solver over all domains excluding boundary layers. (YES/NO)
set global_smth YES

# number of iterations to run the global elliptic solver.
# (>1000 Recommended)
set gsmthiter 3000

#General chrdwise growth ratio for node distribution over the wing, flap, and slat.
set srfgr 1.15

#chrdwise growth ratio for node distribution over the wing's lower surface.
set srfgrwl 1.1

#chrdwise growth ratio for node distribution over the slat's upper surface.
set srfgrfu 1.18

#CAE solver selection. (Exp. SU2 or CGNS)
set cae_solver CGNS

#enables CAE export (YES/NO)
set cae_export YES

#saves the native format (YES/NO)
set save_native YES

#Initial growth ratios for node distributions!
#--------------------------------------------
# region 1 con 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr 1.09

# region 2 con 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr 1.09

# region 3 con 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr 1.09
```
### Instruction

To run the script, open up the mesher.glf in your text editor and set up the above mentioned parameters on the top of the script and run the mesher.glf in Pointwise. In batch mode you can execute:

```shell
pointwise -b mesher.glf
```
The entire grid generation is automated. The script's summary appears in the output.txt in the root directory after the script is done and you will find meshes in the grids directory in the root.

The mesher.glf is handling all the scripts and first calls on the toprepare.glf to import and prepare the configuration, divides the topology and creates the boundary layer blocks for each elements. Then, it creates the first layer of multi-block structured domains and calls on the extrusion.glf. Extrusion script extrudes the outer boundary of the first multi-block structured grid untill it reaches to the c-type domain and calls on the smoother.glf to run the elliptic solver on all domains excluding boundary layer blocks.

### Local and global elliptic solvers

The mesher.glf handles two elliptic solvers: local and global, which are considered as smoother in the script. The local elliptic solver runs only on structured domains near the configuration. These domains are part of the first layer of structured domains that are created after the boundary layer block extrusion. The global elliptic solver runs on all domains including first and second layers of structured domains except boundary layer blocks. The smoother.glf contains the global elliptic solver implementation. The local elliptic solver is implemented in the mesher.glf.

The local and global smoothers are based on muligrid approach to solve the elliptic PDE on the grid and make sure that grid points and structured domains between slat, wing and flap and their interfaces are relaxed with nice orthogonality and distribution. The local elliptic solver runs only if the global smoother is switched off. In the mesher.glf number of iterations for both smoothers can be indicated. The default number of iterations for the global smoother is 3000 and for the local smoother is 2000 to make sure that they are adequate for different levels of refinements. For that reason, script's runtime to generate grids can take from 10 minutes for the coarse level (e.g. res_lev 6) depending on your hardware to couple of hours for the finest level (e.g. res_lev 0). You might set number of iterations to 1500 or less to decrease the runtime but the grids would not be as relaxed as the defalut values.

![result](https://github.com/pdpdhp/multielementmesher/blob/master/grid.png)

