param(
    [string]$VMName,
    [string]$Hostname,
    [int]$CPUCount,
    [int]$MemoryMB,
    [int]$DiskSizeGB,
    [string]$ISOPath
)

# Percorso della directory di Hyper-V
$VMPath = "C:\HyperV\$VMName"

# Creazione della VM
Write-Host "Creating VM: $VMName"
New-VM -Name $VMName -MemoryStartupBytes ($MemoryMB * 1MB) -BootDevice CD -Path $VMPath -Generation 2

# Configurazione del numero di CPU
Set-VM -VMName $VMName -ProcessorCount $CPUCount

# Configurazione del disco virtuale
$VHDPath = "$VMPath\$VMName.vhdx"
New-VHD -Path $VHDPath -SizeBytes ($DiskSizeGB * 1GB) -Dynamic
Add-VMHardDiskDrive -VMName $VMName -Path $VHDPath

# Configurazione della rete
Connect-VMNetworkAdapter -VMName $VMName -SwitchName "Default Switch"

# Configurazione dell'ISO
Set-VMDvdDrive -VMName $VMName -Path $ISOPath

# Avvia la VM
Start-VM -Name $VMName

Write-Host "VM $VMName created and started successfully."
