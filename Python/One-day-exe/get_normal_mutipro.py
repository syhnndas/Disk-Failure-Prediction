import os
import pandas as pd
import glob
from tqdm import tqdm
from multiprocessing import Pool, cpu_count
import warnings
warnings.filterwarnings('ignore')

# 配置参数
data_folder = "./RawData"
output_file = "normal_samples.csv"
target_model = "ST12000NM0008"  # 目标型号
target_count = 2328  # 需要抽取的正常样本数量
max_per_file = 5     # 每个文件最多抽取的样本数

def process_single_file(file_path):
    """
    处理单个CSV文件，抽取符合条件的正常样本
    返回：该文件中抽取的正常样本DataFrame
    """
    try:
        # 读取CSV文件
        df = pd.read_csv(file_path, low_memory=False)
        
        # 检查必要列是否存在
        required_cols = ['failure', 'model']
        if not all(col in df.columns for col in required_cols):
            missing = [col for col in required_cols if col not in df.columns]
            print(f"警告: 文件 {file_path} 缺少列 {missing}，已跳过。")
            return pd.DataFrame()
        
        # 数据类型转换和筛选
        # 转换failure列为数值类型
        df['failure'] = pd.to_numeric(df['failure'], errors='coerce')
        # 转换model列为字符串类型
        df['model'] = df['model'].astype(str).str.strip()
        
        # 筛选条件：failure=0 且 model匹配目标型号
        mask = (df['failure'] == 0) & (df['model'] == target_model)
        df_normal = df[mask].copy()
        
        if df_normal.empty:
            return pd.DataFrame()
        
        # 每个文件最多抽取max_per_file条，随机抽取避免相似性
        sample_size = min(max_per_file, len(df_normal))
        df_sample = df_normal.sample(n=sample_size, random_state=42)  # 固定随机种子保证可复现
        
        return df_sample
    
    except Exception as e:
        print(f"处理文件 {file_path} 时出错: {str(e)}")
        return pd.DataFrame()

if __name__ == "__main__":
    # 获取所有CSV文件路径
    csv_files = glob.glob(os.path.join(data_folder, "*.csv"))
    
    if not csv_files:
        print("未找到任何CSV文件！")
        exit()
    
    # 初始化变量
    collected_samples = []
    collected_count = 0
    
    # 获取CPU核心数，创建进程池
    num_processes = cpu_count()
    print(f"使用 {num_processes} 个进程并行处理 {len(csv_files)} 个CSV文件...")
    print(f"目标抽取 {target_count} 条 {target_model} 型号的正常样本（failure=0），每个文件最多抽取 {max_per_file} 条")
    
    # 多进程处理文件
    with Pool(processes=num_processes) as pool:
        # 遍历处理结果，实时统计收集数量
        results = list(tqdm(pool.imap(process_single_file, csv_files),
                           total=len(csv_files),
                           desc="抽取正常样本进度"))
    
    # 合并结果并控制总数
    all_samples = []
    for sample_df in results:
        if not sample_df.empty and collected_count < target_count:
            # 计算还需要抽取的数量
            need = target_count - collected_count
            take = min(need, len(sample_df))
            # 抽取指定数量的样本
            take_df = sample_df.head(take)
            all_samples.append(take_df)
            collected_count += take
            
            # 达到目标数量后提前终止
            if collected_count >= target_count:
                break
    
    # 保存结果
    if all_samples:
        final_df = pd.concat(all_samples, ignore_index=True)
        final_df.to_csv(output_file, index=False, chunksize=10000)
        print(f"\n抽取完成！共获取到 {len(final_df)} 条 {target_model} 型号的正常样本")
        print(f"样本已保存到 {output_file}")
        
        # 打印样本分布信息
        file_counts = final_df.groupby(final_df.index // max_per_file).size()
        print(f"样本来自 {len(file_counts)} 个不同的CSV文件，符合每个文件最多{max_per_file}条的限制")
    else:
        print("\n未找到任何符合条件的正常样本！")