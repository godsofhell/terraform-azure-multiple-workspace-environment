locals {
  virtual_network_details=[
    {
        //the name of virtual network name will be either dev-network or prod-network based on the workspace selected
        virtual_network_name="${terraform.workspace}-network"
        //the address space will be picked from the terraform.tfvars file based on the workspace selected
        virtual_network_address_space=var.environment[terraform.workspace].virtual_network_address_space
    }
    ]

//we use flatten here to go deep into the nested for loops and create a single list of maps
subnet_details=(flatten([

for subnet_key,subnets in var.environment[terraform.workspace].subnets :
{ 
    subnet_name=subnet_key
	virtual_network_name="${terraform.workspace}-network"
    subnet_address_prefix=subnets.subnet_address_prefix 	
}]
 ))


 network_interface_details=(flatten([
    
    for subnet_key,subnets in var.environment[terraform.workspace].subnets :[
        for network_interfaces in subnets.network_interfaces :
        {
        network_interface_name=network_interfaces.name
        subnet_name=subnet_key
    }]
       ]))


virtual_machine_details=(flatten([
    for subnet_key,subnets in var.environment[terraform.workspace].subnets :[
        for network_interfaces in subnets.network_interfaces :
        {
        network_interface_name=network_interfaces.name
        virtual_machine_name=network_interfaces.virtual_machine_name
        //script_name=network_interfaces.script_name
    }]
       ]))
}