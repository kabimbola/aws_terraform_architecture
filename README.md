# AWS Terraform Architecture

Add a route53 configured hosted zone as "dns-name" variable in variables.tf

# Setup bastion host, I used Amazon AMI linux

# On the bastion host:
install ansible
install terraform
install aws cli
install python3.X, pip, boto3 and botocore
set aws credentials
install git and connect git to your github account

# Configure and export AWS CLI
export aws profile variable
```
[ec2-user@bastion ~]$ aws configure --profile kenny
AWS Access Key ID [None]: AXXXXXXXXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: hZXXXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: us-east-1
Default output format [None]: json

[ec2-user@bastion ~]$ export AWS_PROFILE=kenny
```
# Create a dir and pull the codes from github.
```
[ec2-user@bastion ~]$ mkdir -p terraform-project; cd terraform-project;
```
# pull the code
```
[ec2-user@bastion terraform-project]$ git clone git@github.com:olayori/aws_terraform_architecture.git
```
# Set the profile in variables.tf to the AWS_PROFILE (kenny)
```
[ec2-user@bastion aws_terraform_architecture]$ cat variables.tf
variable "profile" {
  type    = string
  default = "kenny" # Set this to AWS profile name
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

# variable "dns-name" {
#   type    = string
#   default = "cmcloudlab1627.info"
# }
```
# Create new id_rsa.pub if not exist and enter in main.tf 
```
Verify:
[ec2-user@bastion aws_terraform_architecture]$ cat main.tf | grep id_rsa*
  public_key = file("~/.ssh/id_rsa.pub")
```
