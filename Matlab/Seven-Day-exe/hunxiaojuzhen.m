% 清空工作区和命令行
clear; clc; close all;

confMatList = {
    [96, 30; 35, 91],     % RF
    [104, 22; 28, 98],    % LightGBM
    [108, 18; 26, 100],   % TabNet
    [99, 27; 21, 105],   % TabNet-KAN
};

% % 存储对应标题
% titleList = {
%     'AFDB → CPSC2018',
%     'AFDB → PTB-XL',
%     'CPSC2018 → AFDB',
%     'CPSC2018 → PTB-XL'
% };

% 类别标签（所有子图共用）
labels = {'Normal', 'Pre-Failure'};

% ====================== 2. 定义统一的蓝白色板（所有子图共用） ======================
numColors = 256; % 色阶数量
r = linspace(1, 0, numColors);   % 红色通道：1(白)→0(蓝)
g = linspace(1, 0, numColors);   % 绿色通道：1(白)→0(蓝)
b = linspace(1, 0.4, numColors); % 蓝色通道：1(白)→0.4(深蓝)
cmap = [r', g', b']; % 拼接为256x3的色板

% ====================== 3. 绘制2行3列的6个子图 ======================

for idx = 1:4
    % 选择对应的subplot位置（231~236）
    subplot(2, 2, idx);
    
    % 获取当前组的混淆矩阵和标题
    confMat = confMatList{idx};
    % titleStr = titleList{idx};
    
    % 绘制热力图
    imagesc(confMat);
    colormap(cmap); % 应用统一的蓝白色板
    colorbar; % 显示颜色条
    colorbar('FontSize', 10); % 调整颜色条字体大小
    
    % 添加数值标注
    maxVal = max(confMat(:));
    for i = 1:size(confMat, 1)
        for j = 1:size(confMat, 2)
            % 自适应文字颜色
            if confMat(i,j) > maxVal/2
                textColor = 'white';
            else
                textColor = 'black';
            end
            % 标注数值
            text(j, i, num2str(confMat(i,j)), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'FontSize', 14, 'Color', textColor);
        end
    end
    
    % 设置坐标轴和标签
    set(gca, 'XTick', 1:length(labels), 'XTickLabel', labels, 'FontSize', 14);
    set(gca, 'YTick', 1:length(labels), 'YTickLabel', labels, 'FontSize', 14);
    xlabel('Predicted Label', 'FontSize', 14);
    ylabel('True Label', 'FontSize', 14);
    % title(titleStr, 'FontSize', 14);
    
    % 优化显示效果
    set(gca, 'TickLength', [0 0]); % 隐藏刻度线
    axis square; % 正方形显示
end

% 调整子图间距，避免重叠
set(gcf, 'Color', 'white'); % 设置图窗背景为白色