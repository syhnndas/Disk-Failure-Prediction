import os
import pandas as pd
import glob
from tqdm import tqdm
from multiprocessing import Pool, cpu_count
import warnings
warnings.filterwarnings('ignore')  # 忽略pandas的一些警告

# 设置路径
data_folder = "./RawData"
output_file = "output.csv"

def process_single_file(file_path):
    """
    处理单个CSV文件，返回failure=1的行组成的DataFrame
    """
    try:
        # 读取CSV文件，使用更快的读取方式
        df = pd.read_csv(file_path, low_memory=False)
        
        # 确保 'failure' 列存在
        if 'failure' not in df.columns:
            print(f"警告: 文件 {file_path} 中没有 'failure' 列，已跳过。")
            return pd.DataFrame()
        
        # 筛选 failure == 1 的行（兼容整数和字符串类型）
        # 先统一转换为数值类型，避免类型不匹配问题
        df['failure'] = pd.to_numeric(df['failure'], errors='coerce')
        df_failure = df[df['failure'] == 1].copy()
        
        return df_failure
    
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {str(e)}")
        return pd.DataFrame()

if __name__ == "__main__":
    # 获取所有 CSV 文件路径
    csv_files = glob.glob(os.path.join(data_folder, "*.csv"))
    
    if not csv_files:
        print("未找到任何CSV文件！")
        exit()
    
    # 获取CPU核心数，设置进程数（通常为CPU核心数或核心数-1）
    num_processes = cpu_count() - 5
    print(f"使用 {num_processes} 个进程并行处理 {len(csv_files)} 个CSV文件...")
    
    # 创建进程池并处理所有文件
    failure_dfs = []
    with Pool(processes=num_processes) as pool:
        # 使用tqdm显示进度条
        results = list(tqdm(pool.imap(process_single_file, csv_files), 
                           total=len(csv_files), 
                           desc="处理文件进度"))
    
    # 过滤掉空的DataFrame并合并
    failure_dfs = [df for df in results if not df.empty]
    
    if failure_dfs:
        combined_df = pd.concat(failure_dfs, ignore_index=True)
        # 优化保存速度
        combined_df.to_csv(output_file, index=False, chunksize=10000)
        print(f"已成功将所有 failure=1 的行保存到 {output_file}，共 {len(combined_df)} 行。")
    else:
        print("没有找到任何 failure=1 的数据。")