clear;clc;
features_col = ["smart_187_raw_cv","smart_241_raw_max","smart_241_raw_mean","smart_5_raw_cv","smart_241_raw_last","smart_5_raw_max","smart_241_raw_cv","smart_5_raw_mean","smart_5_raw_last","smart_188_raw_max","smart_241_raw_diff_max","smart_241_raw_diff_mean","smart_187_raw_max","smart_4_raw_max","smart_12_raw_max","smart_5_raw_diff_std","smart_187_raw_diff_std","smart_187_raw_mean","smart_241_raw_slope","smart_197_raw_cv","smart_193_raw_mean","smart_5_raw_diff_max","smart_188_raw_mean","smart_188_raw_cv","smart_187_raw_skew","smart_241_raw_diff_std","smart_5_raw_diff_mean","smart_7_raw_mean","smart_187_raw_last","smart_4_raw_mean","smart_187_raw_slope","smart_188_raw_last","smart_187_raw_diff_max","smart_5_raw_slope","smart_193_raw_max","smart_193_raw_cv","smart_187_raw_diff_mean","smart_7_raw_diff_std","smart_12_raw_mean","smart_197_raw_max","smart_12_raw_last","smart_193_raw_last","smart_4_raw_last","smart_7_raw_max","smart_198_raw_cv","smart_197_raw_mean","smart_198_raw_last","smart_188_raw_diff_std","smart_7_raw_last","smart_187_raw_kurt"];
T = readtable("failure_normal_features.csv");
% data = table2array(T);

Tf = T(:,features_col);
dat = table2array(Tf);
dat = dat(~all(dat==0,2),:);
R = corrcoef(dat);
% figure; heatmap(R);

% 设定阈值
threshold = 0.8;  

% 取出上三角部分（避免重复输出(i,j)和(j,i)），排除对角线
R_tri = triu(R, 1);  

% 找到所有满足 绝对值>阈值 的索引
[row, col] = find(abs(R_tri) > threshold);  

% 输出结果
fprintf('\n======= 高相关特征对 (|r|>%.2f) =======\n', threshold);
for i = 1:length(row)
    r = row(i);
    c = col(i);
    corr_val = R(r, c);
    fprintf('行=%d, 列=%d | 特征: {%s} ↔ {%s} | 相关系数=%.4f\n', ...
        r, c, features_col{r}, features_col{c}, corr_val);
end
fprintf('=======================================\n');

%% 超简单：读取txt → 输出关联特征组
clear; clc;

% 读取你的txt
fid = fopen('txt.txt','r');
data = fread(fid,'*char')';
fclose(fid);

% 自动提取所有特征对 A-B
tokens = regexp(data, '{([^}]+)} ↔ {([^}]+)}', 'tokens');
pairs = cat(1, tokens{:});

% 构建关联图 + 聚类
G = graph(pairs(:,1), pairs(:,2));
bins = conncomp(G);

% 输出结果
fprintf('\n==== 关联特征组（自动合并）====\n');
for i = 1:max(bins)
    list = G.Nodes.Name(bins==i);
    fprintf('%s\n', strjoin(list, ', '));
end

%% 
clear; clc;
%% 1. 读取特征重要性表格 tmp.xlsx
[~, ~, raw] = xlsread('tmp.xlsx');
feat_names = strtrim(raw(:,1));  % 第一列：特征名
feat_scores = cellfun(@double, raw(:,2));  % 第二列：分数

%% 2. 把你的关联特征组粘贴在这里（每行一组）
groups_str = [
    "smart_241_raw_max, smart_241_raw_mean, smart_241_raw_last"
    "smart_5_raw_max, smart_5_raw_mean, smart_5_raw_last"
    "smart_187_raw_max, smart_187_raw_mean, smart_187_raw_last"
    "smart_241_raw_diff_mean, smart_241_raw_slope, smart_241_raw_diff_std"
    "smart_188_raw_max, smart_188_raw_mean, smart_188_raw_last"
    "smart_4_raw_max, smart_4_raw_mean, smart_4_raw_last"
    "smart_5_raw_diff_mean, smart_5_raw_slope"
    "smart_193_raw_mean, smart_193_raw_max, smart_193_raw_last"
    "smart_241_raw_cv, smart_193_raw_cv"
    "smart_187_slope, smart_187_diff_mean"
    "smart_12_raw_max, smart_12_raw_mean, smart_12_raw_last"
    "smart_7_raw_mean, smart_7_raw_max, smart_7_raw_last"
    "smart_197_raw_cv, smart_198_raw_cv"
    "smart_197_raw_max, smart_197_raw_mean, smart_198_raw_last"
];


%% 3. 自动遍历每组 → 选出最高分特征（核心代码）
fprintf('\n==== 每组保留的最重要特征 ====\n');
for i = 1:length(groups_str)
    % 拆分当前组的特征
    group = split(groups_str(i), ', ');
    group = strtrim(group);
    
    % 查找每个特征的分数
    scores = zeros(size(group));
    for j = 1:length(group)
        idx = strcmp(feat_names, group(j));
        if any(idx)
            scores(j) = feat_scores(idx);
        else
            scores(j) = -inf;  % 表格里没有的分数设为最低
        end
    end
    
    % 找分数最高的
    [~, best_idx] = max(scores);
    best_feat = group(best_idx);
    
    % 输出结果
    fprintf('%s\n', best_feat);
end



%% 3. 输出【每组需要删除的特征】
fprintf('\n===== 需要删除的特征 =====\n');
for i = 1:length(groups_str)
    % 拆分每组特征
    group = split(groups_str(i), ', ');
    group = strtrim(group);
    
    % 获取本组分数
    scores = zeros(size(group));
    for j = 1:length(group)
        idx = strcmp(feat_names, group(j));
        if any(idx)
            scores(j) = feat_scores(idx);
        else
            scores(j) = -inf;
        end
    end
    
    % 找出最高分，剩下的就是要删除的
    [~, best_idx] = max(scores);
    to_remove = group(setdiff(1:length(group), best_idx));
    
    % 输出结果
    fprintf('%s\n', strjoin(to_remove, ', '));
end

%% 剔除特征
features_col = ["smart_187_raw_cv","smart_241_raw_max","smart_241_raw_mean","smart_5_raw_cv","smart_241_raw_last","smart_5_raw_max","smart_241_raw_cv","smart_5_raw_mean","smart_5_raw_last","smart_188_raw_max","smart_241_raw_diff_max","smart_241_raw_diff_mean","smart_187_raw_max","smart_4_raw_max","smart_12_raw_max","smart_5_raw_diff_std","smart_187_raw_diff_std","smart_187_raw_mean","smart_241_raw_slope","smart_197_raw_cv","smart_193_raw_mean","smart_5_raw_diff_max","smart_188_raw_mean","smart_188_raw_cv","smart_187_raw_skew","smart_241_raw_diff_std","smart_5_raw_diff_mean","smart_7_raw_mean","smart_187_raw_last","smart_4_raw_mean","smart_187_raw_slope","smart_188_raw_last","smart_187_raw_diff_max","smart_5_raw_slope","smart_193_raw_max","smart_193_raw_cv","smart_187_raw_diff_mean","smart_7_raw_diff_std","smart_12_raw_mean","smart_197_raw_max","smart_12_raw_last","smart_193_raw_last","smart_4_raw_last","smart_7_raw_max","smart_198_raw_cv","smart_197_raw_mean","smart_198_raw_last","smart_188_raw_diff_std","smart_7_raw_last","smart_187_raw_kurt"];
%% ===================== 特征剔除核心代码 =====================
% 1. 把你要剔除的特征粘贴在这里（每行一个/一行多个都支持）
remove_feats = [
    "smart_241_raw_mean", "smart_241_raw_last", ...
    "smart_5_raw_mean", "smart_5_raw_last", ...
    "smart_187_raw_mean", "smart_187_raw_last", ...
    "smart_241_raw_slope", "smart_241_raw_diff_std", ...
    "smart_188_raw_mean", "smart_188_raw_last", ...
    "smart_4_raw_mean", "smart_4_raw_last", ...
    "smart_5_raw_slope", ...
    "smart_193_raw_max", "smart_193_raw_last", ...
    "smart_193_raw_cv", ...
    "smart_187_diff_mean", ...
    "smart_12_raw_mean", "smart_12_raw_last", ...
    "smart_7_raw_max", "smart_7_raw_last", ...
    "smart_198_raw_cv", ...
    "smart_197_raw_mean", "smart_198_raw_last"
];

% 2. 核心：去重 + 剔除（自动保留不重复的有效特征）
remove_feats = unique(remove_feats);               % 去重防止重复剔除
keep_mask = ~ismember(features_col, remove_feats); % 标记保留的特征
features_keep = features_col(keep_mask);           % 最终保留的特征

% 3. 输出结果
fprintf('\n===== 最终保留的特征 =====\n');
disp(features_keep);

% 4. 可选：输出保留特征数量（方便核对）
fprintf('\n原始特征数：%d\n', length(features_col));
fprintf('剔除特征数：%d\n', length(remove_feats));
fprintf('保留特征数：%d\n', length(features_keep));

%% 直接输出保留特征（带单引号格式）
fprintf('\n===== 保留的特征（可直接复制）=====\n');
str = strjoin(cellstr(features_keep) + """, """);
str = strrep(str, """", "'");  % 替换成双引号为单引号
fprintf('%s\n', str);
