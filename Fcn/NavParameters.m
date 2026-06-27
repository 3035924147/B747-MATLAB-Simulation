if exist('flywpt')
WPT=importdata(flywpt);
else
WPT = importdata('guidance_data.xlsx');
end

GP.lat = WPT.data.Sheet1(:,1);%纬度
GP.lon = WPT.data.Sheet1(:,2);%经度
GP.hei = WPT.data.Sheet1(:,3);%高度

GP.inital_LLA = [GP.lat(1),GP.lon(1),GP.hei(1)];%初始纬经高
GP.end_LLA = [GP.lat(end),GP.lon(end),GP.hei(end)];%结束时纬经高 
GP.Xe = lla2flat([GP.lat GP.lon GP.hei],GP.inital_LLA(1:2),0,0);%转换至地球系   北东地

%出发机场

airport.ZLXY.Angle = WPT.data.Sheet2(1,1);
airport.ZLXY.LLA = GP.inital_LLA;
airport.ZLXY.Position = GP.Xe(1,:);
% 到达机场
airport.ZBAA.Angle = WPT.data.Sheet2(7,1);
airport.ZBAA.LLA = GP.end_LLA;
airport.ZBAA.Position = GP.Xe(end,:);
clear GP

%% flight parameters
TakeOff.Speed = 70;%起飞速度
TakeOff.Flap_Size = 0; % deg 起飞襟翼大小
TakeOff.Flap_h = 1000; %收襟翼高度
TakeOff.N1= 90;   % 地面起飞滑跑油门
TakeOff.VerSpeed = 25;  % 起飞垂直速度
TakeOff.Hei = 1000; % 起飞离场开始偏航的高度

Climb.FirstN1 = 75;%第一阶段爬升油门
Climb.FirstVerSpeed = 13; %第一阶梯爬升段 垂直速率
Climb.FirstHeight = 4000;%第一阶段爬升高度
Climb.LevSpeed = 180; %水平加速段终止速度
Climb.SecondN1 = 85;%第二爬升阶段油门
Climb.SecondVerSpeed = 10; %第二阶梯爬升段 垂直速率

Curise.Speed = 230;% 巡航速度
Curise.Height = WPT.data.Sheet2(9,1); % 巡航高度

Decline.N1 = 30;%下降段油门
Decline.VerSpeed = -6;%下降段垂直速率
Decline.FirstHeight = 4000;%下降段到达高度
Decline.LevSpeed = 150; %水平段终止速度


%% 仪表进近
APP = struct;
APP.AptEle = 35.3;%机场标高，m
APP.EntEle = 39.9;%入口标高，m
APP.VAR = 6; %磁差6°W
APP.DA = 90; %Decision Altitude，m 决断高度
APP.DH = APP.DA - round(APP.EntEle); %决断高度距离入口标高距离            round 四舍五入至最近整数
APP.GP = -3;%下滑角，deg
APP.RunHead = airport.ZBAA.Angle;%18L跑道磁航向，deg

% 进场进近（36R 古北口LR-21A进场）
APP.pos.HUR = [WPT.data.Sheet2(1,2), WPT.data.Sheet2(1,3)];%导航台纬经
APP.pos.PEK = airport.ZBAA.LLA(1:2); % 机场纬经


APP.kai.HUR_IAF = WPT.data.Sheet2(1,5);%导航台到起始进近定位点偏航角
APP.kai.PEK_IF =  WPT.data.Sheet2(2,5);%%%机场到中间进近定位点偏航角度
APP.kai.PEK_FAF = WPT.data.Sheet2(3,5); %%%机场到最后进近定位点偏航角度
APP.kai.PEK_MAPt =WPT.data.Sheet2(4,5);%%%机场到复飞点偏航角度


% APP.height.LR = 4000;%进场高度
APP.height.HUR = 4000;%进场高度
APP.height.IAF = 1500; %起始进近定位点
APP.height.LOC = 1500; %定位点 航向台
APP.height.IF = 1200;%中间进近定位点
APP.height.FAF = 1200;%最终进近定位点

% 单位换算：海里-米 1海里=1852米
APP.d.IAF_HUR = WPT.data.Sheet2(1,6) *1852;%起始进近点到怀柔导航台
APP.d.IF_PEK = WPT.data.Sheet2(2,6) *1852;%中间进近点到机场
APP.d.FAF_PEK = WPT.data.Sheet2(3,6) *1852;%最终进近点到机场
APP.d.MAPt_PEK = WPT.data.Sheet2(4,6) *1852;%复飞点到机场

% APP.speed.LR = 130; %进场速度,m/s
APP.speed.HUR = 130; %进场速度,m/s
APP.speed.IAF = 100; %起始进近速度,m/s
APP.speed.FAF = 80; %最终进近速度m/s

% 拉平
Flare.Height = 15;%拉平高度
Flare.VS = -0.5; %接地垂直速度0.5m/s
Flare.tao = 10; %拉平时间常数，s
%%
%导航参数
navParam = struct;
navParam.g = 9.80665;%重力加速度
navParam.R = 10000;%
navParam.RSmall = 4000;

navParam.d2r = pi/180;%单位换算 海里-米 1海里=1852米，1弧度=57.3度
navParam.r2d = 180/pi;
navParam.m2nm = 0.00054;
navParam.nm2m = 1852;

navParam.Re = 6378137;%长轴，m
navParam.Rp = 6356752;%短轴，m
navParam.RL = 6371393;%正球体半径，m
navParam.e = (navParam.Re-navParam.Rp)/navParam.Re;%扁率


%% 这是啥啊？？？？？？？？？？？%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
navParam.K1 = 1+3/4*navParam.e^2+45/64*navParam.e^4+175/256*navParam.e^6+11025/16384*navParam.e^8;
navParam.K2 = -3/4*navParam.e^2-15/32*navParam.e^4-525/1024*navParam.e^6-2205/4096*navParam.e^8;
navParam.K3 = 15/256*navParam.e^4+105/1024*navParam.e^6+2205/16384*navParam.e^8;
navParam.K4 = -35/3072*navParam.e^6-105/4096*navParam.e^8;
navParam.K5 = 315/131072*navParam.e^8;

navParam.a2 = 3/8*navParam.e^2+3/16*navParam.e^4+213/2048*navParam.e^6+255/4096*navParam.e^8;
navParam.a4 = 21/256*navParam.e^4+21/256*navParam.e^6+533/8192*navParam.e^8;
navParam.a6 = 151/6144*navParam.e^6+151/4096*navParam.e^8;
navParam.a8 = 1097/131072*navParam.e^8;

navParam.FQParam(1) = navParam.d2r;%deg2rad
navParam.FQParam(2) = navParam.r2d;%rad2deg
navParam.FQParam(3) = navParam.Re;%长轴
navParam.FQParam(4) = navParam.Rp;%短轴
navParam.FQParam(5) = navParam.RL;%正球体半径
navParam.FQParam(6) = navParam.e;%扁率
navParam.FQParam(7) = navParam.K1;
navParam.FQParam(8) = navParam.K2;
navParam.FQParam(9) = navParam.K3;
navParam.FQParam(10)= navParam.K4;
navParam.FQParam(11)= navParam.K5;
%% 飞机初始位置
% navParam.InitialLLA = [40.4993,115.5711,3200]; % 单位：°，m
% navParam.InitialKai = 95; % 单位°
% navParam.InitialVelocity = 200; % 单位：m/s

% navParam.InitialLLA = [WPT.data.Sheet1(1,1)+0.01,WPT.data.Sheet1(1,2)+0.01,WPT.data.Sheet1(1,3)+1]; % 单位：°，m   飞机初始位置
navParam.InitialKai = WPT.data.Sheet2(1,1); % 单位°    %飞机初始航向
navParam.InitialLLA = [WPT.data.Sheet1(1,1)+0.01,WPT.data.Sheet1(1,2)+0.01,WPT.data.Sheet1(1,3)+1]; % 单位：°，m   飞机初始位置
% navParam.InitialKai = 0; % 单位°    %飞机初始航向
navParam.InitialVelocity =  WPT.data.Sheet2(8,1); % 单位：m/s   %飞机初始速度
%% 合成航线
% 计算IAF位置
APP.pos.IAF = APP.pos.HUR;
[APP.pos.IAF(1),APP.pos.IAF(2)] = dengjiaozhengjie(navParam,APP.pos.HUR(1),APP.pos.HUR(2),APP.kai.HUR_IAF,APP.d.IAF_HUR);
% 计算IF 位置
[APP.pos.IF(1),APP.pos.IF(2)] = dengjiaozhengjie(navParam,APP.pos.PEK(1),APP.pos.PEK(2),APP.kai.PEK_IF,APP.d.IF_PEK);
% 计算FAF 位置
[APP.pos.FAF(1),APP.pos.FAF(2)] = dengjiaozhengjie(navParam,APP.pos.PEK(1),APP.pos.PEK(2),APP.kai.PEK_FAF,APP.d.FAF_PEK);
% 机场位置
APP.pos.Airport = APP.pos.PEK; 
% 合成
tmp  = [APP.pos.IAF,APP.height.IAF;%起始进近点
	APP.pos.IF,APP.height.IF;%中间进近点
	APP.pos.FAF,APP.height.FAF;%最后进近点
	airport.ZBAA.LLA];%机场
WPT.data.Sheet1(end,:) = [];
WPT.data.Sheet1(end,:) = [];
WPT.data.Sheet1 = [WPT.data.Sheet1;tmp];
navData = NavDataCal(navParam,WPT);
%% 绘制导航台
% plot(APP.pos.LR(2),APP.pos.LR(1),'r*');
% plot(APP.pos.HUR(2),APP.pos.HUR(1),'r*');
navstate.tmp=tmp;
navstate.app=APP;
navstate.Flare=Flare;
navstate.TakeOff=TakeOff;
navstate.Climb=Climb;
navstate.Decline=Decline;
%% 子程序
function navData = NavDataCal(navParam,WPT)
navData.number = size(WPT.data.Sheet1,1); %航路段数
navData.waypoint = WPT.data.Sheet1;%航路坐标 纬经高
lat = navData.waypoint(:,1);
lon = navData.waypoint(:,2);
alt = navData.waypoint(:,3);

%% 直线航段(航向角kai 航程S)
kai = zeros(navData.number-1,1);
FlightLineSeg = [];
for k = 1:navData.number-1
    [kai(k,1),S(k,1)] = dengjiaofanjie(navParam,lat(k), lon(k),lat(k+1), lon(k+1));
    tmp = [lat(k),lon(k),alt(k),S(k),kai(k)]; % 第一个航点，航程、航向角
    FlightLineSeg = [FlightLineSeg;tmp];
end
%% 过渡航段构建
%转弯起点 L_i lambda_i H_i
%转弯终点 L_f lambda_f H_f
%转弯圆心 L_0 lambda_0 H_0
 FlightCircleSeg = [];
 FlightCircleP0 = []; % 用来计算圆弧侧偏距Dc
for k = 1:navData.number-2
    if k>=navData.number-4
        navParam.R = navParam.R; 
    end
    [L_i(k,1),lambda_i(k,1),L_f(k,1),lambda_f(k,1),L_0(k,1),lambda_0(k,1),turn(k,1)] = ...
        neiqieguodu(navParam, lat(k+1), lon(k+1), kai(k), kai(k+1)); % 计算圆弧航段
    [CircleKai(k,1),CircleS(k,1)] = dengjiaofanjie(navParam,L_i(k,1),lambda_i(k,1),L_f(k,1),lambda_f(k,1)); % 计算圆弧航段的航向（P1->P2的航向，用来计算圆弧侧偏距Dc）
    H_i(k,1) = alt(k+1);H_f(k,1) = H_i(k);H_0(k,1) = H_i(k);
    SegLat = [L_i(k);L_f(k)];SegLon = [lambda_i(k);lambda_f(k)];SegH = [H_i(k);H_f(k)];
    SegDis = [CircleS(k,1);turn(k,1)];% 航段距离CircleS,转向turn，左转-1，右转1 
    SegKai = [kai(k);kai(k+1)]; % 航段航向角
    tmp = [SegLat,SegLon,SegH,SegDis,SegKai];
    FlightCircleSeg = [FlightCircleSeg;tmp];
    % %%%%%%%%%圆弧初始位置P1，P1->P2航向，圆心位置，高度，转弯方向，转弯半径
    tmp = [L_i(k,1),lambda_i(k,1),CircleKai(k,1),L_0(k,1),lambda_0(k,1),H_i(k,1),turn(k,1),navParam.R];
    FlightCircleP0 = [FlightCircleP0;tmp];
end
navData.FlightCircleSeg = FlightCircleSeg;
navData.FlightLineSeg =FlightLineSeg;
navData.FlightCircleP0 = FlightCircleP0;

% 当前直线航段 InitialIndex
for k = 1:navData.number-1
    tmp1 = FlightLineSeg(k,[1,2,5]); % 航段k的初始航点经纬及航向
    tmp2 = navParam.InitialLLA(1:2); % 飞机初始经纬坐标
    in = [tmp1,tmp2];
    Dis(k) = LatDistance_line(in);
end
[~,navData.InitialIndex] = min(abs(Dis));

% 绘航路图
% figure(1)
% clf
% plot(lon,lat,'k-*');
% hold on
% % 绘制圆弧切点
% plot(FlightCircleSeg(:,2),FlightCircleSeg(:,1),'ro');
% % 绘制圆弧圆心
% plot(FlightCircleP0(:,5),FlightCircleP0(:,4),'bo');
end
function [kai_rh,S_rh] = dengjiaofanjie(navParam, L1,lambda1,L2,lambda2 )
%等角航线的反解
%输入
% L1，lambda1,H1:起始点纬度、经度、高度（deg,deg,m）
% L2，lambda2,H2:终点纬度、经度、高度(deg,deg,m)

%输出
%kai_rh:航向角（deg）
%S_rh:航线长度（nm）

% 参数

L1 = L1*navParam.d2r;
L2 = L2*navParam.d2r;
lambda1 = lambda1*navParam.d2r;
lambda2 = lambda2*navParam.d2r;

%航向角
Lq1 = atanh(sin(L1))-navParam.e*atanh(navParam.e*sin(L1));
Lq2 = atanh(sin(L2))-navParam.e*atanh(navParam.e*sin(L2));
if lambda2>=lambda1
    if L2 == L1 
        kai_rh = pi/2;
    elseif L2 > L1 
        kai_rh = atan((lambda2-lambda1)/(Lq2-Lq1));
    else
        kai_rh = atan((lambda2-lambda1)/(Lq2-Lq1))+pi;
    end
else
    if L2 == L1 
        kai_rh = 3*pi/2;
    elseif L2 > L1 
        kai_rh = atan((lambda2-lambda1)/(Lq2-Lq1))+2*pi;
    else
        kai_rh = atan((lambda2-lambda1)/(Lq2-Lq1))+pi;
    end
end

%航线长度
if kai_rh == pi/2||kai_rh == 3*pi/2
    N1 = navParam.Re/((1-navParam.e^2*(sin(L1)^2))^(1/2));
    S_rh = (N1*cos(L1))*(lambda2-lambda1);
else
    X_L1 = navParam.Re*(1-navParam.e^2)*(navParam.K1*L1+navParam.K2*sin(2*L1)+navParam.K3*sin(4*L1)+navParam.K4*sin(6*L1)+navParam.K5*sin(8*L1));
    X_L2 = navParam.Re*(1-navParam.e^2)*(navParam.K1*L2+navParam.K2*sin(2*L2)+navParam.K3*sin(4*L2)+navParam.K4*sin(6*L2)+navParam.K5*sin(8*L2));
    delta_X = X_L2-X_L1;
    S_rh = delta_X/cos(kai_rh);
end
kai_rh = kai_rh*navParam.r2d;

end

function [L2,lambda2] = dengjiaozhengjie(navParam,L1,lambda1,kai_rh,S_rh)
%等角航线正解
%输入：
% L1，lambda1,H1:起始点纬度、经度、高度（deg,deg,m）
%kai:航向角（deg）
%S：起点和终点之间航线的长度(m)
%输出：
% L2，lambda2,H2:终点纬度和经度、高度（deg,deg,m）

L1 = L1*pi/180;
lambda1 = lambda1*pi/180;
kai_rh = kai_rh*pi/180;

if (kai_rh == pi/2) || (kai_rh == 3*pi/2)
    L2 = L1;
    N1 = navParam.Re/((1-navParam.e^2*(sin(L1)^2))^(1/2));
    lambda2 = S_rh/(N1*cos(L1))+lambda1;
else
    X_L1 = navParam.Re*(1-navParam.e^2)*(navParam.K1*L1+navParam.K2*sin(2*L1)+navParam.K3*sin(4*L1)+navParam.K4*sin(6*L1)+navParam.K5*sin(8*L1));
    delta_X = S_rh*cos(kai_rh);
    X_L2 = X_L1+delta_X;%%%%%%%%%%%%%delta_X
    %P2纬度
    zeta = X_L2/(navParam.Re*(1-navParam.e^2)*(1+3/4*navParam.e^2+45/64*navParam.e^4+175/256*navParam.e^6+11025/16384*navParam.e^8));
    L2 = zeta+navParam.a2*sin(2*zeta)+navParam.a4*sin(4*zeta)+navParam.a6*sin(6*zeta)+navParam.a8*sin(8*zeta);
    %P2经度
    Lq1 = atanh(sin(L1))-navParam.e*atanh(navParam.e*sin(L1));
    Lq2 = atanh(sin(L2))-navParam.e*atanh(navParam.e*sin(L2));
    lambda2 = lambda1+tan(kai_rh)*(Lq2-Lq1);
end
L2 = L2*navParam.r2d;
lambda2 = lambda2*navParam.r2d; 

end

function [L1,lambda1,L2,lambda2,L0,lambda0,Turn] = neiqieguodu(navParam, L3, lambda3, kai_i, kai_f)
%水平方向切线转弯
%航路点采用经纬度表示
%输入：
% L3,lambda3，H3:已知航路点纬度、经度、高度(deg,deg,m)
%kai_i:前一航段的方位角(deg)
%kai_f:下一航段的方位角(deg)
%输出：
% turn:转弯方向
% delta_kai:过度圆弧对应的圆心角(deg)
% L1,lambda1，H1:圆弧转弯起始点P1点纬度、经度和高度(deg,deg,m)
% L2,lambda2,H2:圆弧转弯终止点P2点纬度、经度和高度(deg,deg,m)
% L0,lambda0，H0：圆弧中心P0点纬度、经度和高度(deg,deg,m)

kai_i = mod(kai_i,360)*pi/180;% 转为弧度
kai_f = mod(kai_f,360)*pi/180;% 转为弧度
% 判断飞机的转弯方向
fi = kai_f - kai_i;
if 0<kai_i && kai_i<=pi/2 % 初始航线方位角0~90°
    if 0<fi && fi<pi%与下一时刻航线方位角相差180°以内
        turn = '右转';
    else
        turn = '左转';
    end
elseif pi<kai_i && kai_i<=3*pi/2 %初始航线方位角180~270
    if -pi<fi && fi<0
        turn = '左转';
    else
        turn = '右转';
    end
elseif pi/2<kai_i && kai_i<=pi  %初始航线方位角90~180
    if 0<fi && fi<pi
        turn = '右转';
    else
        turn = '左转';
    end
else                                %
    if -pi<fi && fi<0 
        turn = '左转';
    else
        turn = '右转';
    end
end

if strcmp(turn,'右转')==1
    Turn = 1;
else
    Turn = -1;
end

% 计算过度圆弧对应的圆心角
if abs(kai_f-kai_i)<pi
    delta_kai = abs(kai_f-kai_i);
else
    delta_kai = 2*pi-abs(kai_f-kai_i);
end

% 计算圆弧转弯起始点P1点坐标(L2,lambda1)
if kai_i<pi
    kai_pfixp1 = kai_i+pi;
else
    kai_pfixp1 = kai_i-pi;
end

%等角航线正解
%固定点Pfix到转弯起始点P1的航向角为kai_pfixp1
S31 = navParam.R*tan(delta_kai/2);
kai_pfixp1 = kai_pfixp1*180/pi;
[L1,lambda1] = dengjiaozhengjie(navParam,L3, lambda3, kai_pfixp1, S31);
% 计算圆弧转弯终止点P2点坐标(L2,lambda2)
%等角航线正解
%固定点Pfix到转弯终止点P2的航向角为kai_f
S32 = navParam.R*tan(delta_kai/2);
kai_f = kai_f*180/pi; % 第二段航线的航向角，转化为角度
[L2,lambda2] = dengjiaozhengjie(navParam,L3, lambda3, kai_f, S32);
% 计算圆弧中心P0点坐标
%转弯起始点P1到圆弧的中心P0点坐标的航向角kai_p1p0
if strcmp(turn,'右转')==1
    kai_p1p0 = kai_i + pi/2;
else
    kai_p1p0 = kai_i - pi/2;
end
if kai_p1p0<0
    kai_p1p0 + kai_p1p0 + 2*pi;
elseif kai_p1p0>2*pi
    kai_p1p0 = kai_p1p0 - pi*2;
end
%等角航线正解
S10 = navParam.R;
kai_p1p0 = kai_p1p0*180/pi;
[L0,lambda0] = dengjiaozhengjie(navParam,L1, lambda1, kai_p1p0, S10);
end

function out = LatDistance_line( in )
%偏航距计算
% 输入：in(1)
navParam.RL = 6371393;%正球体半径，m
navParam.d2r = pi/180;
L0 = in(1)*navParam.d2r;  % 航段纬度
lambda0 = in(2)*navParam.d2r;
kai_rh = in(3)*navParam.d2r; % 航段航向角
L = in(4)*navParam.d2r;  % 飞机当前纬度
lambda = in(5)*navParam.d2r;

if kai_rh == pi/2 || kai_rh == 3*pi/2
    out = (L-L0)*navParam.RL;
else
    lambda1 = lambda0 + tan(kai_rh)*log(cos(L0)*(1+sin(L))/(cos(L)*(1+sin(L0))));
    PP1 = -(lambda-lambda1)*navParam.RL*cos(L);
    out =PP1*cos(kai_rh);
end
end





