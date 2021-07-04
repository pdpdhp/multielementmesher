import numpy as np
import matplotlib as mpl

#----------------------------GRID GUIDELINE--------------------

#TARGET Y PLUS FOR RANS AND HYBRID RANS/LES
TARG_YPR = [0.25,0.35,0.5,0.7,1.0,1.4,2.0]

#BOUNDARY BLOCK CELL GROWTH RATE
TARG_GR=[1.03,1.04,1.06,1.08,1.12,1.17,1.25]

# CHORDWISE SPACING ACCORDING TO GRID GUIDELINE
CHR_SPC = [0.0002,0.00066,0.001,0.00125,0.002,0.003,0.0045]

# TRAILING EDGE SPACING RATIO ACCORDING TO GRID GUIDELINE
TE_SRT = [7.5e-06,1.5e-05,3.0e-05,0.6e-04,1.2e-04,2.5e-04,5e-04]

# TRAILING EDGE NUMBER OF POINTS ACCORDING TO GRID GUIDELINE
TE_PT1 = [640,320,160,80,40,20,10]

# TRAILING EDGE NUMBER OF POINTS ACCORDING TO GRID GUIDELINE
TE_PT2 = [320,160,80,40,20,10,10]

# EXPLICIT EXTRUSION FACTORS ACCORDING TO GRID GUIDELINE
EXP_FAC = [0.9,0.9,0.9,0.9,0.9,0.9,0.9]

# IMPLICIT EXTRUSION FACTORS ACCORDING TO GRID GUIDELINE
IMP_FAC = [100,100,100,100,100,100,100]

# NORMAL EXTRUSION VOLUME RATIO ACCORDING TO GRID GUIDELINE
VOL_FAC = [0.001,0.0012,0.0014,0.0016,0.0018,0.020,0.018]

# NORMAL EXTRUSION STEPS ACCORDING TO GRID GUIDELINE
EXTR_STP=[150,120,100,80,60,40,30]

#-------------------------HIGH ORDER DESCRETIZATION------------
# HO Grid (YES/NO)
HO_GRID = "YES"

#TARGET Y PLUS FOR HIGH ORDER DISCRETIZATION
TARG_YPH = [0.25,0.35,0.5,0.7,1.0,1.4,2.0]

#BOUNDARY BLOCK CELL GROWTH RATE FOR HIGH ORDER DISCRETIZATION
TARG_GRH=[1.03,1.04,1.06,1.08,1.12,1.17,1.25]

#====================================================================

NUM_LEVR = len(TARG_YPR)
NUM_LEVH = len(TARG_YPH)

#Flow Properties

#-----------------TEMPERATURE--------------
#(K)
T=272.1
#(R)
T_R = 489.78

#-----------------MACH NUMBER--------------
M=0.2

#------------------Reynolds----------------
Re = 5000000

#-----------------PRESSURE-----------------
#(Pa)
P=101325.0
#(psi)
P_psi=14.6959488

#-----------MEAN AERODYNAMIC CHORD--------
#(M)
D=1.0
#(INCH)
D_inch=1.0

#---------------GAS CONSTANT---------------
R=8314.4621
Rs=287.058
gama=1.4

#---------------IDEAL GAS-------------------
ro=P/((R/28.966)*T)

#---------------SOUND SPEED----------------
C=np.sqrt(gama*(P/ro))

#---------------VELOCITY-------------------
V=C*M

#KINEMATIC VISCOSITY/MOMENTOM DIFFUSIVITY--
no=(V*D)/Re

#--------DYNAMIC/ABSOLUTE VISCOSITY--------
mo=ro*no

#---REYNOLDS CHECK BASED ON IDEAL GAS------
Re1=(ro*V*D)/mo

#----SUTHERLAND LAW FOR FLOW PROPERTISE----
mo0 = 1.716e-05
mo0us = 2.488852e-9
T0 = 272.1
S = 198.6
Ts = T

#DYNAMIC/ABSOLUTE VISCOSITY based SUTHERLAND LAW
mos = mo0 * ((Ts/T0)**(3/2)) * ((T0 + S)/(Ts + S))

#-------DENSITY BASED ON SUTHERLAND ----------
ros = ((mos * Re)/(((gama*P)**0.5)*M*D))**2

#-----DENSITY BASED ON SUTHERLAND US----------
ros_lbinch3 = ros*3.6127292000084e-5

#-----SOUND SPEED BASED ON SUTHERLAND---------
Cs = np.sqrt(gama*(P/ros))

#-------VELOCITY BASED ON SUTHERLAND----------
Vs = Cs*M

#-----REYNOLD CHECK BASED ON SUTHERLAND-------
Res = (ros*Vs*D)/mos

#------------y+ calculation--------------------
#scholchting_skin_friction
cf=(2*np.log10(Re)-0.65)**(-2.3)

#----------WALL SHEAR STRESS------------------
ta_w=cf*0.5*ro*(V**2)
ta_ws=cf*0.5*ros*(Vs**2)

#-----------FRICTION VELOCITY----------------
us=np.sqrt(ta_w/ro)
uss=np.sqrt(ta_ws/ros)

# ---------- GRID PROPERTISE-----------------

Chord=D
chord_csize=np.array(CHR_SPC)*Chord
chord_csize_inch=chord_csize*39.37

ypr=np.array(TARG_YPR)
yph=np.array(TARG_YPH)
gr=np.array(TARG_GR)
grh=np.array(TARG_GRH)

teratio=np.array(TE_SRT)
leratio= teratio/10

te1_points=np.array(TE_PT1)
te2_points=np.array(TE_PT2)

Exp=np.array(EXP_FAC)
Imp=np.array(IMP_FAC)
Vol=np.array(VOL_FAC)

steps=np.array(EXTR_STP)

#-----------FIRST CELL HEIGHT | DELTA S-------
dsr=(ypr*mo)/(ro*us)
dssr=(ypr*mos)/(ros*uss)
dsr_inch=dsr*39.37
dssr_inch=dssr*39.37

dsh=(yph*mo)/(ro*us)
dssh=(yph*mos)/(ros*uss)
dsh_inch=dsh*39.37
dssh_inch=dssh*39.37

#------------------GRID PROPERTISE--------------
grid_spec=np.column_stack((ypr,dssr,gr,chord_csize[0:NUM_LEVR],teratio[0:NUM_LEVR],leratio[0:NUM_LEVR],te1_points[0:NUM_LEVR],te2_points[0:NUM_LEVR],Exp[0:NUM_LEVR],Imp[0:NUM_LEVR],Vol[0:NUM_LEVR],steps[0:NUM_LEVR]))

#GRID PROPERTIES INCH
grid_spec_inch=np.column_stack((ypr,dssr_inch,gr,chord_csize_inch[0:NUM_LEVR],teratio[0:NUM_LEVR],leratio[0:NUM_LEVR],te1_points[0:NUM_LEVR],te2_points[0:NUM_LEVR],Exp[0:NUM_LEVR],Imp[0:NUM_LEVR],Vol[0:NUM_LEVR],steps[0:NUM_LEVR]))

#GRID PROPERTIES INCH HIGH ORDER
grid_spec_ho=np.column_stack((yph,dssh,grh,chord_csize[0:NUM_LEVH],teratio[0:NUM_LEVH],leratio[0:NUM_LEVH],te1_points[0:NUM_LEVH],te2_points[0:NUM_LEVH],Exp[0:NUM_LEVH],Imp[0:NUM_LEVH],Vol[0:NUM_LEVH],steps[0:NUM_LEVH]))

#------------------FLOW PROPERTISE--------------
#FLOW PROPERTISE BASED ON SUTHERLAND | SI

flow_spec_si=np.array([Res,D,P,T,ros,M])

#FLOW PROPERTISE BASED ON SUTHERLAND | US
flow_spec_us=np.array([Res,D_inch,P_psi,T,ros_lbinch3,M])

#------------writing files---------------------
# grid propertise metric
f = open('grid_specification_metric.txt', 'w')
f.write("%7s %17s %9s %16s %7s %10s %4s %4s %9s %10s %10s %6s\n" % ("Y+","Delta_S(m)","GR","C_Spacing(m)","TE Ratio","LE Ratio","TE1","TE2","ExpExtr","ImpExtr","VolExtr","NExtr"))

for i in range(NUM_LEVR):
    f.write(" % 1.3e  % 1.7e % 1.3e  % 1.3e % 1.3e % 1.3e % 4d % 4d % 1.3e % 1.3e % 1.3e % 3d\n" % (grid_spec[i,0],grid_spec[i,1],grid_spec[i,2],\
    								grid_spec[i,3],grid_spec[i,4],grid_spec[i,5],grid_spec[i,6],grid_spec[i,7],grid_spec[i,8],grid_spec[i,9],grid_spec[i,10],grid_spec[i,11]))
f.close()

f = open('grid_specification_inch.txt', 'w')
f.write("%7s %17s %9s %16s %7s %10s %4s %4s %9s %10s %10s %6s\n" % ("Y+","Delta_S(in)","GR","C_Spacing(in)","TE Ratio","LE Ratio","TE1","TE2","ExpExtr","ImpExtr","VolExtr","NExtr"))

for i in range(NUM_LEVR):
    f.write(" % 1.3e  % 1.7e % 1.3e  % 1.3e % 1.3e % 1.3e % 4d % 4d % 1.3e % 1.3e % 1.3e % 3d\n" % (grid_spec_inch[i,0],grid_spec_inch[i,1],grid_spec_inch[i,2],\
    								grid_spec_inch[i,3],grid_spec_inch[i,4],grid_spec_inch[i,5],grid_spec_inch[i,6],grid_spec_inch[i,7],grid_spec_inch[i,8],grid_spec_inch[i,9],grid_spec_inch[i,10],grid_spec_inch[i,11]))
f.close()

f = open('flow_propertise_si.txt', 'w')
f.write("%10s %14s %12s %12s %20s %10s \n" % ("Reynolds","Ref_chord(m)","Pressure(Pa)","Temp(K)","Density(Kg/m3)","Mach"))

f.write("%1.5e  %1.5e %1.7e  %1.7e %1.15e  %1.5e\r\n" % (flow_spec_si[0],flow_spec_si[1],\
								flow_spec_si[2],flow_spec_si[3],flow_spec_si[4],flow_spec_si[5]))
f.close()

f = open('flow_propertise_us.txt', 'w')
f.write("%10s %17s %15s %11s %22s %10s \n" % ("Reynolds","Ref_chord(inch)","Pressure(psi)","Temp(K)","Density(lb/inch3)","Mach"))

f.write("%1.5e  %1.9e   %1.7e  %1.7e %1.15e  %1.5e\r\n" % (flow_spec_us[0],flow_spec_us[1],\
    									flow_spec_us[2],flow_spec_us[3],flow_spec_us[4],flow_spec_us[5]))
f.close()


if HO_GRID == "YES":
	f = open('grid_specification_HO.txt', 'w')
	f.write("%7s %17s %9s %16s %7s %10s %4s %4s %9s %10s %10s %6s\n" % ("Y+","Delta_S(in)","GR","C_Spacing(in)","TE Ratio","LE Ratio","TE1","TE2","ExpExtr","ImpExtr","VolExtr","NExtr"))
	for i in range(NUM_LEVH):
	    f.write(" % 1.3e  % 1.7e % 1.3e  % 1.3e % 1.3e % 1.3e % 4d % 4d % 1.3e % 1.3e % 1.3e % 3d\n" % (grid_spec_ho[i,0],grid_spec_ho[i,1],grid_spec_ho[i,2],\
    								grid_spec_ho[i,3],grid_spec_ho[i,4],grid_spec_ho[i,5],grid_spec_ho[i,6],grid_spec_ho[i,7],grid_spec_ho[i,8],grid_spec_ho[i,9],grid_spec_ho[i,10],grid_spec_ho[i,11]))
	f.close()
