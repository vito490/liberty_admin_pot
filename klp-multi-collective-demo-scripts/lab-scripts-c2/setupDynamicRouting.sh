##########################
# setupDynamicRouting.sh
##########################

LAB_HOME=/home/techzone
LAB_FILES=/home/techzone/liberty_admin_pot
WORK_DIR="/home/techzone/lab-work"
#wlp home of controller
LIBERTY_ROOT_DIR=$WORK_DIR/liberty-controller
LIBERTY_ROOT_DIR2=$WORK_DIR/liberty-controller-c2
CONTROLLER_HTTPS_PORT="9491"
CONTROLLER_C2_HTTPS_PORT="9492" 
WLP_HOME=$LIBERTY_ROOT_DIR/wlp
WLP_HOME2=$LIBERTY_ROOT_DIR2/wlp
SCRIPTS_DIR=$LAB_FILES/lab-scripts
SCRIPTS_DIR2=$LAB_FILES/lab-scripts-c2
IHS_HOME=/opt/IBM/HTTPServer

PluginRoot=/opt/IBM/WebSphere/Plugins/

HOSTNAME=`hostname`
echo $HOSTNAME

## add DynamicRouting to collective 1
cp $SCRIPTS_DIR/scriptArtifacts/dynamicRouting.xml $WLP_HOME/usr/servers/CollectiveController/configDropins/overrides/.

## add DynamicRouting to collective 2
cp $SCRIPTS_DIR2/scriptArtifacts/dynamicRouting.xml $WLP_HOME2/usr/servers/CollectiveController-c2/configDropins/overrides/.

sleep 5
$IHS_HOME/bin/apachectl stop
if [ -e "$SCRIPTS_DIR2/plugin-cfg.xml" ]; then
     rm   $SCRIPTS_DIR2/plugin-cfg.xml ;
     echo "$SCRIPTS_DIR2/plugin-cfg.xml file removed"
fi
if [ -e "$SCRIPTS_DIR2/plugin-key.p12" ]; then
     rm   $SCRIPTS_DIR2/plugin-key.p12 ;
     echo "$SCRIPTS_DIR2/plugin-key.p12 file removed"
fi
if [ -e "$SCRIPTS_DIR2/plugin-key-CollectiveController.p12" ]; then
     rm   $SCRIPTS_DIR2/plugin-key-CollectiveController.p12 ;
     echo "$SCRIPTS_DIR2/plugin-key-CollectiveController.p12 file removed"
fi
if [ -e "$SCRIPTS_DIR2/plugin-key-CollectiveController-c2.p12" ]; then
     rm   $SCRIPTS_DIR2/plugin-key-CollectiveController-c2.p12 ;
     echo "$SCRIPTS_DIR2/plugin-key-CollectiveController-c2.p12 file removed"
fi
if [ -e "/tmp/plugin-cfg.xml" ]; then
     rm   /tmp/plugin-cfg.xml ;
     echo "/tmp/plugin-cfg.xml file removed"
fi
if [ -e "/tmp/plugin-key.p12" ]; then
     rm   /tmp/plugin-key.p12 ;
     echo "/tmp/plugin-key.p12 file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController.p12" ]; then
     rm   /tmp/plugin-key-CollectiveController.p12 ;
     echo "/tmp/plugin-key-CollectiveController.p12 file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController-c2.p12" ]; then
     rm   /tmp/plugin-key-CollectiveController-c2.p12 ;
     echo "/tmp/plugin-key-CollectiveController-c2.p12 file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController.kdb" ]; then
     rm   /tmp/plugin-key-CollectiveController.kdb ;
     echo "/tmp/plugin-key-CollectiveController.kdb file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController-c2.kdb" ]; then
     rm   /tmp/plugin-key-CollectiveController-c2.kdb ;
     echo "/tmp/plugin-key-CollectiveController-c2.kdb file removed"
fi
if [ -e "/tmp/plugin-key.kdb" ]; then
     rm   /tmp/plugin-key.kdb ;
     echo "/tmp/plugin-key.kdb file removed"
fi
if [ -e "/tmp/plugin-key.rdb" ]; then
     rm   /tmp/plugin-key.rdb ;
     echo "/tmp/plugin-key.rdb file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController.rdb" ]; then
     rm   /tmp/plugin-key-CollectiveController.rdb ;
     echo "/tmp/plugin-key-CollectiveController.rdb file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController-c2.rdb" ]; then
     rm   /tmp/plugin-key-CollectiveController-c2.rdb ;
     echo "/tmp/plugin-key-CollectiveController-c2.rdb file removed"
fi
if [ -e "/tmp/plugin-key.sth" ]; then
     rm   /tmp/plugin-key.sth ;
     echo "/tmp/plugin-key.sth file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController-c2.sth" ]; then
     rm   /tmp/plugin-key-CollectiveController-c2.sth ;
     echo "/tmp/plugin-key-CollectiveController-c2.sth file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController.sth" ]; then
     rm   /tmp/plugin-key-CollectiveController.sth ;
     echo "/tmp/plugin-key-CollectiveController.sth file removed"
fi

if [ -e "/tmp/plugin-key.crl" ]; then
     rm   /tmp/plugin-key.crl ;
     echo "/tmp/plugin-key.crl file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController-c2.crl" ]; then
     rm   /tmp/plugin-key-CollectiveController-c2.crl ;
     echo "/tmp/plugin-key-CollectiveController-c2.crl file removed"
fi
if [ -e "/tmp/plugin-key-CollectiveController.crl" ]; then
     rm   /tmp/plugin-key-CollectiveController.crl ;
     echo "/tmp/plugin-key-CollectiveController.crl file removed"
fi


echo ""
echo "----------------------------------------------------------------------------------------------" 
echo "AutoAcceptCertificates enabled for connection to controller  (secure connection to Controller)" 
echo "----------------------------------------------------------------------------------------------" 
echo "" 

sleep 2

# $WLP_HOME/bin/dynamicRouting setup --port=$CONTROLLER_HTTPS_PORT --host=$HOSTNAME --user=admin --password=admin --keystorePassword=webAS --pluginInstallRoot=$PluginRoot --webServerNames=webserver1 --autoAcceptCertificates



### Setup dynamic routing to apps in multiple collectives 
$WLP_HOME2/bin/dynamicRouting setup --collectives=admin:admin@$HOSTNAME:$CONTROLLER_HTTPS_PORT,admin:admin@$HOSTNAME:$CONTROLLER_C2_HTTPS_PORT --keystorePassword=webAS --pluginInstallRoot=$PluginRoot --webServerNames=webserver1 --autoAcceptCertificates


sleep 2
echo "dynamicRouting setup completed"

cp plugin-cfg.xml /tmp/.
cp plugin-key.p12 /tmp/.

### For multi collective configuration
cp plugin-key-CollectiveController.p12 /tmp/.
cp plugin-key-CollectiveController-c2.p12 /tmp/.
sleep 2

### Convert keyfile for plugin-key.p12
#$IHS_HOME/bin/gskcapicmd -keydb -convert -pw webAS -db /tmp/plugin-key.p12 -old_format pkcs12 -target /tmp/plugin-key.kdb -new_format cms -stash 


### Convert keyfile for collective 1
$IHS_HOME/bin/gskcapicmd -keydb -convert -pw webAS -db /tmp/plugin-key-CollectiveController.p12 -old_format pkcs12 -target /tmp/plugin-key-CollectiveController.kdb -new_format cms -stash 

sleep 2 

### Convert keyfile for collective 2
$IHS_HOME/bin/gskcapicmd -keydb -convert -pw webAS -db /tmp/plugin-key-CollectiveController-c2.p12 -old_format pkcs12 -target /tmp/plugin-key-CollectiveController-c2.kdb -new_format cms -stash 


sleep 2
echo "gskcmd convert completed"

### for plugin-key.p12
#$IHS_HOME/bin/gskcapicmd -cert -setdefault -pw webAS -db /tmp/plugin-key.kdb -label default

sleep 2
### for controller 1
$IHS_HOME/bin/gskcapicmd -cert -setdefault -pw webAS -db /tmp/plugin-key-CollectiveController.kdb -label default

sleep 2 
### for controller 2
$IHS_HOME/bin/gskcapicmd -cert -setdefault -pw webAS -db /tmp/plugin-key-CollectiveController-c2.kdb -label default



sleep 2
echo "gskcmd cert completed"

cp /tmp/plugin-key-CollectiveController.kdb  /opt/IBM/WebSphere/Plugins/config/webserver1/.
cp /tmp/plugin-key-CollectiveController-c2.kdb /opt/IBM/WebSphere/Plugins/config/webserver1/.

#cp /tmp/plugin-key.rdb  /opt/IBM/WebSphere/Plugins/config/webserver1/.
cp /tmp/plugin-key-CollectiveController.rdb /opt/IBM/WebSphere/Plugins/config/webserver1/.
cp /tmp/plugin-key-CollectiveController.rdb /opt/IBM/WebSphere/Plugins/config/webserver1/.

cp /tmp/plugin-key-CollectiveController.sth /opt/IBM/WebSphere/Plugins/config/webserver1/.
cp /tmp/plugin-key-CollectiveController-c2.sth /opt/IBM/WebSphere/Plugins/config/webserver1/.

cp /tmp/plugin-cfg.xml /opt/IBM/WebSphere/Plugins/config/webserver1/.
sleep 2


#Start HIS server
$IHS_HOME/bin/apachectl stop
sleep 2
$IHS_HOME/bin/apachectl start

sleep 2
