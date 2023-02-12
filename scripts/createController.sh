######################
#  createController.sh
######################
LAB_HOME=/home/techzone
LAB_FILES=/home/techzone/liberty_admin_pot
LOGS=$LAB_FILES/logs
LOG=$LOGS/0_createController.log
SCRIPT_ARTIFACTS=$LAB_FILES/scripts/scriptArtifacts
WLP_HOME=$LAB_HOME/wlp


HOSTNAME=`hostname`
echo $HOSTNAME

CONTROLLER_NAME="adminCenterController"
HTTP_PORT="9090"
HTTPS_PORT="9493"


if [ -d "$LOGS" ]; then
     rm -rf $LOGS ;
     echo "remove the logs directory, if it exists: $LOG"
fi 

if [ ! -d "$LOGS" ]; then
     mkdir $LOGS ;
     echo "Create Logs Directory: $LOGS"
fi


echo "#----------------------------------" | tee $LOG
echo "# Now running createController.sh" | tee -a $LOG
echo "#----------------------------------" | tee -a $LOG


echo "" | tee -a $LOG
echo "# Variables used in the script" | tee -a $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG
echo "# Lab Home: $LAB_HOME" | tee -a $LOG
echo "# Lab Files Directory: $LAB_FILES" | tee -a $LOG
echo "# Liberty Home directory: $WLP_HOME" | tee -a $LOG
echo "# Controller Hostname: $HOSTNAME" | tee -a $LOG
echo "# Name of Controller server: $CONTROLLER_NAME" | tee -a $LOG
echo "# Controller HTTP Port: $HTTP_PORT" | tee -a $LOG
echo "# Controller HTTPS Port: $HTTPS_PORT" | tee -a $LOG
echo "#--------------------------------------------------------------" | tee -a $LOG
echo "" | tee -a $LOG

sleep 7

#Stop the Liberty Controller server, if it is running
echo "" | tee -a $LOG
echo "# stop the Liberty Controller, if it is running" | tee -a $LOG
echo "$WLP_HOME/bin/server stop $CONTROLLER_NAME" | tee -a $LOG
echo "" | tee -a $LOG
echo "" | tee -a $LOG

if [ -d "$WLP_HOME/usr/servers/$CONTROLLER_NAME" ]; then
  $WLP_HOME/bin/server stop $CONTROLLER_NAME ;
  echo "$CONTROLLER_NAME stopped" 
  sleep 5

#Cleanup the Liberty Server directory  
  echo "" | tee -a $LOG
  echo "# Ensure the Liberty server directory is clean" | tee -a $LOG
  echo "rm -rf $WLP_HOME/usr/servers/$CONTROLLER_NAME" | tee -a $LOG
  echo "rm -rf $WLP_HOME/usr/servers/*" | tee -a $LOG
  echo "" | tee -a $LOG
  
  rm -rf $WLP_HOME/usr/servers/$CONTROLLER_NAME ;
  rm -rf $WLP_HOME/usr/servers/* ;
  echo "controller $CONTROLLER_NAME removed" 
  echo "" | tee -a $LOG
  echo "$CONTROLLER_NAME directory structure removed" 
  sleep 5
fi

#Cleanup the packagedServer directory
echo "" | tee -a $LOG
echo "# Remove $LAB_FILES/packagedServers directory, if it exists" | tee -a $LOG
echo "rm -rf  $LAB_FILES/packagedServers" | tee -a $LOG
echo "" | tee -a $LOG

if [ -d "$LAB_FILES/packagedServers" ]; then
     rm -rf  $LAB_FILES/packagedServers ;
     echo "$LAB_FILES/packagedServers directory removed" 
fi

#Create the collective controller server
echo "" | tee -a $LOG
echo "# create the $CONTROLLER_MAME Liberty server" | tee -a $LOG
echo "$WLP_HOME/bin/server create $CONTROLLER_NAME" | tee -a $LOG
echo "" | tee -a $LOG

$WLP_HOME/bin/server create $CONTROLLER_NAME

 if [[ $? != 0 ]]; then
   echo "Failed to create the Liberty Server: $CONTROLLER_NAME. See the error message that was returned!"
   exit $?
  fi 

echo "Controller $CONTROLLER_NAME created" 


#Create the collective
echo "" | tee -a $LOG
echo "# create the Liberty Collective" | tee -a $LOG
echo "$WLP_HOME/bin/collective create $CONTROLLER_NAME --keystorePassword=passw0rd --createConfigfile=$WLP_HOME/usr/servers/$CONTROLLER_NAME/controller.xml" | tee -a $LOG
echo "" | tee -a $LOG

$WLP_HOME/bin/collective create $CONTROLLER_NAME --keystorePassword=passw0rd --createConfigfile=$WLP_HOME/usr/servers/$CONTROLLER_NAME/controller.xml

if [[ $? != 0 ]]; then
   echo "Failed to create the Liberty Collective: See the error message that was returned!"
   exit $?
  fi 

echo "" 
echo "Collective created.." 
echo "" 
echo "controller.xml generated in $WLP_HOME/usr/servers/$CONTROLLER_NAME" 
echo ""


#Create the configDropins/overrides directory
echo "" | tee -a $LOG
echo "# create the configDropins/overrides directory" | tee -a $LOG
echo "mkdir $WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins" | tee -a $LOG
echo "mkdir /$WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides" | tee -a $LOG
echo "" | tee -a $LOG

mkdir $WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins 
mkdir /$WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides 
echo "" 

echo "$WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides directory created" 
echo "" 

#Copy the controllerOverride.xml into the configDropins/overrides directory
echo "" | tee -a $LOG
echo "# copy the controllerOverride.xml file to the configDropis/overrides directory" | tee -a $LOG
echo "cp $SCRIPT_ARTIFACTS/controllerOverride.xml $WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides" | tee -a $LOG
echo "" | tee -a $LOG


cp $SCRIPT_ARTIFACTS/controllerOverride.xml $WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides

echo "$SCRIPT_ARTIFACTS/controllerOverride.xml copied to $WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides" 


#Start the Liberty Collective Controller server
echo "" | tee -a $LOG
echo "# Start the Controller $CONTROLLER_NAME" | tee -a $LOG
echo "$WLP_HOME/bin/server start $CONTROLLER_NAME" | tee -a $LOG
echo "" | tee -a $LOG


$WLP_HOME/bin/server start $CONTROLLER_NAME

sleep 5

if [[ $? != 0 ]]; then
   echo "The Liberty Controller server $CONTROLLER_NAME failed to start: See the error message that was returned!"
   exit $?
  fi 
  
echo "$CONTROLLER_NAME server started successfully." 
echo ""

#Create the $LAB_FILES/packagedServers directory

echo "" | tee -a $LOG
echo "# Create the $LAB_FILES/packagedServers directory" | tee -a $LOG
echo "mkdir $LAB_FILES/packagedServers" | tee -a $LOG
echo "" | tee -a $LOG

#Create the packagedServers directory
mkdir $LAB_FILES/packagedServers
echo "$LAB_FILES/packagedServers directory created" 
echo "" 


#print location of log files 
 
echo "" 
echo "---------------------------------------------------"
echo "The log files can be found in: $LOGS"
echo "ls -l $LOGS"
echo "---------------------------------------------------"
echo ""  


#Print the URL of the Liberty Admin Center
echo "# --> Admin Center URL: https://server0.gym.lan:$HTTPS_PORT/adminCenter" | tee -a $LOG

echo "" | tee -a $LOG
echo "# End of createColntroller.sh script." | tee -a $LOG
echo "" | tee -a $LOG
