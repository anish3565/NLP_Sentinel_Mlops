import logging
import os
import dagshub
import mlflow

from dotenv import load_dotenv

load_dotenv()
logging.basicConfig(level=logging.INFO)
def promote_model():
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

    client = mlflow.MlflowClient()

    model_name = "my_model"
    # Get the latest version in staging
    latest_version_staging = client.get_latest_versions(model_name, stages=["Staging"])[0].version

    # Archive the current production model
    prod_versions = client.get_latest_versions(model_name, stages=["Production"])
    for version in prod_versions:
        client.transition_model_version_stage(
            name=model_name,
            version=version.version,
            stage="Archived"
        )

    # Promote the new model to production
    client.transition_model_version_stage(
        name=model_name,
        version=latest_version_staging,
        stage="Production"
    )
    print(f"Model version {latest_version_staging} promoted to Production")

if __name__ == "__main__":
    promote_model()
