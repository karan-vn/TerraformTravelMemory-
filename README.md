# MERN Application Deployment using Terraform and Ansible

## Overview

This project demonstrates the deployment of a MERN (MongoDB, Express.js, React.js, Node.js) application on AWS using Infrastructure as Code and configuration management.

The infrastructure is provisioned using **Terraform**, while **Ansible** is used to configure the EC2 instances, install required software, configure MongoDB, and deploy the MERN application.

The MERN application used for this assignment is:

**TravelMemory**  
https://github.com/UnpredictablePrashant/TravelMemory

---

## Objectives

The main objectives of this project are:

- Provision AWS infrastructure using Terraform.
- Create a VPC with public and private subnets.
- Configure Internet Gateway and NAT Gateway.
- Provision separate EC2 instances for the web and database servers.
- Configure AWS Security Groups and IAM roles.
- Configure EC2 instances using Ansible.
- Install Node.js and NPM on the web server.
- Install and configure MongoDB on the database server.
- Deploy the TravelMemory MERN application.
- Configure communication between the React frontend, Express backend, and MongoDB.
- Apply basic security hardening.
- Document the deployment and verify the working application.

---

# Architecture

The deployment uses a two-tier architecture on AWS.

```text
                           Internet
                              |
                              |
                    +---------v---------+
                    |  Internet Gateway |
                    +---------+---------+
                              |
                     Public Route Table
                              |
                    +---------v---------+
                    |   Public Subnet   |
                    |                   |
                    |  Web EC2 Instance |
                    |                   |
                    | Node.js / Express |
                    | React Frontend    |
                    +---------+---------+
                              |
                              |
                       Private Network
                              |
                    +---------v---------+
                    |  Private Subnet   |
                    |                   |
                    | Database EC2      |
                    |                   |
                    |    MongoDB        |
                    +-------------------+

                              ^
                              |
                       NAT Gateway

## Project Structure
Terraform Assignment/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── ...
│
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   │   ├── webserver.yml
│   │   ├── mongodb.yml
│   │   └── deploy.yml
│   ├── group_vars/
│   └── ...
│
├── docs/
│   ├── architecture.md
│   └── screenshots/
│
├── .gitignore
└── README.md


Prerequisites

The following tools are required:

AWS Account
AWS CLI
Terraform
Ansible
Git
SSH
WSL2 / Linux environment
An SSH key pair for EC2 access

AWS Infrastructure

Terraform is used to provision the AWS infrastructure required by the application.

VPC

A dedicated VPC is created for the application deployment.

The VPC contains:

One public subnet
One private subnet
Internet Gateway
NAT Gateway
Public route table
Private route table
Public Subnet

The public subnet contains the web server EC2 instance.

The web server requires internet connectivity so that the application can be accessed externally.

Private Subnet

The private subnet contains the database EC2 instance.

The database server is not directly exposed to the public internet.

Only the required application/web server traffic should be allowed to reach MongoDB.

NAT Gateway

The NAT Gateway provides outbound internet connectivity to resources in the private subnet while preventing direct inbound internet access to the private instance

EC2 Instances

Two EC2 instances are provisioned.

Web Server

The web server is deployed in the public subnet.

It hosts:

React frontend
Node.js
Express backend
Database Server

The database server is deployed in the private subnet.

It hosts:

MongoDB

The database server should only accept MongoDB connections from the web/application server.
Security Groups

Separate security groups are used for the web and database servers.

Web Server Security Group

The web server requires controlled access for:

SSH
HTTP
Application traffic where required

SSH access should be restricted to the administrator's public IP address.

Database Security Group

MongoDB traffic should only be allowed from the web/application server.

MongoDB should not be exposed directly to the public internet.

Terraform Deployment

Navigate to the Terraform directory:

cd terraform

Initialize Terraform:

terraform init

Validate the configuration:

terraform validate

Review the infrastructure plan:

terraform plan

Apply the infrastructure:

terraform apply

Confirm the deployment when prompted.

To display Terraform outputs:

terraform output

The public IP address of the web server should be available through the Terraform output.

Ansible Configuration

Ansible is used to configure the EC2 instances after Terraform has provisioned them.

The Ansible inventory contains the web and database servers.

Example:

[web]
WEB_SERVER_IP

[database]
DATABASE_SERVER_PRIVATE_IP

The private IP address of the database server is used for communication between the application and MongoDB.

Web Server Configuration

The Ansible playbook for the web server performs tasks such as:

Update required packages.
Install Node.js.
Install NPM.
Clone the TravelMemory repository.
Install application dependencies.
Configure environment variables.
Build/configure the React frontend.
Start the Node.js/Express backend.

Example Ansible command:

ansible-playbook -i inventory/hosts.ini playbooks/webserver.yml
MongoDB Server Configuration

The MongoDB server is configured using Ansible.

The configuration includes:

Installing MongoDB.
Starting and enabling the MongoDB service.
Configuring MongoDB networking.
Creating the required database.
Creating the required database user.
Enabling authentication where applicable.
Restricting access through the AWS Security Group and server firewall.

Example:

ansible-playbook -i inventory/hosts.ini playbooks/mongodb.yml
Application Configuration

The TravelMemory application consists of a React frontend and an Express/Node.js backend.

The application uses environment variables to establish communication between the components.

Conceptually:

React Frontend
      |
      | HTTP API Requests
      v
Express / Node.js Backend
      |
      | MongoDB Connection
      v
MongoDB

The backend connects to MongoDB using the MongoDB connection string.

The frontend is configured with the backend API URL.

Sensitive credentials should not be committed to Git.

Environment Variables

Environment-specific configuration should be stored outside the Git repository.

Example backend configuration:

MONGO_URI=<mongodb-connection-string>
PORT=<application-port>

Example frontend configuration:

REACT_APP_BACKEND_URL=<backend-url>

Actual credentials and secrets must not be committed to GitHub.

Security Hardening

The deployment includes basic security measures such as:

Restricting SSH access to the administrator's IP address.
Keeping MongoDB in a private subnet.
Restricting MongoDB access to the application server.
Configuring EC2 Security Groups.
Using SSH key-based authentication.
Avoiding direct public access to the database.
Avoiding hard-coded credentials in Terraform or Ansible files.
Disabling unnecessary network access.
Applying appropriate host firewall rules.
Disabling root SSH login where appropriate.
Verification

After deployment, the following should be verified.

Infrastructure
terraform validate
terraform plan
terraform output

Verify in AWS that:

VPC exists.
Public subnet exists.
Private subnet exists.
Internet Gateway is attached.
NAT Gateway is available.
Route tables are correctly configured.
Both EC2 instances are running.
Security Groups are correctly configured.
Ansible

Test connectivity:

ansible all -i inventory/hosts.ini -m ping

Expected result:

SUCCESS
MongoDB

Verify that MongoDB is running:

sudo systemctl status mongod
Application

Verify that:

The backend is running.
The frontend is accessible.
The frontend can communicate with the backend.
The backend can communicate with MongoDB.
Application functionality works as expected.

## Deployment Flow

The complete deployment process is:

1. Configure AWS
       |
       v
2. Terraform Initialization
       |
       v
3. Create VPC and Networking
       |
       v
4. Create Security Groups
       |
       v
5. Provision EC2 Instances
       |
       v
6. Obtain EC2 IP Addresses
       |
       v
7. Configure Ansible Inventory
       |
       v
8. Configure MongoDB Server
       |
       v
9. Configure Web Server
       |
       v
10. Deploy TravelMemory
       |
       v
11. Configure Application Variables
       |
       v
12. Test Frontend → Backend → MongoDB
       |
       v
13. Security Verification
       |
       v
14. Documentation and Screenshots
