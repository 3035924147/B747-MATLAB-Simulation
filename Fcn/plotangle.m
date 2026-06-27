% close all;

xlsx=importdata('飞行轨迹02-成都双流机场-北京大兴机场.xlsx');
figure(1);%航线二维
plot(xlsx.data(:,5),xlsx.data(:,6));
grid on
hold on
plot(118.126,24.545,'r*');

figure(2);%航线三维
plot3(xlsx.data(:,5),xlsx.data(:,6),xlsx.data(:,2))
grid on;
%%
% [d,r]=xy_inv(118.126,24.545,118.013,24.587);
% xy_inv(116.46,39.5117,116.76,39.4722);

xy_inv(116.14,39.0434,116.404,39.1409); %起始进近点到导航台
xy_inv(116.434,39.1949,116.396,39.4608);%
xy_inv(116.429,39.2559,116.396,39.4608);