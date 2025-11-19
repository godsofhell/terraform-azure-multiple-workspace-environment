# ============================================================================
# AZURE INFRASTRUCTURE WITH MONITORING - Main Configuration
# ============================================================================
# PROJECT: Complete Azure setup with 2 VMs, networking, storage, and monitoring
# 
# WHAT THIS BUILDS:
#   - 2 Windows VMs (webvm01, appvm01) with IIS web server
#   - Virtual network with 2 subnets (web subnet, app subnet)
#   - Storage account with scripts and data containers
#   - Monitoring: Alerts (CPU/Network thresholds) + Logging (Windows Event Logs)
#
# DEPLOYMENT ORDER (Dependencies):
#   1. Resource Group (container for everything)
#   2. Network + Storage (parallel - no dependencies on each other)
#   3. VMs (needs Network + Storage)
#   4. Monitoring (needs VMs to be running)
#
# QUICK REFERENCE:
#   - Edit settings: terraform.tfvars
#   - Plan changes: .\terraform plan
#   - Apply changes: .\terraform apply
#   - Destroy all: .\terraform destroy
# ============================================================================

# Module 1: Resource Group (the container)
module "resource-group" {
    source = "./modules/general/resourcegroup"
    //depending on the name of workspace the name of resource group will be created
    resource_group_name = "${terraform.workspace}-${var.resource_group_name}"
    location = var.location
}   

# Module 2: Networking (virtual network + subnets + security rules)
module "network" {
   source="./modules/networking/vnet"
   resource_group_name = "${terraform.workspace}-${var.resource_group_name}"
   location = var.location
   network_security_group_rules = var.network_security_group_rules
   subnet_details = local.subnet_details
   virtual_network_details = local.virtual_network_details
   network_interface_details = local.network_interface_details
   depends_on = [ module.resource-group ]
}


module "virtual-machines" {    
    source="./modules/compute/virtualMachines"
    resource_group_name="${terraform.workspace}-${var.resource_group_name}"
    location=var.location
    virtual_machine_details = local.virtual_machine_details
    network_interface_details = local.network_interface_details
    
    depends_on = [ module.network ]
}

