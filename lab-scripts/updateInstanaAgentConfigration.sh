sudo systemctl stop instana-agent
sleep 5
sudo cp -f /home/techzone/liberty_admin_pot/lab-scripts/scriptArtifacts/instana-configuration.yaml /opt/instana/agent/etc/instana/configuration.yaml
sleep 5
sudo systemctl start instana-agent