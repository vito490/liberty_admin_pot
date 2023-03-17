######################
#  deployCollective.sh 
######################

numParms=$#
PARM1=$1
#echo "PARM1: $PARM1"

SKIP_1030="false"

if [[ ! -z "$PARM1" ]]; then
 # echo "parameter specified, need to see if it matches --skip1030"

  if [[ "$PARM1" = "--skip1030" ]]; then 
     SKIP_1030="true"
     echo ""
     echo "================================================="
     echo "---> Script will skip setting up dynamic routing!"
     echo "================================================="
     echo ""
     sleep 3 
  fi  
fi

#echo "skip1030: $SKIP_1030"


echo ""
echo "============================="
echo "Create the Liberty Collective"
echo "============================="
echo ""
sleep 3

/home/techzone/liberty_admin_pot/lab-scripts/createController.sh

if [[ $SKIP_1030 != "true" ]]; then  
  echo ""
  echo "============================="
  echo "Setup Dynamic Routing"
  echo "============================="
  echo ""
  sleep 3
  
  /home/techzone/liberty_admin_pot/lab-scripts/setupDynamicRouting.sh
fi 

echo ""
echo "========================================"
echo "Build and produce Liberty Server Package"
echo "========================================"
echo ""
sleep 3

/home/techzone/liberty_admin_pot/lab-scripts/mavenBuild.sh -v 22.0.0.8



echo ""
echo "========================================"
echo "Deploy apServer1"
echo "========================================"
echo ""
sleep 3

/home/techzone/liberty_admin_pot/lab-scripts/addMember.sh -n appServer1 -v 22.0.0.8 -p 9081:9441 -h server0.gym.lan SKIP_PROMPT


echo ""
echo "========================================"
echo "Deploy appServer2"
echo "========================================"
echo ""
sleep 3

/home/techzone/liberty_admin_pot/lab-scripts/addMember.sh -n appServer2 -v 22.0.0.8 -p 9082:9442 -h server1.gym.lan SKIP_PROMPT


echo ""
echo "========================================"
echo "Liberty Collective Deployment Complete! "
echo "========================================"
echo ""

