2D CRM Section Structured Mesher
================================

These scripts written to generate structured multi-block grid on the CRM high-lift 2D wing section. In overall, seven refinement levels are defined based on the flow properties and grid guideline specifications, both are included in the script's directory.

#### GUIDELINE SCRIPT:
guideline/gridflowprop.py : It is a python script, generatin grid properties based on target y+, growth rate, chordwise spacing, TE spacing ratio, TE number of points, explicit, implicit, and volume factors for normal extrusion and extrusion steps.

This script generates grid_specification.txt and flow_propertise.txt

#### options:

HO = (YES/NO)

If YES generates a separate grid specification file to be used later by the mesher.glf. 

#### PW SCRIPTS:

mesher.glf: Generates the mesh and calls the extrusion.glf. 

topoprepare.glf: Divides the domain and prepare the multi-element configuration.

extrusion.glf: Extrude from first layer till gets to the c-topology.

smoother.glf: Runs the elliptic solver over domains.

output.txt: Provides summary info including number of domains, number of cells, minimum area, minimum volume, script's run-time and CAE export.

#### Options

These parameters on the top of the mesher.glf can be adjusted for the grid generation:

```Tcl
#GRID REFINEMENT LEVEL:
#--------------------------------------------
#Grid Levels vary from the first line of the grid_specification.txt to the last line!
#Default values from 6 to 0! Last line is level 6 and the coarsest!
set res_lev 6

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
set srfgr 1.25

#Chordwise growth ratio for node distribution over the wing's lower surface.
set srfgrwl 1.2

#Chordwise growth ratio for node distribution over the slat's upper surface.
set srfgrfu 1.2

#GRID DIMENSION:
#--------------------------------------------
#2D DIMENSIONAL MESH (YES/NO)
set model_2D YES

#QUASI 2D MESH (YES/NO)
set model_Q2D YES

#Span dimension for quasi 2d model in -Y direction (max 3.0)
set span 1.0

#Fix number of points in spanwise direction? If YES, indicate number of points below. (YES/NO)
set fixed_snodes YES

#Number of points in spanwise direction. This parameter will be ignored
#If you opt NO above, this is set automatically based on maximum spacing over wing, slat and flap.
set span_dimension 4

#CAE EXPORT:
#--------------------------------------------
#CAE SOLVER SELECTION. (Exp. SU2 or CGNS)
set cae_solver CGNS

#HIGH ORDER DESCRETIZATION EXPORT POLYNOMIAL DEGREE (Q1:Linear - Q4:quartic) | FOR SU2 ONLY Q1
set POLY_DEG Q2

#USING HIGH ORDER DESCRETIZATION GRID GUIDELINE SPECIFICATION IN GUIDELINE DIR (YES/NO)
set HO_GEN YES

#ENABLES CAE EXPORT (YES/NO)
set cae_export NO

#SAVES NATIVE FORMATS (YES/NO)
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

### CAE export

The mesher.glf's preamble has five options that can be adjusted. For quadratic, cubic and quartic meshes, you have to select CGNS format. The POLY_DEG indicates polynominal degree for mesh elevation. The HO_GEN lets you set the grid specification through a separate file in the guideline folder. For this, you need first generate the grid specification text file using the gridflowprop.py. THE cae_export exports the cae format you selected. The save_native option saves the Pointwise format.


### Local and global elliptic solvers

The mesher.glf handles two elliptic solvers: local and global, which are considered as smoother in the script. The local elliptic solver runs only on structured domains near the configuration. These domains are part of the first layer of structured domains created after the boundary layer block extrusion. The global elliptic solver runs on all domains including first and second layers except boundary layer blocks. The smoother.glf contains the global elliptic solver. The local elliptic solver is included in the mesher.glf.

The local and global smoothers are based on muligrid approach to solve the elliptic PDE on the grid and make sure that grid points and structured domains between slat, wing and flap and their interfaces are relaxed with nice orthogonality and distribution. The local elliptic solver runs only if the global smoother is switched off. In the mesher.glf, number of iterations for both smoothers can be indicated. The default number of iterations for the global smoother is 3000 and for the local smoother is 2000 to make sure that they are adequate for different levels of refinements. However, as very fine levels, like level 1 and 0, are chosen, more iterations might be needed, like around 7000. Therefore, script's runtime to generate grids can vary from 15 minutes for the coarsest level (e.g. res_lev 6) depending on your hardware to more than 16 hours for the finest level (e.g. res_lev 0). You might opt less number of iterations in order to decrease the runtime but result would not be as relaxed as the result obtained by the recommended values for smoother's number of iterations.

### Grid dimension

The script can generate 2D and quasi 2D grids at the same time. The quasi 2d grid is translation of the 2d grid in -y direction. Translation's distance can be set by the parameter 'span' in the mesher.glf. Number of points in the span direction can be selected by setting 'fixed_snodes' to YES and assigning number of points to the 'span_dimension' parameter. If 'fixed_snodes' set to NO, 'span_dimension' will be ignored and number of points in the span direction automatically will be measured based on the maximum chordwise spacing on the upper surfaces of wing, slat and flap. For both types of grids, approximately upstream reaches to 1200c and downstream is about 7000c.

### Boundary condition

For both 2D and quasi 2D grids boundary conditions are assigned appropriately to the right boundaries but are not set. Based on the solver, they can be set in Pointwise.

In case you encounter any issues using the scripts please use the issue feature on Github and let me know of that or send me an email. I will do my best to address that as soon as possible.

![grid1](https://github.com/pdpdhp/multielementmesher/blob/master/grid1.png)

![grid2](https://github.com/pdpdhp/multielementmesher/blob/master/grid2.png)

