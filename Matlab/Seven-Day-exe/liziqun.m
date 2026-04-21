clc; clear; close all;
% 设置全局字体为 Times New Roman
% 设置全局字体为 Times New Roman 并加粗
set(groot, 'DefaultAxesFontName','Times New Roman', ...
           'DefaultTextFontName','Times New Roman', ...
           'DefaultAxesFontWeight','bold', ...
           'DefaultTextFontWeight','bold');
%% 参数设置
nd_list = [4,6,8,10,12];
grid_list = [6,8,10,12,14];

% 四组最优值信息
opt_info = {
    2, 6, 10, 0.89;
    3, 4, 12, 0.94;
    4, 8,  8, 0.96;
    4, 10, 8, 0.91
};

num_particles = 6;
num_iter = 10;

[X,Y] = meshgrid(nd_list, grid_list);

figure('Position',[100 100 1200 900]);

for k = 1:4
    subplot(2,2,k)
    so = opt_info{k,1};
    nd_opt = opt_info{k,2};
    grid_opt = opt_info{k,3};
    F1_opt = opt_info{k,4};
    
    % 构造 F1 平滑函数用于热力图
    Z = 0.7 + 0.3*exp(-((X-nd_opt).^2/2)-((Y-grid_opt).^2/2));
    
    % 绘制热力图
    imagesc(nd_list, grid_list, Z)
    set(gca,'YDir','normal')
    colormap(summer)  % 黄绿色渐变，可改为 autumn/red/hot
    colorbar
    caxis([0.7 1])  % 固定颜色范围
    
    xlabel('n\_d','FontSize',12)
    ylabel('grid\_size','FontSize',12)
    title(['spline\_order = ', num2str(so)],'FontSize',12,'FontWeight','bold')
    hold on
    
    % 初始化粒子位置
    particle_nd = randsample(nd_list,num_particles,true);
    particle_grid = randsample(grid_list,num_particles,true);
    
    % 粒子收敛轨迹
    for t = 1:num_iter
        particle_nd = particle_nd + 0.2*(nd_opt - particle_nd);
        particle_grid = particle_grid + 0.2*(grid_opt - particle_grid);
        
        scatter(particle_nd, particle_grid, 60, 'w', 'filled')
    end
    
    % 高亮全局最优点
    scatter(nd_opt, grid_opt, 120, 'r', 'filled', 'p') % 红星标记
    
    % 标注 n_d, grid_size, F1
    text(nd_opt+0.3, grid_opt+0.3, ...
        sprintf('n_d=%d\ngrid=%d\nF1=%.2f', nd_opt, grid_opt, F1_opt), ...
        'Color','r','FontWeight','bold','FontSize',10)
    
end