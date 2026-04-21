%% 雷达图
figure;
X = [
93.6	92.4	94.1	94.8	93.2;
97.2	94.6	96.8	95.5	95.7;
96.1	95.2	95.6	97.9	95.4;
96.8	98.1	94.2	95.0	96.1;]

RC=radarChart(X);
RC.PropName={'Acc','Rec','Pre','Spe','F1'};
RC.ClassName={'RF','LightGBM','TabNet','TabNet-KAN'};
min(min(X))
max(max(X))
RC.RLim=[92,99];
RC.RTick=[92:99];

RC=RC.draw();
RC.legend();
