2D CRM Section Structured Mesher
================================

These scripts written to generate structured multi-block grid on the CRM high-lift 2D wing section. In overall, seven refinement levels are defined based on the flow properties and grid guideline specifications, both are included in the script's directory.

### Scripts
topoprepare.glf:

divides the domain and prepare the multi-element configuration.

mesher.glf:

generates the mesh and calls the extrusion.glf. 

extrusion.glf:

extrude from first layer till gets to the c-topology.

smoother.glf:

runs the elliptic solver over domains.

output.txt:

provides summary info including number of domains, number of cells, minimum area, minimum volume, script's run-time and CAE export.

grid_specification.txt:

provides grid guideline specifications to generate the multi-block structured grid.

flow_propertise.txt:

includes flow condition specifications.

### Parameters

These parameters on the top of the mesher.glf can be used to customize the grid:

```Tcl
#GRID REFINEMENT LEVEL:
#--------------------------------------------
#Grid Levels vary from the first line of the grid_specification.txt to the last line as the coarsest level!
#Default values from 6 to 0!
set res_lev 5

#GLOBAL AND LOCAL SMOOTHER:
#--------------------------------------------
# running elliptic solver over all domains excluding boundary layers. (YES/NO)
set global_smth YES

# number of iterations to run the global elliptic solver.
# (>1000 Recommended)
set gsmthiter 3000

# running structured elliptic solver over local domains only if global is switched off (e.g. near the configuration) (YES/NO)
set local_smth NO

# number of iterations to run the local elliptic solver.
# (>1000 Recommended)
set lsmthiter 2000

#GROWTH RATIOS:
#--------------------------------------------
#General chordwise growth ratio for node distribution over the wing, flap, and slat.
set srfgr 1.15

#chordwise growth ratio for node distribution over the wing's lower surface.
set srfgrwl 1.1

#chordwise growth ratio for node distribution over the slat's upper surface.
set srfgrfu 1.18

#GRID DIMENSION:
#--------------------------------------------
# 2D DIMENSIONAL MESH. (YES/NO)
set model_2D YES

# QUASI 2D MESH. (YES/NO)
set model_Q2D YES

# span dimension for quasi 2d model in -Y direction
set span 1.0

# Fix number of points in spanwise direction? if YES, indicate number of points below. (YES/NO)
set fixed_snodes YES

# Number of points in spanwise direction. This parameter will be ignored
# if you opted NO above and set automatically based on maximum spacing over wing, slat and flap.
set span_dimension 10

#CAE EXPORT:
#--------------------------------------------
#CAE solver selection. (Exp. SU2 or CGNS)
set cae_solver CGNS

#enables CAE export (YES/NO)
set cae_export YES

#saves the native format (YES/NO)
set save_native YES

#INITIAL GROWTH RATIOS FOR NODE DISTRIBUTION:
#--------------------------------------------
# region 1 con 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr 1.09

# region 2 con 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr 1.09

# region 3 con 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr 1.09
```
### Instruction

To run the script, open up the mesher.glf in your text editor and set up the script's parameters mentioned above and execute it in Pointwise. In batch mode you can execute by:

```shell
pointwise -b mesher.glf
```
The entire grid generation is automated. The script's summary appears in the output.txt in the root directory after the script is done and you will find meshes in 'grids' directory in the root.

The mesher.glf is handling all the scripts. It first calls toprepare.glf to import and prepare the configuration, divides the topology and creates boundary layer blocks on each elements. Then, it creates the first layer of structured multi-block domains. Then it calls extrusion.glf. Extrusion script extrudes the outer boundary obtained in the previous step until it reaches to the c-type domain. Then it calls smoother.glf to run the elliptic solver on all domains excluding boundary layer blocks.

### Local and global elliptic solvers

The mesher.glf handles two elliptic solvers: local and global, which are considered as smoother in the script. The local elliptic solver runs only on structured domains near the configuration. These domains are part of the first layer of structured domains created after the boundary layer block extrusion. The global elliptic solver runs on all domains including first and second layers except boundary layer blocks. The smoother.glf contains the global elliptic solver. The local elliptic solver is included in the mesher.glf.

The local and global smoothers are based on muligrid approach to solve the elliptic PDE on the grid and make sure that grid points and structured domains between slat, wing and flap and their interfaces are relaxed with nice orthogonality and distribution. The local elliptic solver runs only if the global smoother is switched off. In the mesher.glf, number of iterations for both smoothers can be indicated. The default number of iterations for the global smoother is 3000 and for the local smoother is 2000 to make sure that they are adequate for different levels of refinements. However, as very fine levels, like level 1 and 0, are chosen, more iterations might be needed, like around 7000. Therefore, script's runtime to generate grids can vary from 15 minutes for the coarsest level (e.g. res_lev 6) depending on your hardware to more than 16 hours for the finest level (e.g. res_lev 0). You might opt less number of iterations in order to decrease the runtime but result would not be as relaxed as the result obtained by the recommended values for smoother's number of iterations.

### Grid dimension

The script can generate 2D and quasi 2D grids at the same time. The quasi 2d grid is translation of the 2d grid in -y direction. Translation's distance can be set by the parameter 'span' in the mesher.glf. Number of points in the span direction can be selected by setting 'fixed_snodes' to YES and assigning number of points to the 'span_dimension' parameter. If 'fixed_snodes' set to NO, 'span_dimension' will be ignored and number of points in the span direction automatically will be measured based on the maximum chordwise spacing on the upper surfaces of wing, slat and flap. For both types of grids, approximately upstream reaches to 1200c and downstream is about 7000c.

### Boundary condition

For both 2D and quasi 2D grids boundary conditions are assigned appropriately to the right boundaries but are not set. Based on the solver, they can be set in Pointwise.


![grid1](https://github.com/pdpdhp/multielementmesher/blob/master/grid1.png)

![grid2](https://github.com/pdpdhp/multielementmesher/blob/master/grid2.png)

