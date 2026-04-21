import json
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
from config import get_storage_config


def get_blob_service_client():
    config = get_storage_config()

    # 🔐 Option 1: Managed Identity (explicit)
    if config["use_managed_identity"]:
        if not config["account_url"]:
            raise Exception("BLOB_ACCOUNT_URL is required when using Managed Identity")

        credential = DefaultAzureCredential()

        return BlobServiceClient(
            account_url=config["account_url"],
            credential=credential
        )

    # 🔑 Option 2: Connection String
    else:
        if not config["connection_string"]:
            raise Exception("BLOB_CONNECTION_STRING is required when not using Managed Identity")

        return BlobServiceClient.from_connection_string(
            config["connection_string"]
        )


def get_blob_client():
    config = get_storage_config()
    service = get_blob_service_client()

    return service.get_blob_client(
        container=config["container_name"],
        blob=config["blob_name"]
    )


def get_counter():
    blob = get_blob_client()

    try:
        data = blob.download_blob().readall()
        return json.loads(data)
    except Exception:
        return {"count": 0}


def update_counter():
    blob = get_blob_client()

    counter = get_counter()
    counter["count"] += 1

    blob.upload_blob(json.dumps(counter), overwrite=True)

    return counter["count"]