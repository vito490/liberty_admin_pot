#!/bin/bash -i
#####################
# deleteRemoteMember.sh
#####################
# This script runs on the REMOTE Liberty HOST. 
# It is invoked from the deleteMember.sh from the CONTROLLER HOST
# The useage is: 
# deleteRemoteMember.sh <Liberty_Server_Name> <Controller_HTTPS_Port> 
# Example: deleteRemoteMember.sh testServer 9493

if [[ "$#" -lt 2 ]]; then
  echo "Missing command parameters, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "   deleteRemoteMember.sh <LibertyServerName> <ControllerHTTPSPort>"
  echo ""
  echo "example: deleteRemoteMember.sh testServer 9493"
  echo ""
  echo "---------------------------------------"
  return 1
fi

LAB_HOME=/home/techzone
LOGS=/home/techzone
LOG=$LOGS/4_deleteRemoteMember.log
HOSTNAME=`hostname`

echo "#--------------------------------------------------------" | tee $LOG
echo "# Now running deleteRemoteMember.sh on host $HOSTNAME" | tee -a $LOG
echo "#--------------------------------------------------------" | tee -a $LOG

sleep 5

WLP_ROOT_DIR=/opt/IBM

WLP_HOME=/opt/IBM/wlp

CONTROLLER_HOST=server0.gym.lan

CONTROLLER_HTTPS_PORT=$2

LIBERTY_SERVER=$1

echo "" | tee -a  $LOG
echo "#-------------------------------------------------------------" | tee -a  $LOG
echo "Liberty Server to remove from the collective is: $LIBERTY_SERVER" | tee -a $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG
echo "" | tee -a  $LOG
echo "# List variables used in the script" | tee -a  $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG
echo "# Host is: `hostname`" | tee -a $LOG
echo "# Liberty Server: $LIBERTY_SERVER" | tee -a  $LOG
echo "# Liberty Home: $WLP_HOME" | tee -a  $LOG
echo "# Controller Host: $CONTROLLER_HOST" | tee -a  $LOG
echo "# Controller HTTPS Port: $CONTROLLER_HTTPS_PORT" | tee -a  $LOG
echo "#-------------------------------------------------------------" | tee -a $LOG

cd /home/techzone
echo "curent directory is" `pwd` 
echo "-------------------------------------------------------"

#check status of the server and verify it exists locally, and if its running. 
#rc=0: Server is running
#rc=1: Server not running
#rc=2: Server does not exist
#rc>2 bad errors!

  echo "" | tee -a $LOG
  echo "# See if the server exists and is it running on $HOSTNAME" | tee -a $LOG
  echo "$WLP_HOME/bin/server status $LIBERTY_SERVER"| tee -a $LOG
  echo "" | tee -a $LOG
 
  $WLP_HOME/bin/server status $LIBERTY_SERVER
  rc=$?
  echo "rc = $rc" 
  
  if [[ "$rc" > "2" ]]; then 
     echo "#ERROR! Could not verify Liberty Server $LIBERTY_SERVER on $HOSTNAME." | tee -a $LOG
     echo "# See error massages!" | tee -a $LOG
     exit $rc
  fi
  
  if [[ "$rc" = "2" ]]; then 
     echo "#ERROR! Server $LIBERTY_SERVER does not exist on $HOSTNAME." | tee -a $LOG
     echo "Verify the input paramters and that you are tryng to remove the member from the correct HOST" | tee -a $LOG
     echo "Exiting with return code $rc from 'server status' command" | tee -a $LOG
     exit 2
  else 
  #Stop the Liberty server on remote host
     echo "" | tee -a $LOG
     echo "# Stop the local Liberty Server member" | tee -a $LOG
     echo "$WLP_HOME/bin/server stop $LIBERTY_SERVER" | tee -a $LOG
     echo "" | tee -a $LOG
 
     $WLP_HOME/bin/server stop $LIBERTY_SERVER
  
     echo " " 
     echo "Server $LIBERTY_SERVER has been stopped."
     echo " " 
  fi   



#remove the Librty server from the collective

  echo "" | tee -a $LOG
  echo "# Remove the member from  the collecive...." | tee -a $LOG
  echo "$WLP_HOME/bin/collective remove $LIBERTY_SERVER --host=$CONTROLLER_HOST --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin"  | tee -a $LOG
  echo "" | tee -a $LOG
  
  
  echo "------------------------------------------------------" 
  echo "Reply 'y' when prompted to accept the certificate chain" 
  echo "------------------------------------------------------" 
  sleep 10
  
  $WLP_HOME/bin/collective remove $LIBERTY_SERVER --host=$CONTROLLER_HOST --port=$CONTROLLER_HTTPS_PORT --user=admin --password=admin

   if [[ $? != 0 ]]; then
     echo "#ERROR Failed to remove $LIBERTY_SERVER from the collective. See the error message that was returned!" | tee -a $LOG
     exit 1
  else 
    echo "# Liberty Server $LIBERTY_SERVER was removed from the collective" | tee -a $LOG
    echo "" | tee -a $LOG
    
# remove the  Liberty server directory.  
    
    if [ -d "$WLP_HOME/usr/servers/$LIBERTY_SERVER" ]; then
      echo "" | tee -a $LOG
      echo "# Delete the server directory"  | tee -a $LOG
      echo "# rm -rf $WLP_HOME/usr/servers/$LIBERTY_SERVER" | tee -a $LOG
      echo "" | tee -a $LOG
    
      rm -rf $WLP_HOME/usr/servers/$LIBERTY_SERVER
   
      echo "$WLP_HOME/usr/servers/$LIBERTY_SERVER directory has been removed"  
    fi  
  fi 


echo "End of removeRemoteMember.sh script." | tee -a $LOG




