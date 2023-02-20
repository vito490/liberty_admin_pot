LAB_FILES=/home/techzone/liberty_admin_pot
LOCAL_WLP_DIR="/home/techzone/lab-work/liberty-staging/22.0.0.8-appServer1/wlp"
REMOTE_WLP_DIR="/opt/IBM/liberty-staging/22.0.0.8-appServer2/wlp"

cp $LAB_FILES/httpSessionPersistence.xml $LOCAL_WLP_DIR//usr/servers/appServer1/configDropins/overrides/.
scp $LAB_FILES/httpSessionPersistence.xml techzone@server1.gym.lan:$REMOTE_WLP_DIR/usr/servers/appServer2/configDropins/overrides/.