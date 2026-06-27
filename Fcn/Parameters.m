%%
if exist('flywpt')
WPT=importdata(flywpt);
else
WPT = importdata('guidance_data.xlsx');
end
%% 飞机模型
env = struct;
env.ISA_lapse = WPT.data.Sheet3(1,1);%°C/m 温度直减率
env.ISA_hmax = WPT.data.Sheet3(2,1);
env.ISA_R = WPT.data.Sheet3(3,1);%J/kg/K   特征气体常数      P=P0(1-lapse/T0)^(g/(lapse*R))   平均海平面<h<对流层 （一般大于10000m）
env.ISA_g = WPT.data.Sheet3(4,1);%重力加速度
env.ISA_rho0 = WPT.data.Sheet3(5,1);%海平面空气标准密度 km/m3
env.ISA_P0 = WPT.data.Sheet3(6,1);%海平面气压 帕
env.ISA_T0 = WPT.data.Sheet3(7,1);%平均海平面标准温度 K
% env.windBase = 12;%基础风速
% env.windDirTurb = 180;%扰动
% env.windDirHor = 90;%
% env.windOn = 0;

B747 = struct;
B747.geometry = struct;
% B747.geometry.span = 59.6;%翼展b 59.74
B747.geometry.span = WPT.data.Sheet3(8,1);%翼展b 59.74
B747.geometry.chord = WPT.data.Sheet3(9,1);%平均几何弦长cA
% B747.geometry.S = 510.95;%面积s 510.97
B747.geometry.S = WPT.data.Sheet3(10,1);%面积s 510.97
B747.geometry.elarm = WPT.data.Sheet3(11,1); %
B747.geometry.mass = WPT.data.Sheet3(12,1);%起飞质量
B747.geometry.massEmpty = WPT.data.Sheet3(13,1);%空载质量
B747.geometry.massFull = WPT.data.Sheet3(14,1);%满油质量
B747.inertia = struct;
% B747.inertia.Ixx = 24675560;%转动惯量
% B747.inertia.Iyy = 44876980;
% B747.inertia.Izz = 67383260;
B747.inertia.Ixx = WPT.data.Sheet3(15,1);%转动惯量
B747.inertia.Iyy = WPT.data.Sheet3(16,1);
B747.inertia.Izz = WPT.data.Sheet3(17,1);
B747.inertia.Ixz = WPT.data.Sheet3(18,1);

B747.aero = struct;
B747.aero.alpha0 =WPT.data.Sheet3(19,1);
B747.aero.CL0 = WPT.data.Sheet3(20,1);%零升力系数
B747.aero.CLa =WPT.data.Sheet3(21,1);%升力系数对迎角的导数
% B747.aero.CLa_dot = 2.64; %7.0
B747.aero.CLa_dot =WPT.data.Sheet3(22,1); %7.0
B747.aero.CLq = WPT.data.Sheet3(23,1);%%%%%%%%升力系数对俯仰角速率的导数
B747.aero.CLDe =WPT.data.Sheet3(24,1);%升力系数对升降舵的导数
B747.aero.CLDf = WPT.data.Sheet3(25,1);%%%%%%%%%%%%升力系数对襟翼导数
B747.aero.CD0 = WPT.data.Sheet3(26,1);%零升阻力系数
B747.aero.CDa =WPT.data.Sheet3(27,1);%阻力系数对迎角的导数
% B747.aero.CDp = 0.01;%%%%%%%阻力系数对滚转角速率的导数 0
B747.aero.CDp = WPT.data.Sheet3(28,1);%%%%%%%阻力系数对滚转角速率的导数 0
B747.aero.CYb = WPT.data.Sheet3(29,1);%侧力系数对侧滑角的导数
B747.aero.CYDr =WPT.data.Sheet3(30,1);%侧力系数对方向舵的导数
B747.aero.Clb = WPT.data.Sheet3(31,1);%滚转力矩系数对侧滑角的导数 
B747.aero.Clp = WPT.data.Sheet3(32,1);%滚转力矩系数对滚转角速率的导数
B747.aero.Clr = WPT.data.Sheet3(33,1);%滚转力矩系数对偏航角度率的导数
B747.aero.ClDa = WPT.data.Sheet3(34,1);%%%%%%%%%滚转力矩系数对副翼的导数 %%%%%负的么 -0.013
B747.aero.ClDr = WPT.data.Sheet3(35,1);%滚转力矩系数对方向舵的导数
B747.aero.Cm0 =WPT.data.Sheet3(36,1);%零升力矩系数
B747.aero.Cma = WPT.data.Sheet3(37,1);%俯仰力矩系数对迎角的导数
% B747.aero.Cma_dot = 0;%-4
B747.aero.Cma_dot =WPT.data.Sheet3(38,1);%-4
% B747.aero.Cmq = -20;%俯仰力矩系数对俯仰角速率的导数 -20.5
B747.aero.Cmq = WPT.data.Sheet3(39,1);%俯仰力矩系数对俯仰角速率的导数 -20.5
B747.aero.CmDe = WPT.data.Sheet3(40,1);%俯仰力矩系数对升降舵的导数
B747.aero.CmDf = WPT.data.Sheet3(41,1);%%%%%%%%%俯仰力矩系数对襟翼导数
B747.aero.Cnb = WPT.data.Sheet3(42,1);%偏航力矩系数对侧滑角的导数
B747.aero.Cnp = WPT.data.Sheet3(43,1);%偏航力矩系数对滚转角速率的导数
B747.aero.Cnr = WPT.data.Sheet3(44,1);%偏航力矩系数对偏航角度率的导数
B747.aero.CnDa = WPT.data.Sheet3(45,1);%偏航力矩系数对副翼的导数
B747.aero.CnDr = WPT.data.Sheet3(46,1);%偏航力矩系数对方向舵的导数

B747.engine = struct;
B747.engin.MaxThrust = WPT.data.Sheet3(47,1); %Unit:N 最大推力
B747.engine.Idle = WPT.data.Sheet3(48,1);%慢车位
B747.engine.static =WPT.data.Sheet3(49,1);%海平面推力时间常数
B747.engine.fuelcon = WPT.data.Sheet3(50,1);%海平面推力燃料消耗比
B747.engine.ratio = WPT.data.Sheet3(51,1);%安装推力比
% 模型初始条件
B747.ic = struct;
B747.ic.gsLL =navParam.InitialLLA(1:2);%纬经
B747.ic.gsH = navParam.InitialLLA(3);%高
B747.ic.Pos_0 = [0;0;B747.ic.gsH ];%初始位置
InitialKai=navParam.InitialKai * pi/180;
if InitialKai>pi
    InitialKai=InitialKai-pi;
elseif InitialKai<-pi
    InitialKai=InitialKai+pi;
end
B747.ic.Euler_0 = [0; 0; InitialKai];%初始姿态  
clear InitialKai
B747.ic.Omega_0 = [0; 0; 0];
B747.ic.PQR_0 = [0.001; 0.001; 0.001];%初始角速率
B747.ic.Vb_0 = [navParam.InitialVelocity; 0;0];%初始速度
B747.sampleTime = WPT.data.Sheet3(52,1);

% 控制舵面、滚转角、俯仰角限幅
control = struct;
control.dtLimit = 0.99;%油门
control.deLimit = 30*pi/180;%升降舵
control.daLimit = 20*pi/180;%副翼
control.drLimit = 10*pi/180;%方向舵
control.theta_Limit = 30*pi/180;%俯仰
control.phi_cLimit = 25*pi/180;%滚转