%% 1. 读取本地Excel表格（核心修改：直接读取xlsx文件）
clear; clc;
excel_path = '四种方法特征筛选.xlsx'; 
raw_data = readtable(excel_path, 'VariableNamingRule', 'preserve');
features = raw_data.Features; % 特征名列
numeric_data = raw_data{:, 2:5}; % MRMR、Chi2、ANOVA、KW值列（第2-5列）
col_names = raw_data.Properties.VariableNames(2:5); % 指标名称（MRMR、Chi2、ANOVA、KW）

%% 2. Z-score
numeric_data_T = numeric_data'; 
[normalized_data_T, ps] = mapminmax(numeric_data_T, 0, 1); 
normalized_data = normalized_data_T' / 4; 

%% 3. 计算归一化/4后的求和
avg_score = sum(normalized_data, 2);

%% 4. 按平均值降序排序
norm_table = array2table(normalized_data, 'VariableNames', col_names);
sorted_data = table(features, norm_table.MRMR, norm_table.Chi2, norm_table.ANOVA, norm_table.KW, avg_score, ...
    'VariableNames', [{'Features'}, col_names, {'Avg_Score'}]);
sorted_data = sortrows(sorted_data, 'Avg_Score', 'descend');
% 验证输出（可选）
disp('排序后的数据前5行：');
disp(head(sorted_data, 5));

%% 5. 绘制堆叠柱状图
sorted_features = sorted_data.Features;
sorted_normalized = sorted_data{:, 2:5};
% sorted_normalized已存为mat
% sorted_normalized = sorted_normalized{:, 2:5};
figure();
b = bar(sorted_normalized, 'stacked'); 

% 坐标轴设置（核心修复：关闭TeX解释器）
ax = gca;
ax.XTick = 1:length(sorted_features);
ax.XTickLabel = sorted_features;
ax.XTickLabelRotation = 45;
ax.FontSize = 16;
ax.TickLabelInterpreter = 'none'; % 禁止解析下划线为下标
% xlabel也关闭TeX解释器，避免后续异常
xlabel('Features', 'FontSize', 14, 'Interpreter', 'none');
ylabel('Normalized Importance Score', 'FontSize', 14);

% 图例和网格
legend(col_names,'FontSize', 12);
grid on;
grid minor;
set(gca, 'GridAlpha', 0.3);
box off;
