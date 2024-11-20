import json

# Percorso del file output generato da Terraform
terraform_output_file = "terraform_output.json"
inventory_file = "inventory"

# Legge il file JSON
with open(terraform_output_file, "r") as f:
    terraform_output = json.load(f)

# Recupera gli IP delle macchine virtuali
vm_ips = terraform_output.get("vm_ips", {}).get("value", {})

# Scrive l'inventario Ansible
with open(inventory_file, "w") as f:
    f.write("[controller]\n")
    f.write(f"controller.example.com ansible_host={vm_ips['controller']}\n\n")
    
    f.write("[master]\n")
    f.write(f"master.example.com ansible_host={vm_ips['master']}\n\n")
    
    f.write("[nodes]\n")
    f.write(f"nodeone.example.com ansible_host={vm_ips['nodeone']}\n")
    f.write(f"nodetwo.example.com ansible_host={vm_ips['nodetwo']}\n\n")
    
    f.write("[all:vars]\n")
    f.write("ansible_user=root\n")
    f.write("ansible_ssh_private_key_file=~/.ssh/id_rsa\n")
