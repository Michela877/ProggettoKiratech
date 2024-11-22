# Imposta il percorso della cartella per archiviare i file VHDX
$VHDPath = "C:\HyperV\VirtualHardDisks"

# Imposta il percorso della cartella per salvare i file di configurazione delle VM
$VMPath = "C:\HyperV\VirtualMachines"

# Percorso dell'immagine ISO (da impostare successivamente)
$ISOPath = "C:\Users\User\Downloads\CentOS-Stream-9-latest-x86_64-dvd1.iso"

# Verifica se il file ISO esiste
if (-not (Test-Path $ISOPath)) {
    Write-Host "Errore: Il file ISO non è stato trovato. Imposta il percorso corretto in \$ISOPath." -ForegroundColor Red
    exit
}

# Crea le cartelle se non esistono
New-Item -ItemType Directory -Force -Path $VHDPath
New-Item -ItemType Directory -Force -Path $VMPath

# Configurazione delle macchine virtuali
$VMs = @(
    @{
        Name = "controller.example.com"
        Memory = 3GB
        VCPU = 1
        DiskSize = 20GB
    },
    @{
        Name = "master.example.com"
        Memory = 4GB
        VCPU = 2
        DiskSize = 20GB
    },
    @{
        Name = "nodeone.example.com"
        Memory = 4GB
        VCPU = 1
        DiskSize = 20GB
    },
    @{
        Name = "nodetwo.example.com"
        Memory = 4GB
        VCPU = 1
        DiskSize = 20GB
    }
)

# Creazione delle macchine virtuali
foreach ($vm in $VMs) {
    $VMName = $vm.Name
    $Memory = $vm.Memory
    $VCPU = $vm.VCPU
    $DiskSize = $vm.DiskSize
    $VHDFile = Join-Path -Path $VHDPath -ChildPath "$VMName.vhdx"

    # Verifica se la macchina virtuale esiste già
    $existingVM = Get-VM -Name $VMName -ErrorAction SilentlyContinue
    if ($existingVM) {
        Write-Host "La macchina virtuale '$VMName' esiste già. Passo alla successiva." -ForegroundColor Yellow
        continue  # Salta alla macchina virtuale successiva
    }

    Write-Host "Creazione della macchina virtuale: $VMName"

    # Crea il disco virtuale
    New-VHD -Path $VHDFile -SizeBytes $DiskSize -Dynamic

    # Crea la macchina virtuale con Generazione 2
    New-VM -Name $VMName -MemoryStartupBytes $Memory -Generation 2 -Path $VMPath

    # Disabilita Secure Boot per consentire l'avvio dell'ISO non firmato
    Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

    # Configura la memoria dinamica
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 3GB -StartupBytes $Memory -MaximumBytes 4GB

    # Aggiungi CPU
    Set-VMProcessor -VMName $VMName -Count $VCPU

    # Collega il disco virtuale al primo controller SCSI (richiesto per Gen 2)
    Add-VMHardDiskDrive -VMName $VMName -Path $VHDFile

    # Collega una scheda di rete
    Add-VMNetworkAdapter -VMName $VMName -SwitchName "Default Switch"

    # Collega l'immagine ISO come dispositivo di avvio
    Add-VMDvdDrive -VMName $VMName -Path $ISOPath

    # Imposta il dispositivo di avvio al DVD per Generazione 2
    $dvdDrive = Get-VMDvdDrive -VMName $VMName | Select-Object -First 1
    Set-VMFirmware -VMName $VMName -FirstBootDevice $dvdDrive

    Write-Host "Macchina virtuale $VMName creata con successo."
}

# Avvio di tutte le macchine virtuali create
Write-Host "Verifica e avvio delle macchine virtuali..."
foreach ($vm in $VMs) {
    $VMName = $vm.Name
    $VMState = (Get-VM -Name $VMName).State

    if ($VMState -eq "Running") {
        Write-Host "La macchina virtuale '$VMName' è già in esecuzione. Nessuna azione necessaria." -ForegroundColor Green
    } else {
        Start-VM -Name $VMName -ErrorAction SilentlyContinue
        Write-Host "Macchina virtuale '$VMName' avviata con successo." -ForegroundColor Cyan
    }
}

Write-Host "Tutte le macchine virtuali sono state verificate/creato con successo."
