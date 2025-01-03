# Google Cloud Platform (GCP) Instance and Database Security

This project is a secure, scalable Cloud SQL solution that automates provisioning and management using Terraform and Google Cloud SDK Shell. It features automated instance creation, CMEK integration for encrypted backups, point-in-time recovery, secure networking with VPC and firewall rules, and robust monitoring and alerting for compliance and data protection

## Features

- **Automated Cloud SQL Instance Creation**: Created MySQL instances with specified tiers, regions, and availability settings.
- **CMEK Integration**: Secured backups with Customer Managed Encryption Keys (CMEK) using Google Cloud KMS.
- **Secure Networking**: Configured Virtual Private Cloud (VPC), firewall rules, and Private IP configurations to isolate and protect the database from unauthorized access.
- **Data Encryption in Transit and at Rest**: Enabled SSL/TLS encryption for secure communication and ensured encrypted backups.
- **IAM Permissions Management**: Assigned roles and permissions for secure and controlled access using the IAM API and Service Account Credentials API.
- **Replica Management**: Set up read replicas for improved scalability and reliability.
- **Backup Configuration**: Enabled automated backups with a customizable retention policy and backup window.
- **Point-in-Time Recovery**: Configured point-in-time recovery by enabling binary logging for Cloud SQL instances.
- **Database Monitoring and Alerts**: Implemented Google Cloud Monitoring and Logging to track database activity and set up alerts for performance issues or failed access attempts.
- **Audit Logs and Compliance**: Tracked access and modifications to the database using Cloud Logging to meet security and compliance standards.

## Tools and Technologies

- **Terraform**: Infrastructure as Code (IaC) tool used for managing resources in Google Cloud.
- **Google Cloud SDK Shell**: Command-line interface for managing GCP resources and running Terraform scripts locally.
- **Google Cloud Platform**:
  - **Cloud SQL**: Managed SQL database service for MySQL.
  - **VPC and Firewall Rules**: Configured secure networking and traffic isolation.
  - **Google Cloud KMS**: Key management service for securing encryption keys.
  - **Google Cloud Monitoring and Logging**: Tracked database health, performance, and security with integrated alerting.
  - **IAM**: Role and policy management for secure access control.

## Google Cloud Platform APIs Used
- **Cloud SQL Admin API and Cloud SQL API**: Managed Cloud SQL resources like instances, backups, and replicas.
- **Cloud Key Management Service (KMS) API**: Secured and managed cryptographic keys.
- **Compute Engine API**: Managed virtual machines and firewall configurations for enhanced security.
- **Service Networking API**: Enabled secure Private IP configurations and network peering.
- **Cloud Logging API**: Captured and stored logs for auditing and debugging.
- **Cloud Monitoring API**: Monitored database performance and integrates alerting for anomalies.
- **Gemini for Google Cloud API**: Utilized Gemini to gather feedback for performance optimization and monitoring.
- **IAM Service Account Credentials API**: Managed secure access for service accounts.

## Google Cloud Platform Screenshots
### Instance Overview
![Screenshot 2025-01-02 130958](https://github.com/user-attachments/assets/08657c3f-d9b3-436b-bf48-68660568fbbc)

### Read Replica Instance
![Screenshot 2025-01-02 080819](https://github.com/user-attachments/assets/9c0ecc73-dfc1-4e67-bba5-8994440adf6c)

### Key Ring Management Details
![Screenshot 2025-01-01 190723](https://github.com/user-attachments/assets/9eb35653-7fe8-4f72-a18e-34b046663fae)

### Database Performance Monitoring Dashboard
![Screenshot 2025-01-01 235557](https://github.com/user-attachments/assets/539a6b2f-cb99-4ff6-9caf-bd586b49d261)

### Tracking Log Activities
![Screenshot 2025-01-01 213013](https://github.com/user-attachments/assets/d8b96659-20d3-497c-b86c-8abf80a2331c)
