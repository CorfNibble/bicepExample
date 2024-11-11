
# Azure DevOps Pipeline for App Service and SQL Database Deployment

This project provides an automated Azure DevOps pipeline for deploying an Azure App Service and SQL Database using Bicep templates, with integration to Key Vault for secure management of sensitive data.

## Key Components and Design Rationale

### App Service
The App Service is designed for scalability and resilience, with autoscaling rules configured to handle increased CPU usage. The pipeline parameters allow customization of scaling thresholds, making it adaptable to specific application performance needs.

### SQL Database
The SQL Database is accessible only through a connection string securely stored in Azure Key Vault. This ensures credentials are not hardcoded or exposed in the source code, adhering to best security practices.

### Key Vault
Key Vault serves as a centralized, secure storage solution for sensitive information like database credentials. The App Service retrieves the SQL connection string directly from Key Vault at runtime, further strengthening security.

## Diagnostic Logging

### App Service and SQL Database Logging
Diagnostic logging is enabled for both the App Service and SQL Database, capturing performance metrics and query logs for monitoring. Key logging configurations include:

- **CPU usage metrics**: Monitored for scaling decisions and performance analysis.
- **SQL query logs**: Useful for query optimization and troubleshooting database-related issues.

Logs are accessible through Azure Monitor, allowing for real-time alerting and historical performance analysis.

## Pipeline Structure

The pipeline automates secure deployment and testing with the following stages:

1. **Validation**: Checks Bicep template syntax to prevent deployment issues.
2. **Deployment**: Deploys resources in Azure, applying autoscaling rules and diagnostic settings.
3. **Integration Testing**: Mocks up a connectivity test to verify that the App Service can securely communicate with the SQL Database.
4. **Output Stage**: Outputs the App Service URL and retrieves the SQL connection string securely from Key Vault.

## Usage

### Prerequisites
- Azure DevOps Service Connection (replace in pipeline file with your connection details)
- Azure CLI installed for local testing if necessary
- Azure resources in the appropriate resource group (modify `resourceGroupName` as needed)

### Running the Pipeline
1. Commit your Bicep files and the `azure-pipelines.yml` file to the repository.
2. The pipeline triggers on pushes to the `main` branch.
3. Monitor the pipeline stages in Azure DevOps to verify each step, particularly the deployment and testing stages.

## Security Considerations

Sensitive information, such as the SQL connection string, is retrieved from Key Vault to prevent credential exposure. The pipeline outputs critical information without storing sensitive data in plaintext.

This CI/CD process promotes a secure, automated workflow for infrastructure provisioning, performance monitoring, and integration testing.
