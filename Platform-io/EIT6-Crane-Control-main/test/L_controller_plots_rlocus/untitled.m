%% Import data %%
% Read CSV files
neg1 = readtable('stepv2/data-1.csv');
neg2 = readtable('stepv2/data-2.csv');
neg3 = readtable('stepv2/data-3.csv');
neg7 = readtable('stepv2/data-7.csv');

pos1 = readtable('stepv2/data1.csv');
pos2 = readtable('stepv2/data2.csv');
pos3 = readtable('stepv2/data3.csv');
pos7 = readtable('stepv2/data7.csv');

% Moving mean length (Not in use)
mn = 20;

% Calculate velocity (Not in use)
v_neg1 = diff(movmean(neg1.Var2,mn))./diff(neg1.Var1)*1e6;
v_neg2 = diff(movmean(neg2.Var2,mn))./diff(neg2.Var1)*1e6;
v_neg3 = diff(movmean(neg3.Var2,mn))./diff(neg3.Var1)*1e6;
v_neg7 = diff(movmean(neg7.Var2,mn))./diff(neg7.Var1)*1e6;
v_pos1 = diff(movmean(pos1.Var2,mn))./diff(pos1.Var1)*1e6;
v_pos2 = diff(movmean(pos2.Var2,mn))./diff(pos2.Var1)*1e6;
v_pos3 = diff(movmean(pos3.Var2,mn))./diff(pos3.Var1)*1e6;
v_pos7 = diff(movmean(pos7.Var2,mn))./diff(pos7.Var1)*1e6;

% Makes time vector for velodity (Not in use)
tv_neg1 = neg1.Var1(1:length(neg1.Var1)-1,1);
tv_neg2 = neg2.Var1(1:length(neg2.Var1)-1,1);
tv_neg3 = neg3.Var1(1:length(neg3.Var1)-1,1);
tv_neg7 = neg7.Var1(1:length(neg7.Var1)-1,1);
tv_pos1 = pos1.Var1(1:length(pos1.Var1)-1,1);
tv_pos2 = pos2.Var1(1:length(pos2.Var1)-1,1);
tv_pos3 = pos3.Var1(1:length(pos3.Var1)-1,1);
tv_pos7 = pos7.Var1(1:length(pos7.Var1)-1,1);


%% Define model %%

syms s

% Constants
ke = 0.71;
rl = 0.05;
bl = 20;
j = 0.2; %0.8
ml = 3.89;

% Model
G = (ke*rl)/(((ml*s+bl)*rl^2+j*s)*s);

% Inverse laplace transform (Remember that 1/s = step in laplace domain)
fnc = ilaplace(G*(1/s));

% Make into function
gt = matlabFunction(fnc);

% Generate time interval
x = linspace(0,10,200);

% Make for different currents
m_neg1 = gt(x)*-1;
m_neg2 = gt(x)*-2;
m_neg3 = gt(x)*-3;
m_neg7 = gt(x)*-7;

m_pos1 = gt(x)*1;
m_pos2 = gt(x)*2;
m_pos3 = gt(x)*3;
m_pos7 = gt(x)*7;

%% Plot figures %%
%Moving mean length
mn = 100;

figure(1)
tiledlayout(2,4);
nexttile
plot(neg1.Var1/1e6-43, movmean(neg1.Var2,mn)-1.25,x,m_neg1)
xlabel('Time') 
ylabel('Position')
title('neg 1')
grid on

nexttile
plot(neg2.Var1/1e6-134, movmean(neg2.Var2,mn)-1.25,x,m_neg2)
xlabel('Time') 
ylabel('Position')
title('neg 2')
grid on

nexttile
plot(neg3.Var1/1e6-220.5, movmean(neg3.Var2,mn)-1.25,x,m_neg3)
xlabel('Time') 
ylabel('Position')
title('neg 3')
grid on

nexttile
plot(neg7.Var1/1e6-321.3, movmean(neg7.Var2,mn)-1.25,x,m_neg7)
xlabel('Time') 
ylabel('Position')
title('neg 7')
grid on

nexttile
plot(pos1.Var1/1e6-381, movmean(pos1.Var2,mn)-0.07,x,m_pos1)
xlabel('Time') 
ylabel('Position')
title('pos 1')
grid on

nexttile
plot(pos2.Var1/1e6-439, movmean(pos2.Var2,mn)-0.07,x,m_pos2)
xlabel('Time') 
ylabel('Position')
title('pos 2')
grid on

nexttile
plot(pos3.Var1/1e6-516.3, movmean(pos3.Var2,mn)-0.07,x,m_pos3)
xlabel('Time') 
ylabel('Position')
title('pos 3')
grid on

nexttile
plot(pos7.Var1/1e6-576.95, movmean(pos7.Var2,mn)-0.07,x,m_pos7)
xlabel('Time') 
ylabel('Position')
title('pos 7')
grid on

%% Design of controller %%

% Define transfer function variable
s = tf('s');

% Constants
ke = 0.71;
rl = 0.05;
bl = 20;
j = 0.2; %0.8
ml = 3.89; %3.89 %0.951
Ml = ml+((4*j)/rl^2);

% Model
%G = (ke*rl)/(((ml*s+bl)*rl^2+j*s)*s);
G = (ke*Ml^-1)/(rl*(s^2+s*Ml^-1*bl))

% Make bodeplot without any controller
figure(2)
margin(G)

% Define controller
kp = 170;
ki = 0;
kd = 80; %Ophæver polen i -0.0617 -> solve(0=1*(1+kd*(-0.0617)),kd)

% Requriments for controller (the system type is type 1 = one pole in 0, but second order system = s^2):
% zeta = 0.61
% omega_n = 1 rad/s
% setteling time 5s
% overshoot not so high that the speed of the impact exceed 0.5 m/s

%Find poles
pole(G)

% Define controller
D = (kp+ki*1/s+kd*s);

% Make bodeplot with controller
figure(3)
margin(D*G)

% Make closed loop with unity feedback
fb = feedback(D*G,1);

% Make step with controller
figure(4)
step(fb)
grid on

%%

figure(5)
rlocus(G*((1+(1/2)*s)))
%rlocus(G)
%zgrid(0.71,1)
%xlim([-1.2 0.2])
%ylim([-1.2 1.2])
%ylim([-2.5 2.5])
x = [0.54,0.54];
y = [0.6,0.5];
x1 = [0.55,0.55];
y1 = [0.4,0.49];
a = annotation('textarrow',x,y,'String','Gain = 150 ');
b = annotation('textarrow',x1,y1,'String','Gain = inf ');
%text(-1.5,0.85,'\zeta =')
%text(-1.5,-0.85,'\zeta =')
%text(-1.58,0.1,'\omega_n =')

%text(-0.8,0.15,'45.23^{\circ}', 'FontSize', 8)
xlim([-4.5 0.1])
axis equal


x0=0;
   y0=0;
   plotwidth=600;
   height=400;
   set(gcf,'position',[x0,y0,plotwidth,height])
   
exportgraphics(gcf,'plant_rlocus_zero_2.pdf','ContentType','vector')


figure(6)
%rlocus(G*((1+(1/2)*s)))
rlocus(G)
%zgrid(0.71,1)
%xlim([-2.5 0.1])
%ylim([-1.2 1.2])
%xlim([-4.5 0.2])
%ylim([-2.5 2.5])
%x = [0.54,0.54];
%y = [0.6,0.5];
%x1 = [0.55,0.55];
%y1 = [0.4,0.49];
%a = annotation('textarrow',x,y,'String','Gain = 150 ');
%b = annotation('textarrow',x1,y1,'String','Gain = inf ');
axis equal
%text(-0.99,0.755,'\zeta =')
%text(-0.99,-0.755,'\zeta =')
%text(-1.24,0.03,'\omega_n =')

%text(-0.25,0.3,'45.23^{\circ}', 'FontSize', 8)

x0=0;
   y0=0;
   plotwidth=600;
   height=400;
   set(gcf,'position',[x0,y0,plotwidth,height])
   
exportgraphics(gcf,'plant_rlocus.pdf','ContentType','vector')

cl1 = feedback(G*(150*(1+(1/2)*s)),1);
pole(cl1)

figure(7)
step(cl1)

figure(8)
margin(G)

figure(9)
ny_kp = 150;
ny_kd = 1/2;

con = ny_kp*(1+ny_kd*s)
margin(G*con)

figure(10)
step(feedback(con*G,1))
pole(feedback(con*G,1))
zero(feedback(con*G,1))

%%
G_ny = (1+1/2*s)/(1+1/2*s);
d_ny = (150);

cl_ny = feedback(G_ny*d_ny,1);
figure(11)
step(cl_ny)

