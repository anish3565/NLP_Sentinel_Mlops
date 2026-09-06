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
    # dagshub_url = "https://dagshub.com"
    # repo_owner = "tripathianish12"
    # repo_name = "NLP_Sentiment_Analysis_IMDB_reviews"
    # dagshub_token = (
    #     os.getenv("CAPSTONE_TEST")
    #     or os.getenv("DAGSHUB_USER_TOKEN")
    #     or os.getenv("DAGSHUB_TOKEN")
    # )
    # if dagshub_token:
    #     os.environ["MLFLOW_TRACKING_USERNAME"] = dagshub_token
    #     os.environ["MLFLOW_TRACKING_PASSWORD"] = dagshub_token
    #     dagshub.init(
    #         repo_owner=repo_owner,
    #         repo_name=repo_name,
    #         mlflow=True
    #     )
    #     mlflow.set_tracking_uri(f"{dagshub_url}/{repo_owner}/{repo_name}.mlflow")
    #     logging.info("Initialized DagsHub remote MLflow tracking.")
    # else:
    #     logging.warning("No DagsHub token found. Running with default/local MLflow tracking.")
    # # -------------------------------------------------------------------------------------

    mlflow.set_tracking_uri('https://dagshub.com/tripathianish12/NLP_Sentiment_Analysis_IMDB_reviews.mlflow')
    dagshub.init(repo_owner='tripathianish12', repo_name='NLP_Sentiment_Analysis_IMDB_reviews', mlflow=True)

    client = mlflow.MlflowClient()
    model_name = "my_model"

    # 1. Look for candidate versions in 'Staging', then fallback to 'None'
    candidate_versions = client.get_latest_versions(
        model_name, stages=["Staging"]
    )
    if not candidate_versions:
        candidate_versions = client.get_latest_versions(model_name, stages=["None"])

    if not candidate_versions:
        # 2. Fallback: query all registered model versions and pick the latest
        all_versions = client.search_model_versions(f"name='{model_name}'")
        if not all_versions:
            raise ValueError(f"No versions found for registered model '{model_name}'")
        latest_version_staging = max(all_versions, key=lambda v: int(v.version)).version
    else:
        latest_version_staging = candidate_versions[0].version

    logging.info(
        "Found candidate model version %s for promotion.", latest_version_staging
    )

    # 3. Archive current production models
    prod_versions = client.get_latest_versions(model_name, stages=["Production"])
    for version in prod_versions:
        if str(version.version) != str(latest_version_staging):
            client.transition_model_version_stage(
            name=model_name, version=version.version, stage="Archived"
        )
        logging.info(
            "Archived previous production version %s", version.version
        )

    # 4. Promote candidate version to production
    client.transition_model_version_stage(
        name=model_name,
        version=latest_version_staging,
        stage="Production",
        archive_existing_versions=True,
    )
    print(f"Model version {latest_version_staging} promoted to Production")


    if __name__ == "__main__":
        promote_model()
