import os
import pandas as pd
import glob
from tqdm import tqdm 
# 设置路径
data_folder = "./2020DataRaw"
output_file = "output.csv"

# 获取所有 CSV 文件路径
csv_files = glob.glob(os.path.join(data_folder, "*.csv"))

# 存储所有 failure=1 的数据
failure_dfs = []

# pd.read_csv("./2020DataRaw/2020-01-01.csv")

# 遍历每个 CSV 文件
for file in tqdm(csv_files):
    df = pd.read_csv(file)
    # 确保 'failure' 列存在
    if 'failure' not in df.columns:
        print(f"警告: 文件 {file} 中没有 'failure' 列，已跳过。")
        continue
    # 筛选 failure == 1 的行（注意：可能为字符串或整数）
    df_failure = df[df['failure'] == 1]
    if not df_failure.empty:
        failure_dfs.append(df_failure)

# 合并所有筛选后的 DataFrame
if failure_dfs:
    combined_df = pd.concat(failure_dfs, ignore_index=True)
    combined_df.to_csv(output_file, index=False)
    print(f"已成功将所有 failure=1 的行保存到 {output_file}，共 {len(combined_df)} 行。")
else:
    print("没有找到任何 failure=1 的数据。")