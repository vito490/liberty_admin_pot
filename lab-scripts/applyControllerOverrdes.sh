#########################
#  applyControllerOverrides.sh
#########################
numParms=$#
numOverrides=$numParms

echo "numOverrides $numOverrides"
# assign the arguets entered into a string for processing
str1=$@
#echo "str1" $str1


if [[ "$#" -lt 1 ]]; then
  echo "Missing command parameters, check usage"
  echo "---------------------------------------"
  echo "Usage:" 
  echo "Overrides: Instruct which overrides to apply" 
  echo "   specify 'ROUTING_RULES' for overriding routing rules"
  echo "   specify 'DUMMY' for overriding server for dummy testing"
  echo ""
  echo "example-local:  applyControllerOverrides.sh ROUTING_RULES"
  echo ""
   echo "---------------------------------------"
  exit 1
fi


#Lab environment variable
LAB_HOME=/home/techzone
WORK_DIR=$LAB_HOME/lab-work
LAB_FILES=$LAB_HOME/liberty_admin_pot
SCRIPT_ARTIFACTS=$LAB_FILES/lab-scripts/scriptArtifacts
LOGS=$WORK_DIR/logs
SAVE_COMMAND="applyControllerOverride.sh"


LIBERTY_ROOT=$WORK_DIR/liberty-staging
WLP_HOME="$LIBERTY_ROOT/$LIBERTY_VERSION-$SERVER_NAME/wlp"  #this needs to be the liberty home for the verion of Liberty unzipped

LOG=$LOGS/sessiondb-overrides-$LIBERTY_VERSION-$SERVER_NAME.log

#Controller variables
CONTROLLER_NAME="CollectiveController"
CONTROLLER_ROOT_DIR="$WORK_DIR/liberty-controller"
CONTROLLER_HTTPS_PORT=9491
CONTROLLER_HOSTNAME=`hostname`
CONTROLLER_WLP_HOME="$CONTROLLER_ROOT_DIR/wlp"


#Remote member variables
KNOWN_REMOTE_HOST1="server1.gym.lan"



echo "#----------------------------------" 
echo "# Now running applyControllerOverrides.sh" 
echo "#----------------------------------" 

sleep 5

process-overrides()
{
 
   if [ -d "$CONTROLLER_WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides" ]; then
       
      echo "# cp command: cp $OVERRIDE_FILE $CONTROLLER_WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides"

      cp $OVERRIDE_FILE $CONTROLLER_WLP_HOME/usr/servers/$CONTROLLER_NAME/configDropins/overrides
      rc=$?
    fi
    
  if [[ $rc = 0 ]]; then  
    echo ""
    echo "============================================================="
    echo ""
    echo "SUCCESS: Applying the $override_value overides file was successful."
    echo ""
    echo "============================================================="
    echo ""  
  else  
    echo ""
    echo "============================================================="
    echo ""
    echo "ERROR: Could not copy the $override_value overrides file to the server $CONTROLLER_NAME"
    echo ""
    echo "---> Verify the Controller exists."
    echo ""
    echo "============================================================="
    exit 1
  fi  

} 
#############
#Main PROGRAM 
#############


PROCESS_OVERRIDE=""

numRulesProcessed=0

# The overrides parrms begin at parameter 1, no flgas in this script.... 
for ((n=1; n<=$numParms; n++))
  do 
#get the nth paramter, starting at 1, which will be the override parms on the command
     override_value=`echo "$str1" | cut -d ' ' -f${n}`
      
#if overide parm is "ROUTING_RULES" then let it be know we found it      
     if [[ $override_value == "ROUTING_RULES" ]]; then
         PROCESS_OVERRIDE="ROUTING_RULES"
         echo "--------------------------"
         echo ""
         echo "Applying ROUTING_RULES override"
         echo ""
         echo "--------------------------"
         OVERRIDE_FILE=$SCRIPT_ARTIFACTS/dynamicRoutingRules.xml
         process-overrides
         numRulesProcessed=$((numRulesProcessed+1))
     fi      


#place holder for adding support of additinal overrides in the labs      
     if [[ $override_value == "DUMMY" ]]; then
         PROCESS_OVERRIDE="DUMMY"
         echo "--------------------------"
         echo ""
         echo "Applying DUMMY override"
         echo ""
         echo "--------------------------"
         OVERRIDE_FILE=$SCRIPT_ARTIFACTS/dummy.xml
         process-overrides
         numRulesProcessed=$((numRulesProcessed+1))
     fi      
  
done

unprocessedRules=$((numOverrides-numRulesProcessed ))

if [ $unprocessedRules -gt 0 ]; then
  
   echo "--------------------------"
   echo ""
   echo "There was '$unprocessedRules' unprocessed rule. Check your input paraamters on the script." 
   echo ""
   echo "The only valid command line options are: 'ROUTING_RULES'"
   echo ""
   echo "--------------------------"
fi




