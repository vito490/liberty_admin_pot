######################
#  deployCollective.sh 
######################

/home/techzone/liberty_admin_pot/lab-scripts/createController.sh

/home/techzone/liberty_admin_pot/lab-scripts/setupDynamicRouting.sh

/home/techzone/liberty_admin_pot/lab-scripts/mavenBuild.sh -v 22.0.0.8

/home/techzone/liberty_admin_pot/lab-scripts/addMember.sh -n appServer1 -v 22.0.0.8 -p 9081:9441 -h server0.gym.lan SKIP_PROMPT

/home/techzone/liberty_admin_pot/lab-scripts/addMember.sh -n appServer2 -v 22.0.0.8 -p 9082:9442 -h server1.gym.lan SKIP_PROMPT