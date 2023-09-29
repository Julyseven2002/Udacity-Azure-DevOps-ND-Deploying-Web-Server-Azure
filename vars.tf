variable "location" {
  type 	  = string
  description = "The location where resources are created"
  default     = "East US"
}

variable "resource_gn" {
  type 	  = string
  description = "The name of the resource group in which the resources are created"
  default     = "Azuredevops"
}

variable "number_instance" {
    description = "The number of instance(s) that the vm scale sets would create"
    type 	  = number
    default       = 2
}

variable "tags" {
    description = "A policy tag that ensures all indexed resources in your subscription have tags and deny deployment if they do not. A map of the tags to use for the resources that are deployed"
    type        = map(string)

    default = {
    environment = "dev"
    project_name = "Deploying a Web Server in Azure"
 }
}
variable "application_port" {
    type 	  = string
    description = "The port that you want to expose to the external load balancer"
    default     = 80
}

variable "admin_uname" {
    type 	  = string
    description = "Default username for admin"
    default = "azureuser1"
}

variable "admin_pwd" {
    type 	  = string
    description = "Default password for admin"
    default = "Pwd12345"
}

variable "resource_name_prefix" {
    type 	  = string
    description = "Default resource name prefix - DWSA stands for Deploying a Web Server in Azure"
    default = "udacitynd_DWSA_"
}
