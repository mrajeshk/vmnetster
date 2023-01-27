#!/bin/bash

nsxfqdnPrimary="site-a-nsx.domain.local"
nsxfqdnSecondary="site-b-nsx.domain.local"
certFileA="/home/admin/scriptuser.pem"
certFileB="/home/admin/scriptuser.pem"
lbAt1="T1-LB"
lbBt1="T1-LB"
lbA="Application-LB"
lbB="Application-LB"
staticroute="Application-LB-Route"
serviceint="application-Service-Interface"


echo "------------------------- Disable LB in Primary Site A -------------------------------------------------"

echo "------------------------- Current static route configuration in primary site -------------------------------------------------"

curl --cert $certFileA -k -X GET https://$nsxfqdnPrimary/policy/api/v1/infra/tier-1s/$lbAt1/static-routes

echo "------------------------- Delete static route in primary site -------------------------------------------------"


curl --cert $certFileA -k -X DELETE https://$nsxfqdnPrimary/policy/api/v1/infra/tier-1s/$lbAt1/static-routes/$staticroute

sleep 5

echo "------------------------- LB service is attached with T1 in primary site -------------------------------------------------"


curl --cert $certFileA -k -X GET https://$nsxfqdnPrimary/policy/api/v1/infra/lb-services/$lbA

echo "------------------------- LB service is detach from primary site T1 -------------------------------------------------"

curl --cert $certFileA -k -X PATCH "https://$nsxfqdnPrimary/policy/api/v1/infra/lb-services/$lbA" -H "content-type: application/json" -d @/home/admin/detachLB.json

sleep 5

echo "------------------------- Service Interface in primary site -------------------------------------------------"


curl --cert $certFileA -k -X GET https://$nsxfqdnPrimary/policy/api/v1/infra/tier-1s/$lbAt1/locale-services/default/interfaces/$serviceint

echo "------------------------- Delete Service Interface in primary site -------------------------------------------------"


curl --cert $certFileA -k -X DELETE "https://$nsxfqdnPrimary/policy/api/v1/infra/tier-1s/$lbAt1/locale-services/default/interfaces/$serviceint"

sleep 5

echo "-------------------------Enable LB in Recovery Site B-------------------------------------------------"


echo "------------------------- Create static route in secondary site site -------------------------------------------------"

curl --cert $certFileB -k -X PATCH "https://$nsxfqdnSecondary/policy/api/v1/infra/tier-1s/$lbBt1/static-routes/$staticroute" -H "content-type: application/json" -d @/home/admin/staticroute.json
sleep 5
curl --cert $certFileB -k -X GET "https://$nsxfqdnSecondary/policy/api/v1/infra/tier-1s/$lbBt1/static-routes"

echo "------------------------- Create service interface in secondary site site -------------------------------------------------"

curl --cert $certFileB -k -X PATCH "https://$nsxfqdnSecondary/policy/api/v1/infra/tier-1s/$lbBt1/locale-services/default/interfaces/$serviceint" -H "content-type: application/json" -d @/home/admin/serviceinterface.json
sleep 5
curl --cert $certFileB -k -X GET "https://$nsxfqdnSecondary/policy/api/v1/infra/tier-1s/$lbBt1/locale-services/default/interfaces/$serviceint"

echo "------------------------- Attach LB service in secondary site with T1 -------------------------------------------------"


curl --cert $certFileB -k -X PATCH "https://$nsxfqdnSecondary/policy/api/v1/infra/lb-services/$lbB" -H "content-type: application/json" -d @/home/admin/attacheLB.json
sleep 5
curl --cert $certFileB -k -X GET "https://$nsxfqdnSecondary/policy/api/v1/infra/lb-services/$lbB"

