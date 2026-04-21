import os


def get_storage_config():
    return {
        "use_managed_identity": os.getenv("USE_MANAGED_IDENTITY", "true").lower() == "true",
        "account_url": os.getenv("BLOB_ACCOUNT_URL"),
        "connection_string": os.getenv("BLOB_CONNECTION_STRING"),
        "container_name": os.getenv("BLOB_CONTAINER", "appdata"),
        "blob_name": os.getenv("BLOB_NAME", "counter.json"),
    }