sed -i '1iINSTANA_SERVICE_NAME=appServer1' /home/techzone/lab-work/liberty-staging/22.0.0.8-appServer1/wlp/usr/servers/appServer1/server.env
​
sshpass -p "IBMDem0s!" ssh server1.gym.lan 'sed -i "1iINSTANA_SERVICE_NAME=appServer2" /opt/IBM/liberty-staging/22.0.0.8-appServer2/wlp/usr/servers/appServer2/server.env'