% if exist('flywpt')
%     Cdir = pwd;
%     Model = 'simModel2020.slx';
%     addpath([Cdir '\Fcn']);
%     NavParameters;%导航参数、飞行参数设置
%     Parameters; %飞机参数、气动参数、初始条件等
%     open('simModel2020.slx');
% else
    clear
    clc
    Cdir = pwd;
    Model = 'simModel2020.slx';
    addpath([Cdir '\Fcn']);
    NavParameters;%导航参数、飞行参数设置
    Parameters; %飞机参数、气动参数、初始条件等
    open('simModel2020.slx');
% end