output "virtual_machine_details" {
    value = {
        for machine in azurerm_linux_virtual_machine.virtualmachines :
        //machine.name is used as key to match the for_each key
        machine.name => {
            //virtual_machine_id will return the id of each virtual machine created
            virtual_machine_id = machine.id
           
        }
    }
}