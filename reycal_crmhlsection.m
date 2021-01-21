clc;
clear;
format long
gama=1.4;
% tetha=54.521484375;
%no=1.468e-005;
%kelvin521
T=272.1;
%288.15
%T_inch=521;
Re=5000000;

R=8314.4621;
Rs=287.058;
%inch
D=1.0;
%D_inch=275.8;
%pascal
P=101325;
%P_inch=24.67;
%density
ro=P/((R/28.966)*T);
C=sqrt(gama*(P/ro));
M=0.2;
V=C*M;
no=(V*D)/Re;
mo=ro*no;

Re1=(ro*V*D)/mo;

%sutherland's law
mo0 = 1.716e-05;
T0 = 272.1;
S = 198.6;
Ts = T;
mos = mo0 * ((Ts/T0)^(3/2)) * ((T0 + S)/(Ts + S));
%y+ calculation
%scholchting_skin_friction
cf=(2*log10(Re1)-0.65)^(-2.3);
ta_w=cf*0.5*ro*(V^2);

%friction_velo
us=sqrt(ta_w/ro);

%wall_distance
yp=[0.25;0.35;0.5;0.7;1.0;1.4;2.0];

ds=(yp.*mo)./(ro*us);
%ds_inch=ds.*39.37;
gr=[1.03;1.04;1.06;1.08;1.12;1.17;1.25];

% %fuselage
% f_csize=[0.001*D;0.0033*D;0.005*D;0.0075*D;0.01*D;0.015*D;0.0225*D];
% f_csize_inch=f_csize.*39.37;

%chordwise_spacing
Chord=D;
chord_csize=[0.0001*Chord;0.00033*Chord;0.0005*Chord;0.00075*Chord;0.001*Chord;0.0015*Chord;0.00225*Chord];
%chord_csize_inch=chord_csize.*39.37;

% %spanwise_spacing
% sspan=29.38145;
% span_csize=[0.0001*sspan;0.00033*sspan;0.0005*sspan;0.00075*sspan;0.001*sspan;0.0015*sspan;0.00225*sspan];
% span_csize_inch=span_csize.*39.37;

%TE Ratio
ter=[7.5e-06;1.5e-05;3.0e-05;0.6e-04;1.2e-04;2.5e-04;5e-04];
ler=ter./10;

%te_points
te1_points=[640;320;160;80;40;20;10];
te2_points=[320;160;80;40;20;10;5];

% delta_s_f=(y_p_f*mo)/(ro*u_star);
% delta_s_e=(y_p_e*mo)/(ro*u_star);
% delta_s_d=(y_p_d*mo)/(ro*u_star);
% delta_s_c=(y_p_c*mo)/(ro*u_star);
% delta_s_b=(y_p_b*mo)/(ro*u_star);
% delta_s_a=(y_p_a*mo)/(ro*u_star);

Exp=[0.9;0.9;0.9;0.9;0.9;0.9;0.9];
Imp=[100;100;100;100;100;100;100];
Vol=[0.001;0.0012;0.0014;0.0016;0.0018;0.020;0.018];
steps=[150;120;100;80;60;40;30];

grid_spec=[yp';ds';gr';chord_csize';ter';ler';te1_points';te2_points';Exp';Imp';Vol';steps'];
flow_spec=[Re1;D;P;T;ro;M];

% grid_spec_inch=[yp';ds_inch';gr';f_csize_inch';chord_csize_inch';span_csize_inch';mfactor';te_points'];


fileID = fopen('grid_specification.txt','w');
fprintf(fileID,'%7s %17s %9s %14s %10s %10s %4s %4s %9s %10s %10s %6s\n','Y+','Delta_S','GR','C_Spacing','TE Ratio','LE Ratio','TE1','TE2','ExpExtr','ImpExtr','VolExtr','NExtr');
fprintf(fileID,' % 1.3e  % 1.7e % 1.3e  % 1.3e % 1.3e % 1.3e % 4d % 4d % 1.3e % 1.3e % 1.3e % 3d\n',grid_spec);
% fprintf(fileID,' % 1.15e  % 1.15e  % 1.15e  % 1.15e \n',ynarray);
fclose(fileID);

fileID = fopen('flow_propertise.txt','w');
fprintf(fileID,'%10s %14s %12s %12s %20s %10s \n','Reynolds','Ref_chord(m)','Pressure(Pa)','Temp(K)','Density(Kg/m3)','Mach');
fprintf(fileID,'%1.5e  %1.5e %1.7e  %1.7e %1.15e  %1.5e\r\n',flow_spec);
% fprintf(fileID,' % 1.15e  % 1.15e  % 1.15e  % 1.15e \n',ynarray);
fclose(fileID);

% fileID = fopen('grid_specification_inch','w');
% fprintf(fileID,'%7s %24s %10s %27s %23s %22s %5s %3s \n','Y+','Delta_S(inch)','GR','Fuselage_Spacing(inch)','Chordwise_Spacing(inch)','Spanwise_Spacing(inch)','M_Factor','TE_Pts');
% fprintf(fileID,' % 1.3e  % 1.15e % 1.3e  % 1.15e % 1.15e  % 1.15e % 1.3e  %d\r\n',grid_spec_inch);
% % fprintf(fileID,' % 1.15e  % 1.15e  % 1.15e  % 1.15e \n',ynarray);
% fclose(fileID);


%q=0.5*ro*(((gama*Rs*T)^0.5)^2);
%omega=2*q*0.212;
%f=omega/(2*pi);
%period=1/f;

% ro=0.492898526539144;
% cp=1107;
% I=0.0605;
% mo=1.502937895875741e-005;
% T=576;
% P=81494;
% omega= 2.418875716644979e+004;
% Frequence= 3.849760270289991e+003;
% t=0:0.000007:0.02;
% theta=1.01.*sind(2.*pi.*f.*(t));
% theta_dot=(2.02*pi*f).*cosd(2.*pi.*f.*(t));
% plot(t,theta,'-r');
% figure();
% plot(t,theta_dot,'-b');
% t40=2.7662
