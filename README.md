# MonitorLinux

Para executa-lo precisa estar instalado o pacote "sysstat"
sudo apt-get install sysstat
ou
yum install sysstat
ou
rpm -ivh sysstat-10.0.0-1.i586.rpm
Exemplo de como executa-lo (Tem que ser root):
# bash calcIF.sh 
Interface Rede: eth0 wlan0 - Digita exatamente o nome da interface
Partição: /dev/sda5 - Digita exatamente o nome da partição que quer monitorar
Monitorar Processos: iceweasel - Digita exatamente o nome do processo, nota-se que a próxima linha mostrará o PID do processo.x
