function plotTrack1(LLA)
%% Produce XY Plot of the mission
% Waypoints
nav = evalin('base', 'navData');

FlightCircleSeg = nav.FlightCircleSeg;
lat = nav.waypoint(:,1);
lon = nav.waypoint(:,2);

% Estimated Position
x = LLA(1);
y = LLA(2);
t = LLA(4);
persistent handle_ax handle_fig

try
    % 如果 t 为 0，创建新的图形窗口并初始化
    if t == 0
        % 检查 handle_fig 是否为空或者图像是否已被关闭
        if isempty(handle_fig) || ~isvalid(handle_fig)
            handle_fig = figure(2);
        else
            figure(handle_fig);
        end
        clf;
        plot(lon, lat, 'k-*');
        handle_ax = gca;
        hold on;
        plot(FlightCircleSeg(:,2), FlightCircleSeg(:,1), 'ro');
        title('飞机航迹');
    end
    
    % 更新当前航迹位置
    plot(handle_ax, y, x, 'r.', 'LineWidth', 2);
    drawnow; % 强制刷新图形
    
catch ME
    % 捕获异常，避免 Simulink 中断运行
    disp(['绘图时出错: ', ME.message]);
end
