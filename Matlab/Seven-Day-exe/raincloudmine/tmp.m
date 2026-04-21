clear; % 清除工作区变量
clc;   % 清除命令行窗口
close all; % 关闭所有图形窗口
% --- 1.参数设置 ---
features_cols = ["smart_4_raw_max","smart_188_raw_cv","smart_187_raw_skew","smart_7_raw_diff_std","smart_241_raw_diff_max","smart_187_raw_slope","smart_197_raw_cv","smart_5_raw_diff_mean","smart_193_raw_mean","smart_12_raw_max"];
T_raw = readtable("failure_normal_features.csv");
T = T_raw(:,features_cols);
data_raw = table2array(T);
data = data_raw(randsample(find(T_raw.failure==0),50,false), :);
% 输出不全是0的特征

% 找出不全为0的列
non_zero_cols = any(data ~= 0, 1);  
selected_features = features_cols(non_zero_cols);

% 按你要的格式输出："特征1","特征2","特征3"
fprintf('"')
fprintf('%s","', selected_features(1:end-1));
fprintf('%s"', selected_features(end));