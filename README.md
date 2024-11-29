#Automazione





Questo repository eseguirà il provisioning di un cluster Kubernetes composto da un nodo manager, un nodo master e due nodi worker per il deployment di un'applicazione.


**Nota: ho utilizzato Hyper-v perche essendo gia nei file di sistema di windows la configurazione tramite shell è diretta e piu semplice rispetto ad altri rivali inoltre non ho usato terraform per un semplice fatto che richiedeva il collegamento a file non verificati come hashicorp e per questioni di sicurezza ho utilizzato uno script powershell. inoltre per quanto riguarda il benchmark di security ho selezionato kube bench essendo il piu generico utilizzato per fare i test sulla sicurezza. Per quanto riguarda helm essendo un equivalente della comandlet kubectl per deployare piu facilmente attraverso i pacchetti chars senza usare troppi comandi sono rimasto con la comandlet di kubectl essendo riuscito a fare la stessa identica cosa. per quanto riguarda l'applicativo ho utilizzato un mio applicativo creato da me che utilizza 3 servizi il primo l'applicativo web il secondo il server mysql e il terzo una simulazione di esame sempre tramite web **



#GitLab Runner su Windows (Configurazione Manuale)





Il primo passo consiste nel configurare il GitLab Runner sul sistema operativo desiderato. Assicurati che siano abilitati e installati Hyper-V e Docker, in modo da poter eseguire lo script che creerà le VM necessarie.







#Powershell Automatizzato




Nel secondo passo, utilizzando la cartella di Powershell, verranno create localmente tramite Hyper-V quattro macchine virtuali con tutte le configurazioni richieste.

Nota: Per automatizzare ulteriormente il processo, è possibile utilizzare un file ISO modificato (ad esempio con indirizzi IP statici), oppure optare per un provider cloud.





#Configurazione di Hyper-V con un ISO non modificato






Nel terzo passo, dovrai attendere che tutte le VM siano avviate. Una volta avviate, configura gli indirizzi IP statici e una password di root per ciascuna VM. Ecco un esempio di configurazione:

Nome	                Indirizzo IP	Gateway	        DNS
controller.example.com	192.168.178.131	192.168.178.1	192.168.178.1
master.example.com	192.168.178.132	192.168.178.1	192.168.178.1
nodeone.example.com	192.168.178.133	192.168.178.1	192.168.178.1
nodetwo.example.com	192.168.178.134	192.168.178.1	192.168.178.1

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


#variabili

ANSIBLE_INVENTORY: inserire il path hosts per configurare kubernates in questo caso il hosts della cartella ansible finale /hosts
ANSIBLE_PLAYBOOK_PATH: inserire il path della cartella ansible e basta
POWERSHELL_SCRIPT_PATH: path della cartella powershell con finale /vmhyperv.ps1
SSH_CONFIG_PATH: configurazione ssh dell' utente gitlab /home/gitlab-runner/.ssh/config
SSH_KEY_PATH: configurazione ssh dell'utente gitlab chiave pubblica /home/gitlab-runner/.ssh/id_rsa
SSH_PASS: password delle macchine virutali

DOCKERFILE_PATH: "./path/to/Dockerfile"          # Percorso del Dockerfile
BUILD_CONTEXT: "./path/to/build-context/logingestionele"         # Percorso della build context
DOCKER_IMAGE: "usernameDockerhub/repository-name"         # Nome dell'immagine Docker
DOCKER_PASSWORD
DOCKER_USERNAME



docker build -t username/logingestionele:latest -f ./pathassolutodockerfile/Dockerfile ./pathassolutodirectory/logingestionale

