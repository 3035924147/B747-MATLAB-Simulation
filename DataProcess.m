%% 数据处理
date=datestr(now,'yy_mm_dd');
date=(['FlyData',date]);
% [SimOut_t,~] = unique(SimOut_t,'stable');%提取时间
%% 数据写入表格[date,'.xlsx']
writematrix(zeros(1),[date,'.xlsx'],'WriteMode','overwrite');
XX={'Time',	'Static_Pressure',	'Total_Pressure',	'Total_Temperature','Angle_of_Attack','Roll_Angle','Pitch_Angle','Yaw_Angle',...
    'Acceleration_on_X-axis','Acceleration_on_Y-axis','Acceleration_on_Z-axis','Long','Lat','Altitude',...
    'North_Speed','East_Speed','Down_Speed','Elevator_Deflection','	Aileron_Deflection','Rudder_Deflection',...
    'Throttle_Lever_Position','Flap_Deflection','Roll_Rate_body_frame',	'Pitch_Rate_body_frame','Yaw_Rate_body_frame',...
    'Air_speed_x_axis_body_frame',	'Air_speed_y_axis_body_frame',	'Air_speed_z_axis_body_frame', ...
    'sideslip','IAS','N1','Mach','Wind_x','Wind_y','Wind_z','Wind_sum','airspeed'};
writecell(XX,'FlyData.xlsx','Range','A1');
writematrix(SimOut,'FlyData.xlsx','WriteMode','append');
%% 部分飞行轨迹
% figure
% % plot3(SimOut(1:3000,12),SimOut(1:3000,13),SimOut(1:3000,14));
% plot3(SimOut(4000:18000),SimOut(4000:18000,13),SimOut(4000:18000,14));
% grid on
%% 数据提取
Data=[];
time=SimOut(:,1);
len=size(time);
Data.time=time;
Data.static=SimOut(:,2);%静压
Data.pressure=SimOut(:,3);%总压
Data.q=SimOut(:,3)-SimOut(:,2);%动压
Data.OAT=SimOut(:,4);%总温
Data.alpha=SimOut(:,5);%攻角
Data.Euler=SimOut(:,6:8);%欧拉角,滚转、俯仰、偏航
Data.Ab=SimOut(:,9:11);%加速度，ax,ay,az
Data.LLA=SimOut(:,12:14);%LLA
Data.Ve=SimOut(:,15:17);%Ve
% Data.Xe=out.Xe.signals.values;%Xe
% Data.airspeed=out.airspeed.signals.values;%空速
% Data.ctrlSurfacePos=out.ctrlSurfacePos.signals.values;%控制面
Data.dE=SimOut(:,18);%升降舵
Data.dA=SimOut(:,19);%副翼
Data.dR=SimOut(:,20);%方向舵
Data.dT=SimOut(:,21);%油门
Data.dF=SimOut(:,22);%襟翼
Data.pqr=SimOut(:,23:25);%pqr
Data.Vb=SimOut(:,26:28);%uvw
Data.beta=SimOut(:,29);%侧滑角
Data.ias=SimOut(:,30);%指示空速
Data.Ma=SimOut(:,32);%马赫数
%% 数据保存
save([date,'.mat'],'Data','Data');
currentFolder = pwd; % 获取当前路径
msgbox(sprintf('%s %s %s %s', '文件',date,'已保存到',currentFolder ),'提示'); % 在两个字符串之间添加了一个空格


