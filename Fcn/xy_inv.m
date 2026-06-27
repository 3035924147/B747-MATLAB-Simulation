function [dist_km,azimuth] = xy_inv(x1,y1,x2,y2)%反算函数，注意该过程三角函数算出来的是弧度
% distance = sqrt((x2-x1).^2+(y2-y1).^2);%算出两点间的距离
% Define the coordinates in degrees
lat1 = y1; lon1 = x1; % Los Angeles
lat2 = y2; lon2 = x2; 
% Calculate the distance
dist = distance('rh',lat1, lon1, lat2, lon2);%gc为大圆航线，rh为等角航线
% Convert the distance from degrees to kilometers
% Earth's mean radius = 3958.8 海里
dist_km = dist * (pi/180) * 3958.8;
%%
r2d=180/pi;
if (x2-x1)>0 && (y2-y1)>0 %象限角在第一象限时
    azimuth = pi/2-atan2(abs(y2-y1),abs(x2-x1));%方位角等于90-象限角
    azimuth=azimuth*r2d;
elseif (x2-x1)>0 && (y2-y1)<0%象限角在第四象限时
    azimuth = pi/2+atan2(abs(y2-y1),abs(x2-x1));%方位角等于“90+象限角”
    azimuth=azimuth*r2d;
elseif (x2-x1)<0 && (y2-y1)>0%象限角在第二象限时
    azimuth = 1.5*pi+atan2(abs(y2-y1),abs(x2-x1));%方位角等于“270+象限角”
    azimuth=azimuth*r2d;
elseif (x2-x1)<0 && (y2-y1)<0%象限角在第三象限时
    azimuth =1.5*pi- atan2(abs(y2-y1),abs(x2-x1));%方位角等于“270-象限角”
    azimuth=azimuth*r2d;
elseif (x2-x1) == 0 && (y2-y1)>0%y轴正方向
    azimuth=0;
    azimuth=azimuth*r2d;
elseif (x2-x1) == 0 && (y2-y1)<0%y轴负方向
    azimuth=pi;
    azimuth=azimuth*r2d;
elseif (x2-x1) > 0 && (y2-y1)==0%x轴正方向
    azimuth=pi/2;
    azimuth=azimuth*r2d;
elseif (x2-x1) < 0 && (y2-y1)==0%x轴负方向
    azimuth=1.5*pi;
    azimuth=azimuth*r2d;
else                            %其他情况
    azimuth=0;
end
disp(['两点距离', num2str(dist_km), ' 海里']);
disp(['两点角度', num2str(azimuth), ' deg']);
end