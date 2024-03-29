# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
## Deploy a Policy
1. Login to Azure portal to  create and apply Tagging Policy that ensures all indexed resources in your subscription have tags and deny deployment if they do not.
2. Use `az policy assignment list` to verify the tag
For instructions on how to create and apply policy in Azure, click here: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources

#### Screenshot for `az policy assignment list`
![alt text](https://github.com/Julyseven2002/Udacity-Azure-DevOps-ND-Deploying-Web-Server-Azure/blob/master/polict-list-screenshot.png?raw=true)

## Build Packer Template
1. Change directory to the cloned repository and locate the starter_files sub-directory
2. Update the tag in `server.json`
3. Create an azure service principal for terraform using the command:
   
   ``` 
    az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
   ```
   
   You should get an output similar to:
   ```
        {
            "client_id": "xxxxxxxxxxxxxxxxxxxx",
            "client_secret": "xxxxxxxxxxxxxxxxxxx",
            "tenant_id": "xxxxxxxxxxxxxxxxxxxxxxx"
        }

   ```


5. Get sub_id:
   ```
   az account show --query "{ subscription_id: id }"
   ```
   
7. Run `packer build -var 'azure_subscription_id=xxxxxxxx'  server.json` to create a machine image. Enter your subscription_id 
Note: This would take few minutes to build

8. List packer images
   ```
    az image list
   ````

#### Output
Output of `packer build -var 'azure_subscription_id=xxxxxxxx'  server.json`
![alt text](https://github.com/Julyseven2002/Udacity-Azure-DevOps-ND-Deploying-Web-Server-Azure/blob/master/output-of-packer-build.png?raw=true)



## Create the Infrastructure using Terraform Template
1. Run `terraform init` to initialize  the Terraform environment
2. Run `terraform  plan -out solution.plan` to review  and validate Terraform template
   If everything looks correct and you're ready to build the infrastructure in Azure, apply the template in Terraform
3. Run `terraform apply solution.plan` to scans the current directory for the configuration and applies the changes appropriately.


Note: How fix resource group alreadyb exist error for `terraform apply` cmd:
```
terraform import azurerm_resource_group.rg /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1
```

Note: You can change the property names in packer image and terraform templates. For example , to change the Resource Group name in Terraform, 
use text editor of your choice like vi to edit the default property value in vars.tf file
`
variable "resource_group_name" {
  description = "The name of the resource group in which the resources are created"
  default     = "myResourceGroup"
}
`
#### Output
Once Terraform completes, your VM infrastructure is ready. 

Output of `terraform apply solution.plan`

![alt text](https://github.com/Julyseven2002/Udacity-Azure-DevOps-ND-Deploying-Web-Server-Azure/blob/master/output-of%20-terraform-%20apply.png?raw=true)


Reference:
Microsoft Azure website                            
https://docs.microsoft.com/en-us/azure
