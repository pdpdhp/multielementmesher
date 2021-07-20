# =============================================================
# This script is written to generate structured multi-block or
# unstructured grids with different refinement levels over the
# CRM high-lift 2D section according to grid guideline.
#==============================================================
# written by Pay Dehpanah
# last update: July 2021
#==============================================================

#            MULTI-ELEMENT CONFIGURATION:
#=====================================================
#multi-element airfoil selection (CRMHL-2D or 30P30N)

set airfoil                 CRMHL-2D;# Currently only 2D CRM-HL WING SECTION is supported!

#               GRID REFINEMENT LEVEL:
#=====================================================
#Grid Levels vary from the first line (finest, level 0) of the grid_specification.txt to the last line (coarsest, level 6)!
set res_lev                        6;# From  0 (finest) to 6 (coarsest)

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

# GENERAL SETTINGS:
#==================================================
#GROWTH RATIOS:
#--------------------------------------------------
#general chordwise growth ratio for node distribution over the wing, flap, and slat.
set srfgr                      1.25;

#chordwise growth ratio for node distribution over the wing's lower surface.
set srfgrwl                     1.2;

#chordwise growth ratio for node distribution over the slat's upper surface.
set srfgrfu                     1.2;

#INITIAL GROWTH RATIOS FOR NODE DISTRIBUTION:
#===================================================
# region 1 con 1 growth ratio --> region 1 refers to the region on top of the slat!
set r1c1gr                     1.09;

# region 2 con 3 growth ratio --> region 2 refers to the region on top of the wing!
set r2c3gr                     1.09;

# region 3 con 1 growth ratio --> region 3 refers to the region on top of the flap!
set r3c1gr                     1.09;

#-------------------------------------- GRID GUIDELINE--------------------------------------

#TARGET Y PLUS FOR RANS AND HYBRID RANS/LES
set TARG_YPR                              {0.25,0.35,0.5,0.7,1.0,1.4,2.0}

#BOUNDARY BLOCK CELL GROWTH RATE
set TARG_GR                          {1.03,1.04,1.06,1.08,1.12,1.17,1.25}

# CHORDWISE SPACING ACCORDING TO GRID GUIDELINE
set CHR_SPC             {0.0002,0.00066,0.001,0.00125,0.002,0.003,0.0045}

# TRAILING EDGE SPACING RATIO ACCORDING TO GRID GUIDELINE
set TE_SRT      {7.5e-06,1.5e-05,3.0e-05,0.6e-04,1.2e-04,2.5e-04,5.0e-04}

# TRAILING EDGE NUMBER OF POINTS ACCORDING TO GRID GUIDELINE
set TE_PT1                                      {640,320,160,80,40,20,10}

# TRAILING EDGE NUMBER OF POINTS ACCORDING TO GRID GUIDELINE
set TE_PT2                                       {320,160,80,40,20,10,10}

# EXPLICIT EXTRUSION FACTORS ACCORDING TO GRID GUIDELINE
set EXP_FAC                                 {0.9,0.9,0.9,0.9,0.9,0.9,0.9}

# IMPLICIT EXTRUSION FACTORS ACCORDING TO GRID GUIDELINE
set IMP_FAC                                 {100,100,100,100,100,100,100}

# NORMAL EXTRUSION VOLUME RATIO ACCORDING TO GRID GUIDELINE
set VOL_FAC               {0.001,0.0012,0.0014,0.0016,0.0018,0.020,0.018}

# NORMAL EXTRUSION STEPS ACCORDING TO GRID GUIDELINE
set EXTR_STP                                    {150,120,100,80,60,40,30}

#-----------HIGH ORDER MESH SPECIFICATIONS------------

#TARGET Y PLUS FOR HIGH ORDER DISCRETIZATION
set TARG_YPH                           {1.0,5.0,10.0,20.0,30.0,40.0,50.0}

#BOUNDARY BLOCK CELL GROWTH RATE FOR HIGH ORDER DISCRETIZATION
set TARG_GRH                         {1.03,1.04,1.06,1.08,1.12,1.17,1.20}

#------------------------------------------------------------------------------------------
