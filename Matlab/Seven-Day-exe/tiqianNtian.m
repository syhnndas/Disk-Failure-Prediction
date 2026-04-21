clc; clear; close all;

%% 数据
T = [1, 3, 7, 15];

Acc = [96.8, 90.5, 91.2, 83.7];
Rec = [98.1, 92.3, 89.8, 81.5];
Pre = [94.2, 88.7, 91.5, 85.2];
Spe = [95.0, 89.1, 92.6, 86.0];
F1  = [96.1, 90.5, 90.6, 83.3];

%% 全局字体（论文推荐）
set(0, 'DefaultAxesFontName', 'Times New Roman');
set(0, 'DefaultTextFontName', 'Times New Roman');

%% 绘图
figure;
hold on; grid on; box on;

% 五条曲线（带marker更清晰）
plot(T, Acc, '-o', 'LineWidth', 2, 'MarkerSize', 7);
plot(T, Rec, '-s', 'LineWidth', 2, 'MarkerSize', 7);
plot(T, Pre, '-d', 'LineWidth', 2, 'MarkerSize', 7);
plot(T, Spe, '-^', 'LineWidth', 2, 'MarkerSize', 7);
plot(T, F1,  '-p', 'LineWidth', 2, 'MarkerSize', 7);

%% 坐标轴
xlabel('Window T', 'FontSize', 15, 'FontWeight', 'bold');
ylabel('Value (%)', 'FontSize', 15, 'FontWeight', 'bold');

xticks(T);
xticklabels({'T=1','T=3','T=7','T=15'});

ylim([80 100]);   % 控制显示范围，更像论文图

%% 图例
legend({'Acc','Rec','Pre','Spe','F1'}, 'FontSize', 15);

%% 美化
set(gca, 'LineWidth', 1.2);
set(gca, 'FontSize', 15);

%% ===== 插入表格 =====
% 表格数据
table_data = [Acc', Rec', Pre', Spe', F1'];
table_str = arrayfun(@(x) sprintf('%.1f', x), table_data, 'UniformOutput', false);

% 行列标签
row_name = {'T=1','T=3','T=7','T=15'};
col_name = {'Acc','Rec','Pre','Spe','F1'};

% 创建uitable（嵌入图中）
uitable('Data', table_str, ...
        'ColumnName', col_name, ...
        'RowName', row_name, ...
        'Units', 'normalized', ...
        'Position', [0.62 0.15 0.35 0.35], ... % 位置可调
        'FontName', 'Times New Roman', ...
        'FontSize', 11);

