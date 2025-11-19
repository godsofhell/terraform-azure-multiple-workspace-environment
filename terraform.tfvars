resource_group_name = "grp"
location = "UK South"

network_security_group_rules=[
    {
      priority=300
      destination_port_range="3389"
    },
    {
      priority=310
      destination_port_range="80"
    }
  ]

environment = {
  //dev-network is the name of the virtual network
  //there are two environments dev and prod
  dev = {
      virtual_network_address_space="10.0.0.0/16"
      subnets={
        //web and app are the names of the subnets
        web={
            subnet_address_prefix="10.0.0.0/24"
            network_interfaces=[
              {
                //webinterface01 is the name of the network interface
              name="webinterface01"
              // webvm01 is the name of the virtual machine
              virtual_machine_name="webvm01"
              
              }
              ]
            }        
        app={
            subnet_address_prefix="10.0.1.0/24"
            network_interfaces=[{
              name="appinterface01"
              virtual_machine_name="appvm01"
              
              }]    
            }
            }
  }


            prod = {
      virtual_network_address_space="10.1.0.0/16"
      subnets={
        //web and app are the names of the subnets
        web={
            subnet_address_prefix="10.1.0.0/24"
            network_interfaces=[
              {
                //webinterface01 is the name of the network interface
              name="webinterface01"
              // webvm01 is the name of the virtual machine
              virtual_machine_name="webvm01"
              
              }
              ]
            }        
        app={
            subnet_address_prefix="10.1.1.0/24"
            network_interfaces=[{
              name="appinterface01"
              virtual_machine_name="appvm01"
              
              }]    
            }
            }
            }
        }