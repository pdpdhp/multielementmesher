High Lift's Pointwise's 2D CRM Mesher
================================

These scripts written to generate structured/unstrcutred grids on CRM high-lift 2D wing section. For both structured and unstrcutured, seven refinement levels can be defined based on the flow properties and grid guideline specification files. These two files can be generated using gridflowprop.py in the guideline directory.

#### GUIDELINE SCRIPT:
guideline/gridflowprop.py : It is a python script, generates grid specifications based on target y+, growth rate, chordwise spacing, TE spacing ratio, TE number of points, explicit, implicit, and volume factors for normal extrusion and extrusion steps. These variables can be adjusted inside the script in the preamble part. After execution two files are generated to be used by PW's scripts. In case you want to have a separate grid specification for the high oder meshes, you can set HO=yes and adjust y+ and growth rates for different levels separately.

output: grid_specification.txt, flow_propertise.txt, grid_specification_HO.txt

#### PW SCRIPTS:

mesher.glf: Generates structured multi-block or unstructured meshes and for that calls topoprepare.glf first and then extrusion.glf. 

topoprepare.glf: Divides the domain and prepare the multi-element configuration.

extrusion.glf: Extrude from first layer till gets to the c-topology.

smoother.glf: Runs the elliptic solver over domains.

output.txt: Provides summary info including number of domains, number of cells, minimum area, minimum volume, script's run-time and CAE export.

#### MULTI-BLOCK STRUCTURED

These parameters on the top of the mesher.glf can be adjusted for the multi-block structured grid generation:

```Tcl
#GRID SYSTEM'S ARRANGEMENT: STRUCTURED OR UNSTRUCTRED
#====================================================
#PLEASE SELECT GRID SYSTEM: STR (for STRUCTURED) | UNSTR (for UNSTRUCTURED)
set GRD_TYP STR

# STRUCTURED SETTINGS:
#====================================================
#GLOBAL AND LOCAL SMOOTHER FOR GRD_TYP: STR
#----------------------------------------------------
# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS EXCLUDING BOUNDARY LAYERS. (YES/NO)
set global_smth YES

# NUMBER OF ITERATIONS FOR GLOBAL ELLIPTIC SOLVER
# (>1000 is recommended)
set gsmthiter 1000

# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS | RUNS ONLY IF GLOBAL SMOOTHER IS OFF | INCLUDES NEAR CONFIG DOMAINS. (YES/NO)
set local_smth NO

# NUMBER OF ITERATIONS TO RUN LOCAL ELLIPTIC SOLVER.
# (>1000 is recommended)
set lsmthiter 2000
```

#### UNSTRUCTURED

These parameters on the top of the mesher.glf can be adjusted for the unstructured grid generation:

```Tcl
#GRID SYSTEM'S ARRANGEMENT: STRUCTURED OR UNSTRUCTRED
#====================================================
#PLEASE SELECT GRID SYSTEM: STR (for STRUCTURED) | UNSTR (for UNSTRUCTURED)
set GRD_TYP UNSTR

# UNSTRUCTURED SETTINGS:
#====================================================
#UNSTRUCTRED GRID PROPERTIES FOR GRD_TYP: UNSTR
#----------------------------------------------------
#UNSTRUCTURED SOLVER ALGORITHM: AdvancingFront | AdvancingFrontOrtho | Delaunay
set UNS_ALG AdvancingFrontOrtho

#UNSTRUCTRED SOLVER CELL TYPE: TriangleQuad | Triangle
set UNS_CTYP TriangleQuad

#GENERAL DECAY FACTOR FOR UNSTRUCTRED SOLVER
set SIZE_DCY 0.6
```

#### PREAMBLE TO GENERATE A MESH

In overall, these parameters can be adjusted to generate either structured or unstructured mesh:

```Tcl
#GRID REFINEMENT LEVEL:
#====================================================
#Grid Levels vary from the first line (finest, level 0) of the grid_specification.txt to the last line (coarsest, level 6)!
set res_lev 2

#GRID SYSTEM'S ARRANGEMENT: STRUCTURED OR UNSTRUCTRED
#====================================================
#PLEASE SELECT GRID SYSTEM: STR (for STRUCTURED) | UNSTR (for UNSTRUCTURED)
set GRD_TYP UNSTR

# UNSTRUCTURED SETTINGS:
#====================================================
#UNSTRUCTRED GRID PROPERTIES FOR GRD_TYP: UNSTR
#----------------------------------------------------
#UNSTRUCTURED SOLVER ALGORITHM: AdvancingFront | AdvancingFrontOrtho | Delaunay
set UNS_ALG AdvancingFrontOrtho

#UNSTRUCTRED SOLVER CELL TYPE: TriangleQuad | Triangle
set UNS_CTYP TriangleQuad

#GENERAL DECAY FACTOR FOR UNSTRUCTRED SOLVER
set SIZE_DCY 0.6

# STRUCTURED SETTINGS:
#====================================================
#GLOBAL AND LOCAL SMOOTHER FOR GRD_TYP: STR
#----------------------------------------------------
# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS EXCLUDING BOUNDARY LAYERS. (YES/NO)
set global_smth YES

# NUMBER OF ITERATIONS FOR GLOBAL ELLIPTIC SOLVER
# (>1000 is recommended)
set gsmthiter 1000

# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS | RUNS ONLY IF GLOBAL SMOOTHER IS OFF | INCLUDES NEAR CONFIG DOMAINS. (YES/NO)
set local_smth NO

# NUMBER OF ITERATIONS TO RUN LOCAL ELLIPTIC SOLVER.
# (>1000 is recommended)
set lsmthiter 2000


# GENERAL SETTINGS:
#==================================================
#GROWTH RATIOS:
#--------------------------------------------------
#general chordwise growth ratio for node distribution over the wing, flap, and slat.
set srfgr 1.25

#chordwise growth ratio for node distribution over the wing's lower surface.
set srfgrwl 1.2

#chordwise growth ratio for node distribution over the slat's upper surface.
set srfgrfu 1.2

# GRID DIMENSION:
#===================================================
#2D DIMENSIONAL MESH (YES/NO)
set model_2D YES

#QUASI 2D MESH | GENERATES AN EXTRUDED VERSION (YES/NO)
set model_Q2D NO

#SPAN DIMENSION FOR QUASI 2D MODEL IN -Y DIRECTION | MAXIMUM 3.0
set span 1.0

#Fix number of points in spanwise direction? If YES, indicate number of points below. (YES/NO)
set fixed_snodes YES

#Number of points in spanwise direction. If you opt NO above, This parameter will be ignored
# and will be set automatically based on maximum spacing over wing, slat and flap.
set span_dimension 4

#CAE EXPORT:
#===================================================
#CAE SOLVER SELECTION. (Exp. SU2 or CGNS)
set cae_solver CGNS

#POLYNOMIAL DEGREE FOR HIGH ORDER MESH EXPORT (Q1:Linear - Q4:quartic) | FOR SU2 ONLY Q1
set POLY_DEG Q2

#USING HIGH ORDER GRID GUIDELINE SPECIFICATION IN GUIDELINE DIR (YES/NO)
set HO_GEN NO

#ENABLES CAE EXPORT (YES/NO)
set cae_export NO

#SAVES NATIVE FORMATS (YES/NO)
set save_native YES

#INITIAL GROWTH RATIOS FOR NODE DISTRIBUTION:
#===================================================
# region 1 con 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr 1.09

# region 2 con 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr 1.09

# region 3 con 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr 1.09
```

### Instruction

To generate a grid, you have to first run gridflowprop.py in the guideline directory to have grid specification files. The mesher.glf reads values from these files.

Then you can adjust the above mentioned parameters on top of the mesher.glf with respect to your desired mesh and execute it by Pointwise. In batch mode you can execute the script by:

```shell
pointwise -b mesher.glf
```
The entire grid generation is automated. The script's summary appears in the output.txt in the root directory after the mesh is compelete and you will find meshes in 'grids' directory in the root.

The mesher.glf handles other scripts. It calls toprepare.glf to import and prepare the configuration, divides the topology and creates boundary layer blocks on each elements. Then, it creates the first layer of structured multi-block domains. Then it calls extrusion.glf. Extrusion script extrudes the outer boundary obtained in the previous step until it reaches to the c-type domain. Then it calls smoother.glf to run the elliptic solver on all domains excluding boundary layer domains.

### CAE Export

The mesher.glf's preamble has five options that can be adjusted for CAE export. For quadratic, cubic and quartic meshes, you have to select CGNS format. The POLY_DEG indicates polynominal degree for mesh elevation. The HO_GEN lets you to read the grid specification through a separate file from guideline folder. For this, you need first generate the grid specification text file using the gridflowprop.py with HO set to YES in the python script. The cae_export exports the cae format you have selected. The save_native option saves the Pointwise format.

### Local and Global Elliptic Solvers

The mesher.glf handles two elliptic solvers: local and global for structured mesh, which are considered as smoother in the script. The local elliptic solver runs only on structured domains near the configuration. These domains are part of the first layer of structured domains created after the boundary layer block extrusion. The global elliptic solver runs on all domains including first and second layers except boundary layer blocks. The smoother.glf contains the global elliptic solver. The local elliptic solver is included in the mesher.glf.

The local and global smoothers are based on muligrid approach to solve the elliptic PDE on the grid and make sure that grid points and structured domains between slat, wing and flap and their interfaces are relaxed with nice orthogonality and distribution. The local elliptic solver runs only if the global smoother is switched off. In the mesher.glf, number of iterations for both smoothers can be indicated. The default number of iterations for the global smoother is 3000 and for the local smoother is 2000 to make sure that they are adequate for different levels of refinements. However, as very fine levels, like level 1 and 0, are chosen, more iterations might be needed, like around 7000. Therefore, script's runtime to generate grids can vary from 15 minutes for the coarsest level (e.g. res_lev 6) depending on your hardware to more than 16 hours for the finest level (e.g. res_lev 0). You might opt less number of iterations in order to decrease the runtime but result would not be as relaxed as the result obtained by the recommended values for smoother's number of iterations.

### Grid Dimension

The script can generate 2D and quasi 2D grids at the same time. The quasi 2d grid is translation of the 2d grid in -y direction. Translation's distance can be set by the parameter 'span' in the mesher.glf. Number of points in the span direction can be selected by setting 'fixed_snodes' to YES and assigning number of points to the 'span_dimension' parameter. If 'fixed_snodes' set to NO, 'span_dimension' will be ignored and number of points in the span direction automatically will be measured based on the maximum chordwise spacing on the upper surfaces of wing, slat and flap. For both types of grids, approximately upstream reaches to 1200c and downstream is about 7000c.

### Boundary Condition

For both 2D and quasi 2D grids boundary conditions are assigned appropriately to the right boundaries but are not set. Based on the solver, they can be set in Pointwise.

In case you encounter any issues using the scripts please use the issue feature on Github and let me know of that or send me an email. I will do my best to address that as soon as possible.

![grid1](https://github.com/pdpdhp/multielementmesher/blob/master/grid1.png)

![grid2](https://github.com/pdpdhp/multielementmesher/blob/master/grid2.png)

