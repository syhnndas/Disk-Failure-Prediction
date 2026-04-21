clear; clc;

% Acc	Rec	Pre	Spe	F1
RF = [74.2	72.2	75	76.2	73.6];
LightGBM = [80.2	77.8	81.7	82.5	80.3];
TabNet = [82.5	79.4	81.5	85.7	80.4];
TabNetKAN = [81	83.3	79.1	78.6	81.2];

data = [RF; LightGBM; TabNet; TabNetKAN];

figure('Color','w');
b = bar(data, 'grouped');

% ===== 坐标轴 =====
xticklabels({'RF','LightGBM','TabNet','TabNet-KAN'});
ylabel('Value (%)','FontName','Times New Roman','FontWeight','bold');
ylim([68, 86]);

% ===== 图例 =====
lgd = legend({'Acc','Rec','Pre','Spe','F1'}, 'Location','northwest');
set(lgd, 'FontName','Times New Roman','FontWeight','bold');

% ===== 美化 =====
box off;
grid on;

set(gca, ...
    'FontSize', 12, ...
    'FontName','Times New Roman', ...
    'FontWeight','bold');

% ===== 数值标注 =====
[num_groups, num_bars] = size(data);

for i = 1:num_bars
    x = b(i).XEndPoints;
    y = b(i).YEndPoints;
    
    text(x, y + 0.3, string(round(y,1)), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', ...
        'FontSize', 11, ...
        'FontName','Times New Roman', ...
        'FontWeight','bold');
end