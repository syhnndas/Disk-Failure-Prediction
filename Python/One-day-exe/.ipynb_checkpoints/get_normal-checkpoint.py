import os
import pandas as pd
import glob
from tqdm import tqdm 
# 设置路径
data_folder = "./RawData"
output_file = "normal.csv"
sample_size = 5  # 每个文件最多随机取5条 failure=0 的记录

# 获取所有 CSV 文件
csv_files = glob.glob(os.path.join(data_folder, "*.csv"))

sampled_dfs = []

for file in tqdm(csv_files):
    try:
        df = pd.read_csv(file)
        
        if 'failure' not in df.columns:
            print(f"警告: 文件 {file} 缺少 'failure' 列，已跳过。")
            continue
        
        # 筛选 failure == 0 的行（兼容字符串和数字）
        # 使用 pd.to_numeric 安全转换
        df_clean = df.copy()
        df_clean['failure'] = pd.to_numeric(df_clean['failure'], errors='coerce')
        non_failure_df = df_clean[df_clean['failure'] == 0]
        
        if non_failure_df.empty:
            print(f"文件 {file} 中没有 failure=0 的数据。")
            continue
        
        # 随机采样：如果不足 sample_size，则取全部
        n_to_sample = min(len(non_failure_df), sample_size)
        sampled = non_failure_df.sample(n=n_to_sample, random_state=None)  # 可设 random_state 固定结果
        sampled_dfs.append(sampled)
        
    except Exception as e:
        print(f"处理文件 {file} 时出错: {e}")

# 合并并保存
if sampled_dfs:
    final_df = pd.concat(sampled_dfs, ignore_index=True)
    final_df.to_csv(output_file, index=False)
    print(f"✅ 已保存 {len(final_df)} 行到 {output_file}（来自 {len(sampled_dfs)} 个文件）")
else:
    print("⚠️ 没有找到任何 failure=0 的数据。")