import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import StandardScaler  # SVM 和 KNN 建议标准化

from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt
import joblib
'''
    get_failure_mutipro.py和get_normal_mutipro.py
    在2020-2025这6年的数据中,一共选出来了20160个故障样本。
    其中最多的型号是ST12000NM0008,为2328个。
    相应地, 在所有csv文件中抽取了型号为ST12000NM0008的2328个正常样本。
'''

## 读取数据
normal = pd.read_csv("./normal.csv")
failure_raw = pd.read_csv("./failure.csv")
failure = failure_raw[failure_raw["model"] == "ST12000NM0008"]
print("normal hdds:", len(normal))
print("failure hdds:", len(failure))
df_data = pd.concat([normal, failure], ignore_index=True) # 合并

## 选取特征
features_specified = []
features = [5, 9, 187, 188, 193, 194, 197, 198, 241, 242]
for feature in features:
    features_specified += ["smart_{0}_raw".format(feature)]

X_data = df_data[features_specified] # 数据
Y_data = df_data['failure'] # 标签
X_data.isnull().sum() # 查看每列有多少空值
X_data = X_data.fillna(0) # 用0填充空值

print("normal hdds:", len(Y_data) - np.sum(Y_data.values))
print("failure hdds:", np.sum(Y_data.values))

X_train, X_test, Y_train, Y_test = train_test_split(X_data, Y_data, test_size=0.2, random_state=0)


# 注意：SVM 和 KNN 对特征尺度敏感，建议标准化
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# 定义多个分类器（字典形式，便于遍历）
classifiers = {
    "Random Forest": RandomForestClassifier(random_state=0),
    "Logistic Regression": LogisticRegression(random_state=0, max_iter=1000),
    "SVM": SVC(random_state=0),
    "Gradient Boosting": GradientBoostingClassifier(random_state=0),
    "KNN": KNeighborsClassifier()
}

# 存储结果
results = {}

# 遍历每个分类器
for name, clf in classifiers.items():
    print(f"\n=== Training {name} ===")
    
    # 对 SVM 和 KNN 使用标准化数据，其他用原始数据（也可统一用标准化）
    if name in ["SVM", "KNN"]:
        clf.fit(X_train_scaled, Y_train)
        Y_pred = clf.predict(X_test_scaled)
    else:
        clf.fit(X_train, Y_train)
        Y_pred = clf.predict(X_test)
    
    # 计算指标（注意：对于不平衡数据，建议用 average='binary' 或指定 pos_label）
    acc = accuracy_score(Y_test, Y_pred)
    prec = precision_score(Y_test, Y_pred, zero_division=0)
    rec = recall_score(Y_test, Y_pred, zero_division=0)
    f1 = f1_score(Y_test, Y_pred, zero_division=0)
    
    results[name] = {
        'Accuracy': acc,
        'Precision': prec,
        'Recall': rec,
        'F1-Score': f1
    }
    
    print(f"{name} - Acc: {acc:.4f}, Prec: {prec:.4f}, Rec: {rec:.4f}, F1: {f1:.4f}")


## RF训练测试
rfc = RandomForestClassifier()
rfc.fit(X_train, Y_train)
Y_pred = rfc.predict(X_test) 
acc = accuracy_score(Y_test, Y_pred)
prec = precision_score(Y_test, Y_pred, zero_division=0)
rec = recall_score(Y_test, Y_pred, zero_division=0)
f1 = f1_score(Y_test, Y_pred, zero_division=0)
print(f" 分类结果: \n acc: {acc}\n pre: {prec} \n recall: {rec} \n f1: {f1}")

# 混淆矩阵
cm = confusion_matrix(Y_test, Y_pred)

plt.figure(figsize=(6, 4))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
            xticklabels=['Valid', 'Failed'], 
            yticklabels=['Valid', 'Failed'])
plt.title('Confusion Matrix')
plt.xlabel('Predicted')
plt.ylabel('Actual')
# plt.show('RF.png')

# # 保存模型
# joblib.dump(rfc, './predict/rf_model.pkl')
# print("Model saved to ./predict/rf_model.pkl")

# # 加载模型
# loaded_rfc = joblib.load('./predict/rf_model.pkl')
# Y_pred_loaded = loaded_rfc.predict(X_test)

