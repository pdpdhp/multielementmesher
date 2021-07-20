High Lift's Pointwise's 2D CRM Mesher
================================

#### Introduction:
These scripts written to generate structured or unstrcutred grids on CRM high-lift 2D wing section. For both structured and unstrcutured, seven refinement levels by default is defined based on the flow properties and grid guideline specification files. These two files can be generated with customized parameters.

#### Instruction:

To generate a mesh you can run CRM2DMesher.glf with Pointwise in batch mode. Without specifying an input, it uses defaultMeshParameters.glf and takes grid parameters from there. To customize the grid input, you can edit them in customized_meshpara.template and generate the mesh by:

```shell
pointwise -b CRM2DMesher.glf customized_meshpara.template
```

After the mesh is complete, you can see summary of CAE export in CAE_export.out. Grid with indicated format will be saved in the grids directory.

#### Grid guideline:
Grid guideline specifications are calculated based on the flow condition in the gridflowprop.py in the guideline directory automatically during the grid generation process based on the grid input. To change grid specification, you can change target y+, boundary layer block growth rate, chordwise spacing, trailing spacing ratio, number of points at trailing edge, explicit, implicit, and volume factors for normal extrusion, and extrusion steps at the end of the customized_meshpara.template as your input file for different levels of grid refinement. If you set HO_GEN to YES then grid specification is adjusted based on the target y+ and boundary layer cell growth rate for high order meshes. Later to review these parameters, you may refer to guideline directory and check the grid specification files.

#### Multi-Block structured:

These parameters can be adjusted for multi-block structured grid generation in the input file (i.e. customized_meshpara.template):

```Tcl
#GRID SYSTEM'S ARRANGEMENT: STRUCTURED OR UNSTRUCTRED
#====================================================
#PLEASE SELECT GRID SYSTEM:
set GRD_TYP                      STR;# STR (for STRUCTURED) | UNSTR (for UNSTRUCTURED)

# STRUCTURED SETTINGS:
#====================================================
#GLOBAL AND LOCAL SMOOTHER FOR GRD_TYP: STR
#----------------------------------------------------
# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS EXCLUDING BOUNDARY LAYERS. 
set global_smth                 YES;# (YES/NO)

# NUMBER OF ITERATIONS FOR GLOBAL ELLIPTIC SOLVER
set gsmthiter                  3000;# (>1000 is recommended)

# TO RUN ELLIPTIC SOLVER OVER ALL DOMAINS | INCLUDES NEAR CONFIG DOMAINS. 
set local_smth                   NO;# (YES/NO) | RUNS ONLY IF GLOBAL SMOOTHER IS OFF

# NUMBER OF ITERATIONS TO RUN LOCAL ELLIPTIC SOLVER.
set lsmthiter                  2000;# (>1000 is recommended)
```

#### Unstructured:

These parameters can be adjusted for unstructured grid generation in the input file (i.e. customized_meshpara.template):

```Tcl
#GRID SYSTEM'S ARRANGEMENT: STRUCTURED OR UNSTRUCTRED
#====================================================
#PLEASE SELECT GRID SYSTEM:
set GRD_TYP                    UNSTR;# STR (for STRUCTURED) | UNSTR (for UNSTRUCTURED)

# UNSTRUCTURED SETTINGS:
#====================================================
#UNSTRUCTRED GRID PROPERTIES FOR GRD_TYP: UNSTR
#----------------------------------------------------
#UNSTRUCTURED SOLVER ALGORITHM: 
set UNS_ALG      AdvancingFrontOrtho;# AdvancingFront | AdvancingFrontOrtho | Delaunay

#UNSTRUCTRED SOLVER CELL TYPE: 
set UNS_CTYP            TriangleQuad;# TriangleQuad | Triangle

#GENERAL DECAY FACTOR FOR UNSTRUCTRED SOLVER
set SIZE_DCY                     0.6;# From 0.0 to 1.0 | larger mesh becomes denser around config
```

#### General setting:

Below mentioned parameters can be adjusted to generate either structured or unstructured mesh in the input file (i.e. customized_meshpara.template):

```Tcl
#               GRID REFINEMENT LEVEL:
#=====================================================
#Grid Levels vary from the first line (finest, level 0) of the grid_specification.txt to the last line (coarsest, level 6)!
set res_lev                        6;# From  0 (finest) to 6 (coarsest)

# GRID DIMENSION:
#===================================================
#2D DIMENSIONAL MESH 
set model_2D                    YES;# (YES/NO)

#QUASI 2D MESH | GENERATES AN EXTRUDED VERSION 
set model_Q2D                   YES;# (YES/NO)

#SPAN DIMENSION FOR QUASI 2D MODEL IN -Y DIRECTION
set span                        1.0;# MAXIMUM 3.0

#Fix number of points in spanwise direction? If YES, indicate number of points below. 
set fixed_snodes                YES;# (YES/NO)

#Number of points in spanwise direction. If you opt NO above, This parameter will be ignored
# and will be set automatically based on maximum spacing over wing, slat and flap.
set span_dimension                4;# Only when fixed_snodes is NO

#CAE EXPORT:
#===================================================
#CAE SOLVER SELECTION. 
set cae_solver                 CGNS;# (Exp. SU2 or CGNS)

#POLYNOMIAL DEGREE FOR HIGH ORDER MESH EXPORT 
set POLY_DEG                     Q1;# (Q1:Linear - Q4:quartic) | FOR SU2 ONLY Q1

#USING HIGH ORDER GRID GUIDELINE SPECIFICATION IN GUIDELINE DIR 
set HO_GEN                       NO;# (YES/NO)

#ENABLES CAE EXPORT 
set cae_export                  YES;# (YES/NO)

#SAVES NATIVE FORMATS 
set save_native                 YES;# (YES/NO)
```

#### Grid Dimension:
The script can generate 2D and quasi 2D grids at the same time. The quasi 2d grid is translation of the 2d grid in -y direction. Translation's distance can be set by the parameter 'span' in the input file. Number of points in the span direction can be indicated by setting 'fixed_snodes' to YES and assigning number of points to the 'span_dimension'. If 'fixed_snodes' set to NO, 'span_dimension' will be ignored and number of points in the span direction automatically will be measured based on the maximum chordwise spacing on the upper surfaces of wing, slat and flap. For both types of grids, approximately upstream reaches to 1200c and downstream gets to about 7000c.

#### More information:
The CRM2DMesher.glf handles the mesh generation procedure. It reads the meshing paramter input or uses the default values in case there is no input. Then updates the meshing guideline specifications based on the input, reads the CAD model, prepares the topology and generates the mesh. It calls extrusion script for structured meshing or unstrdiag for unstrcutred meshing. For strcutured meshing based on the input, calls local or global smoothers. In the end, calls cae_exporter to export the grid.

#### Local and Global Elliptic Solvers:
The CRM2DMesher.glf handles two elliptic solvers: local and global for structured mesh, which are considered as smoother in the script. The local elliptic solver runs only on structured domains near the configuration. These domains are part of the first layer of structured domains created after the boundary layer block extrusion. The global elliptic solver runs on all domains including first and second layers except boundary layer blocks. The smoother.glf contains the global elliptic solver. The local elliptic solver is included in the CRM2DMesher.glf.

The local and global smoothers are based on muligrid approach to solve the elliptic PDE on the grid and make sure that grid points and structured domains between slat, wing and flap and their interfaces are relaxed with nice orthogonality and distribution. The local elliptic solver runs only if the global smoother is switched off. In the input file, number of iterations for both smoothers can be defined. The default number of iterations for the global smoother is 3000 and for the local smoother is 2000 to make sure that they are adequate for different levels of refinements. However, as very fine levels, like level 1 and 0, are chosen, more iterations might be needed, like around 7000. Therefore, script's runtime to generate grids can vary from 15 minutes for the coarsest level (e.g. res_lev 6) depending on your hardware to more than 16 hours for the finest level (e.g. res_lev 0). You might opt less numbers of iterations in order to decrease the runtime but result would not be as relaxed as the result obtained by the recommended values.

#### CAE Export:
In the input file you can have five options for CAE export. For quadratic, cubic and quartic meshes, you have to select CGNS format. The POLY_DEG indicates polynominal degree for mesh elevation. The HO_GEN lets you to have a separate guideline for high order meshes. This guideline can be defined at the bottom of the input file (i.e. customized_meshpara.template). The cae_export defines the CAE format. The save_native option saves the Pointwise format.

#### Boundary condition:
For both 2D and quasi 2D grids boundary conditions are named and assigned appropriately to the right surface meshes but they are not explicitly specified.


#### 2D Unstructured:

![UNSTR_DT](https://github.com/pdpdhp/multielementmesher/blob/master/pics/UNSTR_DT.png)

![UNSTR_ATQ](https://github.com/pdpdhp/multielementmesher/blob/master/pics/UNSTR_ATQ.png)

![UNSTR_AOTQ](https://github.com/pdpdhp/multielementmesher/blob/master/pics/UNSTR_AOTQ.png)

#### Quasi 2D Unstructured:

![UNSTR_AOTQ_Q2D](https://github.com/pdpdhp/multielementmesher/blob/master/pics/UNSTR_AOTQ_Q2D.png)

#### 2D Structured:

![STR](https://github.com/pdpdhp/multielementmesher/blob/master/pics/STR.png)

#### Quasi 2D Structured:

![STR_Q2D](https://github.com/pdpdhp/multielementmesher/blob/master/pics/STR_Q2D.png)


