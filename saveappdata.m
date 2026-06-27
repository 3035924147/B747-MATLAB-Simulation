function   y=saveappdata(u)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
data=u;
% appdata=u(2,end);
alpha=data(4,end);
beta=data(28,end);
phi=data(5,end);
theta=data(6,end);
psi=data(7,end);
long=data(11,end);
lat=data(12,end);
h=data(13,end);

% save Appdata alpha beta phi theta psi long lat h
y=[alpha;beta];
end

