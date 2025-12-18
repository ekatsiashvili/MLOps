import mlflow
import mlflow.sklearn
import os
import shutil
import random
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, log_loss
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

# --- НАЛАШТУВАННЯ ---

MLFLOW_URI = "http://localhost:5000"
PUSHGATEWAY_URI = "localhost:9091"
OS_ENV = {
    "MLFLOW_S3_ENDPOINT_URL": "http://localhost:9000",  
    "AWS_ACCESS_KEY_ID": "minioadmin",
    "AWS_SECRET_ACCESS_KEY": "minioadminpassword"
}

# Застосовуємо змінні оточення для Boto3 
os.environ.update(OS_ENV)

# Налаштування MLflow
mlflow.set_tracking_uri(MLFLOW_URI)
mlflow.set_experiment("Iris_Experiment_V1")

# Налаштування Prometheus
registry = CollectorRegistry()
g_accuracy = Gauge('mlflow_accuracy', 'Model Accuracy', ['run_id', 'model_type'], registry=registry)
g_loss = Gauge('mlflow_loss', 'Model Loss (Pseudo)', ['run_id', 'model_type'], registry=registry)

def train():
    # 1. Дані
    iris = load_iris()
    X_train, X_test, y_train, y_test = train_test_split(iris.data, iris.target, test_size=0.2)

    # Параметри для експериментів
    params_list = [
        {"n_estimators": 10, "max_depth": 3},
        {"n_estimators": 50, "max_depth": 5},
        {"n_estimators": 100, "max_depth": 10},
    ]

    best_accuracy = 0
    best_run_id = None

    print(f" Starting training on {MLFLOW_URI}...")

    for i, params in enumerate(params_list):
        with mlflow.start_run(run_name=f"Run_{i+1}") as run:
            run_id = run.info.run_id
            print(f"   Training Run {i+1} (ID: {run_id})...")

            # 2. Тренування
            clf = RandomForestClassifier(**params, random_state=42)
            clf.fit(X_train, y_train)
            
            # 3. Передбачення
            y_pred = clf.predict(X_test)
            y_prob = clf.predict_proba(X_test)
            
            # 4. Метрики
            acc = accuracy_score(y_test, y_pred)
            loss = log_loss(y_test, y_prob)

            # 5. Логування в MLflow
            mlflow.log_params(params)
            mlflow.log_metrics({"accuracy": acc, "log_loss": loss})
            mlflow.sklearn.log_model(clf, "model")

            # 6. Пуш у Prometheus (Grafana)
            g_accuracy.labels(run_id=run_id, model_type="RandomForest").set(acc)
            g_loss.labels(run_id=run_id, model_type="RandomForest").set(loss)
            
            try:
                push_to_gateway(PUSHGATEWAY_URI, job='mlflow_experiment_job', registry=registry)
                print(f"      Metrics pushed to Gateway: Acc={acc:.4f}")
            except Exception as e:
                print(f"      ⚠️ Warning: Could not push to Gateway: {e}")

            # Перевірка на кращу модель
            if acc > best_accuracy:
                best_accuracy = acc
                best_run_id = run_id

    print("-" * 30)
    print(f"🏆 Best Run ID: {best_run_id} with Accuracy: {best_accuracy:.4f}")
    
    # Завантаження кращої моделі
    if best_run_id:
        print("💾 Downloading best model...")
        model_uri = f"runs:/{best_run_id}/model"
        local_path = "./best_model"
        
        # Чистимо стару папку
        if os.path.exists(local_path):
            shutil.rmtree(local_path)
            
        mlflow.artifacts.download_artifacts(artifact_uri=model_uri, dst_path=local_path)
        print(f" Model saved to {local_path}")

if __name__ == "__main__":
    train()