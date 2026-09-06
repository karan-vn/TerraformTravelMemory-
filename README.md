# MERN Application Deployment on AWS using Terraform and Ansible

## Project Overview

This project is part of the Hero Vired DevOps assignment for deploying a MERN stack application on AWS using Infrastructure as Code and configuration management.

The project uses:

- Terraform for AWS infrastructure provisioning
- Ansible for server configuration and application deployment
- AWS EC2 for compute
- AWS VPC for network isolation
- MongoDB for the database
- Node.js and Express.js for the backend
- React.js for the frontend

The MERN application used for this assignment is TravelMemory.

Application Repository:

https://github.com/UnpredictablePrashant/TravelMemory

---

## Assignment Objective

The objective of this project is to gain practical experience in deploying a MERN stack application on AWS using:

1. Terraform for infrastructure automation
2. Ansible for configuration management
3. AWS networking and security
4. EC2-based application hosting
5. MongoDB database deployment
6. Secure communication between application components

---

## Architecture

The planned AWS architecture consists of a VPC with separate public and private subnets.

Internet
  |
  v
Internet Gateway
  |
  v
Public Subnet
  |
  +-- Web EC2 Instance
      - React Frontend
      - Node.js
      - Express Backend
  |
  v
Private Network
  |
  +-- Private Subnet
      - Database EC2 Instance
      - MongoDB

The private subnet uses a NAT Gateway for outbound internet access when required.

The MongoDB server is not intended to be directly accessible from the public internet.

---

## AWS Infrastructure

Terraform is used to provision the AWS infrastructure required for the application.

### VPC

A dedicated VPC will be created for the application deployment.

The VPC contains:

- Public subnet
- Private subnet
- Internet Gateway
- NAT Gateway
- Public route table
- Private route table

### Public Subnet

The public subnet hosts the web/application EC2 instance.

The web server provides the externally accessible application components.

### Private Subnet

The private subnet hosts the database EC2 instance.

MongoDB is kept inside the private subnet to reduce direct exposure to the internet.

### NAT Gateway

The NAT Gateway provides outbound internet connectivity for resources in the private subnet without providing direct inbound internet access.

---

## EC2 Instances

Two EC2 instances are planned for the deployment.

### Web Server

The web server is deployed in the public subnet.

It will host:

- React frontend
- Node.js
- Express backend

### Database Server

The database server is deployed in the private subnet.

It will host:

- MongoDB

The database server will only accept the required database traffic from the application server.

---

## Security

Security Groups will be configured separately for the web and database servers.

### Web Server Security Group

The web server will allow only the required inbound traffic.

SSH access will be restricted to the administrator's public IP address.

Application HTTP/HTTPS traffic will be allowed as required by the deployment.

### Database Security Group

The database server will not be publicly exposed.

MongoDB traffic will be restricted to the web/application server.

This prevents direct public access to the database.

---

## IAM

IAM roles will be configured for the EC2 instances where required.

The project follows the principle of granting only the permissions necessary for the deployed infrastructure.

AWS credentials and other sensitive information will not be stored in the Git repository.

---

## Terraform

Terraform is used to create and manage the AWS infrastructure.

### Terraform responsibilities

Terraform will provision:

- AWS provider configuration
- VPC
- Public subnet
- Private subnet
- Internet Gateway
- NAT Gateway
- Route tables
- Security Groups
- EC2 instances
- IAM resources
- Terraform outputs

### Terraform commands

Initialize Terraform:

`terraform init`

Validate the configuration:

`terraform validate`

Review the infrastructure plan:

`terraform plan`

Create the AWS infrastructure:

`terraform apply`

Display Terraform outputs:

`terraform output`

Destroy the infrastructure when it is no longer required:

`terraform destroy`

The `terraform destroy` command should only be used after collecting all required screenshots and assignment evidence.

---

## Ansible

Ansible is used to configure the EC2 instances after they are provisioned by Terraform.

### Ansible responsibilities

Ansible will be used to:

- Configure SSH connectivity
- Configure the web server
- Install Node.js
- Install NPM
- Clone the TravelMemory application
- Install application dependencies
- Configure application environment variables
- Install MongoDB
- Configure MongoDB
- Create the required MongoDB database/user
- Start and configure application services
- Apply server-level security configuration

---

## Web Server Configuration

The web server will be configured using Ansible.

The configuration process includes:

1. Updating the operating system packages
2. Installing Node.js
3. Installing NPM
4. Cloning the TravelMemory repository
5. Installing backend dependencies
6. Installing frontend dependencies
7. Configuring application environment variables
8. Building/configuring the React frontend
9. Starting the Node.js/Express application

---

## Database Server Configuration

The database server will be configured using Ansible.

The configuration process includes:

1. Installing MongoDB
2. Starting the MongoDB service
3. Enabling MongoDB to start automatically
4. Configuring MongoDB networking
5. Creating the required database
6. Creating the required database user
7. Configuring authentication where required
8. Restricting access to the application server

---

## Application Flow

The application follows this communication flow:

React Frontend
      |
      | HTTP API Requests
      v
Node.js / Express Backend
      |
      | MongoDB Connection
      v
MongoDB Database

The React frontend communicates with the Express backend through the configured backend URL.

The Express backend communicates with MongoDB using the configured MongoDB connection string.

---

## Environment Variables

Environment-specific values will be configured on the servers and will not be committed to Git.

Typical backend configuration includes:

MONGO_URI=<MongoDB connection string>

PORT=<backend port>

Typical frontend configuration includes:

REACT_APP_BACKEND_URL=<backend URL>

Actual credentials, passwords, private keys and other secrets must never be committed to this repository.

---

## Project Structure

The repository is organized around the infrastructure and configuration components of the deployment.

Terraform files are maintained under the Terraform section of the project.

Ansible playbooks and inventory files are maintained under the Ansible section.

Documentation and deployment evidence can be maintained under the documentation section.

A typical structure is:

TerraformTravelMemory-/
|
+-- terraform/
|   +-- providers.tf
|   +-- main.tf
|   +-- variables.tf
|   +-- outputs.tf
|   +-- ...
|
+-- ansible/
|   +-- inventory/
|   +-- playbooks/
|   +-- group_vars/
|   +-- ...
|
+-- docs/
|   +-- screenshots/
|   +-- architecture/
|
+-- .gitignore
+-- README.md

The exact structure may evolve during implementation.

---

## Deployment Workflow

The deployment process follows these stages:

1. Configure AWS CLI
2. Configure AWS authentication
3. Initialize Terraform
4. Create the VPC
5. Create public and private subnets
6. Configure Internet Gateway
7. Configure NAT Gateway
8. Configure route tables
9. Configure Security Groups
10. Provision EC2 instances
11. Configure Terraform outputs
12. Configure Ansible inventory
13. Configure the MongoDB server
14. Configure the web server
15. Deploy the TravelMemory application
16. Configure application environment variables
17. Start the backend
18. Configure the frontend
19. Verify frontend-to-backend communication
20. Verify backend-to-MongoDB communication
21. Perform security checks
22. Capture deployment evidence
23. Document the implementation

---

## Verification and Testing

The deployment will be verified at multiple levels.

### Terraform Verification

Run:

`terraform validate`

`terraform plan`

`terraform output`

Verify that the expected AWS resources have been created.

### Ansible Verification

Test Ansible connectivity using:

`ansible all -i inventory/hosts.ini -m ping`

### Web Server Verification

Verify:

- Node.js installation
- NPM installation
- Application dependencies
- Backend service
- Frontend deployment

### MongoDB Verification

Verify that MongoDB is:

- Installed
- Running
- Enabled
- Accessible from the application server
- Not publicly accessible

### Application Verification

Verify that:

- The React frontend loads successfully
- The frontend can communicate with the backend
- The backend can communicate with MongoDB
- Application functionality works correctly

---

## Security Hardening

The deployment includes the following security considerations:

- Restrict SSH access to the administrator's IP address
- Keep MongoDB inside the private subnet
- Do not expose MongoDB directly to the internet
- Restrict MongoDB access using Security Groups
- Use SSH key-based authentication
- Avoid storing credentials in Git
- Avoid committing `.env` files
- Avoid committing private SSH keys
- Configure host-level firewall rules where appropriate
- Disable unnecessary services and ports
- Disable root SSH login where appropriate

---

## Git Security

The repository must not contain:

- AWS access keys
- AWS secret keys
- SSH private keys
- MongoDB passwords
- Application secrets
- `.env` files
- Terraform state files containing sensitive information

Sensitive files should be excluded through `.gitignore`.

---

## Screenshots and Evidence

The assignment requires documentation and evidence of the working deployment.

The following evidence will be collected:

- Terraform initialization
- Terraform validation
- Terraform plan
- Terraform apply
- AWS VPC
- Public subnet
- Private subnet
- Internet Gateway
- NAT Gateway
- Route tables
- Security Groups
- EC2 instances
- Ansible execution
- MongoDB configuration
- Node.js configuration
- Running backend
- Running frontend
- Working MERN application
- Application communication with MongoDB

Screenshots will be stored in the project documentation directory where applicable.

---

## Deliverables

The completed assignment will contain:

- Terraform scripts for AWS infrastructure
- Ansible playbooks for configuration and deployment
- AWS infrastructure configuration
- MERN application deployment
- Security configuration
- Implementation documentation
- Screenshots/video demonstrating the working application
- GitHub repository containing the complete assignment

---

## Technologies Used

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| Ansible | Configuration management |
| EC2 | Application and database servers |
| VPC | Network isolation |
| Internet Gateway | Internet connectivity |
| NAT Gateway | Private subnet outbound connectivity |
| Security Groups | Network access control |
| IAM | AWS permissions |
| MongoDB | Database |
| Express.js | Backend framework |
| React.js | Frontend framework |
| Node.js | JavaScript runtime |
| Git/GitHub | Source code management |
| WSL2 | Linux development environment |

---

## Repository

GitHub Repository:

https://github.com/karan-vn/TerraformTravelMemory-

---

## Application Repository

TravelMemory:

https://github.com/UnpredictablePrashant/TravelMemory

---

## Author

**Karan Kumar**

Hero Vired DevOps Assignment

MERN Application Deployment using Terraform and Ansible
