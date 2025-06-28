# Setup for Terraform on Google Cloud

This guide outlines the steps required to configure a Google Cloud project to work with Terraform, using a service account for authentication and storing credentials securely in Google Secret Manager.

## Prerequisites

1. **Install the Google Cloud CLI**
    - Download and install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install-sdk).

2. **Create a Service Account**
    - Use the following command to create a service account for Terraform:
      ```bash
      gcloud iam service-accounts create terraform \
        --description="Terraform service account" \
        --display-name="terraform"
      ```

3. **Assign Permissions to the Service Account**
    - Grant the service account owner-level access to the project so it can manage resources:
      ```bash
      gcloud projects add-iam-policy-binding processes-dev \
        --member="serviceAccount:terraform@processes-dev.iam.gserviceaccount.com" \
        --role="roles/owner"
      ```

4. **Create a JSON Key for the Service Account**
    - Generate a JSON key for the service account to allow Terraform to authenticate:
      ```bash
      gcloud iam service-accounts keys create ~/terraform-key.json \
        --iam-account=terraform@processes-dev.iam.gserviceaccount.com
      ```

5. **Store the Service Account Key in Google Secret Manager**

   5.1 **Enable the Secret Manager API**
    - Enable the Secret Manager API in your Google Cloud project:
      ```bash
      gcloud services enable secretmanager.googleapis.com
      ```

   5.2 **Create a Secret in Secret Manager**
    - Create a secret to store the service account key:
      ```bash
      gcloud secrets create terraform-service-account-key --replication-policy="automatic"
      ```

   5.3 **Upload the JSON Key to Secret Manager**
    - Add the JSON key file to the secret:
      ```bash
      gcloud secrets versions add terraform-service-account-key \
        --data-file=~/terraform-key.json
      ```

   5.4 **Grant Access to the Service Account**
    - Allow the Terraform service account to access the secret in Secret Manager:
      ```bash
      gcloud secrets add-iam-policy-binding terraform-service-account-key \
        --member="serviceAccount:terraform@processes-dev.iam.gserviceaccount.com" \
        --role="roles/secretmanager.secretAccessor"
      ```

   5.5 **Grant User Access to the Secret (Optional)**
    - Allow a user to access the secret if needed:
      ```bash
      gcloud secrets add-iam-policy-binding terraform-service-account-key \
        --member="user:ferorellan20@gmail.com" \
        --role="roles/secretmanager.secretAccessor"
      ```

6. **Create a Cloud Storage Bucket for Terraform State**
    - Create a Google Cloud Storage bucket to store the Terraform state:
      ```bash
      gsutil mb -p processes-dev gs://terraform_state_zacatecoluca
      ```

7. **Enable object versioning on GCS**
    - Enable object versioning on the Google Cloud Storage bucket that stores the Terraform state:
    ```bash
    gcloud storage buckets update gs://terraform_state_zacatecoluca --versioning
    ```

8. **Enable lifecycle policy for versioning**
    - Create a JSON file `tf-state-policy.json` for storing the policy configuration to avoid unlimited versioning on the Terraform state bucket:
    ```json
    {
      "lifecycle": {
        "rule": [
          {
            "action": {"type": "Delete"},
            "condition": {
              "numNewerVersions": 10,
              "isLive": false
            }
          }
        ]
      }
    }
    ```

    - Apply the object lifecycle policy to the bucket:
    ```bash
    gcloud storage buckets update gs://terraform_state_dev --lifecycle-file=tf-state-policy.json
    ```

## Next Steps

Now that the environment is set up:
  1. Remember to run `gcloud auth application-default login` to start running terraform commands.




