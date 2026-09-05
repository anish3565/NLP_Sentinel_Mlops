import os
import sys
import json
import pickle
import logging
import warnings
import dagshub
import mlflow
import mlflow.sklearn
from dotenv import load_dotenv

# Path resolution
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))
from src.logger import logging

warnings.simplefilter("ignore", UserWarning)
warnings.filterwarnings("ignore")

load_dotenv()

# # Production use
# -------------------------------------------------------------------------------------
dagshub_url = "https://dagshub.com"
repo_owner = "tripathianish12"
repo_name = "NLP_Sentiment_Analysis_IMDB_reviews"
dagshub_token = (
    os.getenv("CAPSTONE_TEST")
    or os.getenv("DAGSHUB_USER_TOKEN")
    or os.getenv("DAGSHUB_TOKEN")
)

if dagshub_token:
    os.environ["MLFLOW_TRACKING_USERNAME"] = dagshub_token
    os.environ["MLFLOW_TRACKING_PASSWORD"] = dagshub_token
    dagshub.init(
        repo_owner=repo_owner,
        repo_name=repo_name,
        mlflow=True
    )
    mlflow.set_tracking_uri(f"{dagshub_url}/{repo_owner}/{repo_name}.mlflow")
    logging.info("Initialized DagsHub remote MLflow tracking.")
else:
    logging.warning("No DagsHub token found. Running with default/local MLflow tracking.")
# -------------------------------------------------------------------------------------

# # For local
# -------------------------------------------------------------------------------------
# mlflow.set_tracking_uri('https://dagshub.com/tripathianish12/NLP_Sentiment_Analysis_IMDB_reviews.mlflow')
# dagshub.init(repo_owner='tripathianish12', repo_name='NLP_Sentiment_Analysis_IMDB_reviews', mlflow=True)
# -------------------------------------------------------------------------------------


def load_model_info(file_path: str) -> dict:
    """Load the model info from a JSON file."""
    try:
        with open(file_path, 'r') as file:
            model_info = json.load(file)
        logging.debug('Model info loaded from %s', file_path)
        return model_info
    except FileNotFoundError:
        logging.error('File not found: %s', file_path)
        raise
    except Exception as e:
        logging.error('Unexpected error occurred while loading the model info: %s', e)
        raise


def register_model(model_name: str, model_info: dict, local_model_fallback: str = "./models/model.pkl"):
    """Register the model to the MLflow Model Registry with fallback to local artifact."""
    run_id = model_info.get('run_id')
    model_path = model_info.get('model_path', 'model')
    model_uri = f"runs:/{run_id}/{model_path}"

    try:
        logging.info(f"Attempting to register model from URI: {model_uri}")
        model_version = mlflow.register_model(model_uri=model_uri, name=model_name)
        logging.info(f"Model {model_name} version {model_version.version} registered from run {run_id}.")
    except Exception as e:
        logging.warning(f"Remote run artifact not found ({e}). Falling back to logging & registering local model...")
        
        # Fallback: Log local model directly into active MLflow run and register
        with mlflow.start_run(run_id=run_id):
            with open(local_model_fallback, "rb") as f:
                clf = pickle.load(f)
            
            model_version = mlflow.sklearn.log_model(
                sk_model=clf,
                artifact_path=model_path,
                registered_model_name=model_name
            )
            logging.info(f"Successfully uploaded and registered {model_name} via fallback.")


def main():
    try:
        model_info_path = 'reports/experiment_info.json'
        model_info = load_model_info(model_info_path)
        
        model_name = "my_model"
        register_model(model_name, model_info)
    except Exception as e:
        logging.error('Failed to complete the model registration process: %s', e)
        print(f"Error: {e}")


if __name__ == '__main__':
    main()