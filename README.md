#Automazione
Questo repository eseguirà il provisioning di un cluster Kubernetes composto da un nodo manager, un nodo master e due nodi worker per il deployment di un'applicazione.

#GitLab Runner su Windows (Configurazione Manuale)
Il primo passo consiste nel configurare il GitLab Runner sul sistema operativo desiderato. Assicurati che siano abilitati e installati Hyper-V e Docker, in modo da poter eseguire lo script che creerà le VM necessarie.

#Powershell Automatizzato
Nel secondo passo, utilizzando la cartella di Powershell, verranno create localmente tramite Hyper-V quattro macchine virtuali con tutte le configurazioni richieste.

Nota: Per automatizzare ulteriormente il processo, è possibile utilizzare un file ISO modificato (ad esempio con indirizzi IP statici), oppure optare per un provider cloud.

#Configurazione di Hyper-V con un ISO non modificato
Nel terzo passo, dovrai attendere che tutte le VM siano avviate. Una volta avviate, configura gli indirizzi IP statici e una password di root per ciascuna VM. Ecco un esempio di configurazione:

Nome	                Indirizzo IP	Gateway	        DNS
controller.example.com	172.31.177.10	172.31.176.1	172.31.176.1
master.example.com	172.31.177.20	172.31.176.1	172.31.176.1
nodeone.example.com	172.31.177.30	172.31.176.1	172.31.176.1
nodetwo.example.com	172.31.177.40	172.31.176.1	172.31.176.1

Comandi per configurare manualmente su sistema Linux:
sudo nano /etc/NetworkManager/system-connections/eth1.nmconnection
sudo systemctl restart NetworkManager
cat /etc/resolv.conf

#GitLab Runner su CentOS 9 (Configurazione Manuale)
Nel quarto passo, una volta configurati gli indirizzi IP sulle VM, è necessario installare il GitLab Runner su controller.example.com. Successivamente, bisogna installare git (altrimenti la pipeline non funzionerà) e concedere tutte le autorizzazioni sudo con i seguenti comandi:

yum install git
sudo visudo

Aggiungi la seguente riga al file /etc/sudoers:

gitlab-runner ALL=(ALL) NOPASSWD: ALL
Con questo, il processo sarà completamente automatizzato.

Nota: Se i runner vengono cancellati, dovrai aggiornare il percorso del nuovo runner nelle variabili, altrimenti la pipeline non funzionerà correttamente.

#Pipeline
Una volta avviata, la pipeline procederà a installare le VM. Se le VM sono già state installate, la pipeline effettuerà un controllo e passerà alla fase successiva.

Successivamente, la pipeline costruirà l'immagine Docker utilizzando i file presenti nel repository del GitLab Runner Windows. L'immagine verrà buildata localmente e successivamente caricata su Docker Hub (docker push).

Le VM verranno collegate configurando il file /etc/hosts su tutte le macchine per consentire loro di comunicare tra loro. Sarà generato un ssh-keygen sull'utente gitlab, e la sua chiave pubblica verrà distribuita su tutte le VM, consentendo una connessione SSH senza password. Inoltre, verrà configurato un file di configurazione in modo che l'utente si connetta alle VM come root.

Successivamente, si avvierà la fase di Ansible, che installerà tutte le dipendenze necessarie: kubectl, kubelet, kubeadm, docker, containerd.io, flannel, e altre necessarie per configurare e collegare tutti i nodi in un cluster Kubernetes. Inoltre, verrà installato e avviato kube-bench per verificare la sicurezza del cluster, visualizzando i risultati nei log di GitLab. Questo processo si alterna tra vari file di configurazione, come k8s.pkg, kws.master, k8s.workers.

Infine, l'applicazione verrà distribuita tramite Ansible utilizzando il file k8s.deployment, che recupererà le configurazioni dell'applicativo contenute nel repository del GitLab Runner. Creerà un namespace chiamato kyratech-prova e all'interno installerà i pod per l'applicazione Flask e il database MySQL, che saranno gestiti dal cluster Kubernetes.


