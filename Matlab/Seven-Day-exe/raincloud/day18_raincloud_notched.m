clear; % 清除工作区变量
clc;   % 清除命令行窗口
% close all; % 关闭所有图形窗口
% --- 1.参数设置 ---
input_filename = 'my_data_5_groups.xlsx';
output_filename = 'Rain_cloud_notched.tif'; % 更新输出文件名
disp(['正在从文件读取数据: ' input_filename]);
T = readtable(input_filename);
data = table2array(T);
group_names = T.Properties.VariableNames;
[num_samples, num_groups] = size(data); 
% --- 2.绘图与格式化 ---
figure('Color', 'white', 'Position', [100, 100, 700, 480]);
%  定义包含5种颜色的配色方案
colors = [
    0.21, 0.49, 0.72;  % 蓝色
    0.89, 0.10, 0.11;  % 红色
    0.30, 0.69, 0.29;  % 绿色
    0.58, 0.40, 0.74;  % 紫色 
    1.00, 0.50, 0.05   % 橙色 
];
plot_positions = 1:num_groups; 
scatter_offset = -0.3;  % 散点在箱线图下方的偏移量
boxplot_width = 0.3;  % 箱线图的宽度
violin_width = 0.4;   % 云（半小提琴）的最大高度
jitter_width = 0.25;   % 散点抖动的宽度
hold on; 
% 云的参数
cloud_alpha = 0.5;    % 云的透明度
lightness_factor = 0.3; % 颜色变浅的因子

for i = 1:num_groups
    % 提取当前组的数据
    y_data = data(:, i);
    % 计算核密度估计
    [f, yi] = ksdensity(y_data, 'NumPoints', 100);
    % 缩放密度值以控制小提琴的宽度 (现在是高度)
    f_scaled = f / max(f) * violin_width;
    % 创建 *一半* 小提琴的 x, y 坐标
    x_coords = [yi, fliplr(yi)];
    y_coords = [repmat(i, 1, length(yi)), i + fliplr(f_scaled)]; 
    % 计算"略浅"的颜色
    current_color = colors(i, :);
    light_color = current_color + (1 - current_color) * lightness_factor;
    % 绘制云 (patch)
    patch(x_coords, y_coords, light_color, ...
        'EdgeColor', 'none', ...         % 不描边
        'FaceAlpha', cloud_alpha);
end

% 绘制箱型图 (水平方向)
h_boxplot = boxplot(data, 'Labels', group_names, 'Notch', 'on', ...
    'Symbol', '', 'Widths', boxplot_width, ...
    'Positions', plot_positions, ...
    'Orientation', 'horizontal'); % 保持水平方向
% --- 3.图形细节精细化调整 ---
ax = gca;
set(h_boxplot, 'LineWidth', 0.1);
% 自定义箱体颜色
h_boxes = findobj(ax, 'Tag', 'Box');
for j = 1:length(h_boxes)
    patch(get(h_boxes(j), 'XData'), get(h_boxes(j), 'YData'), colors(length(h_boxes)-j+1,:), 'FaceAlpha', 0.4);
end
% 叠加绘制离散点 (在偏移位置)
% 散点图参数
dot_size = 25;       
dot_alpha = 0.7;     
dot_edge_color = [0.2 0.2 0.2];
% 循环为每一组数据添加散点
for i = 1:num_groups
    y_data = data(:, i); % 这是 X 轴的数据
    % y_center 现在是 i - 0.3 (向下偏移)
    y_center = plot_positions(i) + scatter_offset; 
    y_data_jittered = y_center + (rand(num_samples, 1) - 0.5) * jitter_width;
    x_data = y_data; 
    current_color = colors(i, :);
    scatter(x_data, y_data_jittered, dot_size, 'filled', ... % X 和 Y 交换
        'MarkerFaceColor', current_color, ...
        'MarkerFaceAlpha', dot_alpha, ...
        'MarkerEdgeColor', dot_edge_color, ...
        'LineWidth', 0.1);
end
hold off;

% --- 4. 整体外观最终调整 ---
ax.FontName = 'Times New Roman';
ax.FontSize = 12;
ax.FontWeight = 'bold'; 
ax.LineWidth = 1.2;     
box off; grid off
% --- 5. 设置标题和轴标签 ---
title('Rain cloud notched', 'FontName', 'Times New Roman', ...
    'FontSize', 16, 'FontWeight', 'bold');
xlabel('Measured Value', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Experimental Group', 'FontName', 'Times New Roman', 'FontSize', 14, 'FontWeight', 'bold');
% --- 6.保存图像 ---
print(gcf, output_filename, '-dtiff', '-r300');
% --- 7.完成提示 ---
disp(['图像已成功保存为: ' output_filename ' (300 DPI)']);