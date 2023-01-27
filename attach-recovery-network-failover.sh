#!/bin/bash

nsxtFqdn="site-a-nsxt-manager"
certFile="/home/admin/scriptuser.pem"
t1path="infra/tier-1s/T1-GW-Recover-NW"
t0path="global-infra/tier-0s/Stretched-T0"
logfile="/home/admin/script.log"
recovery_plan="recovery-with-custom-script"

currentDate=`date +"%Y-%m-%d %T"`

echo "$currentDate custome script" >> $logfile

if [ $VMware_RecoveryMode == 'recovery' ] && [ $VMware_RecoveryName == $recovery_plan ]
then
    currentDate=`date +"%Y-%m-%d %T"`
    echo "$currentDate Recovery Plan $VMware_RecoveryName running" >> $logfile
    sleep 2
    revisionNum=$(curl -k -s --cert $certFile \
               -X GET https://$nsxtFqdn/policy/api/v1/$t1path \
               | grep "_revision" | awk '{print $3}' | cut -d '"' -f 2)
    currentDate=`date +"%Y-%m-%d %T"`
    echo "Revision Numbar $revisionNum " >> $logfile

    currentDate=`date +"%Y-%m-%d %T"`
    echo "$currentDate Attach $t0path to $t1path" >> $logfile
    curl -k -s --cert $certFile -X PATCH https://$nsxtFqdn/policy/api/v1/$t1path \
    -H "Content-Type: application/json" \
    -d "{\"tier0_path\":"\"/$t0path"\",\"_revision\":$revisionNum}"

else
    currentDate=`date +"%Y-%m-%d %T"`
    echo "$currentDate Test $VMware_RecoveryName recovery" >> $logfile
fi