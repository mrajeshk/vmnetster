import requests
import json

from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

vidmFQDN = "vidm.domain.local"
vidmUser = "admin"
vidmPass ="password"

userLogin   = "localuser01"
userNewPass   = "VMware321"


url = "https://{}/SAAS/API/1.0/REST/auth/system/login".format(vidmFQDN)
payload = '{{"username":"{}","password":"{}","issueToken":"true"}}'.format(vidmUser, vidmPass)
headers ={"accept":"application/json","Content-Type":"application/json"}

response = requests.request("POST", url, data=payload, headers=headers, verify=False)
session_token=response.json()['sessionToken']

url = "https://{}/SAAS/jersey/manager/api/scim/Users?filter=%20userName%20eq%20%22{}%22".format(vidmFQDN,userLogin)
headers = {
        'Authorization': 'Bearer '+session_token,
        'Content-Type': 'application/json',
        'accept': 'application/json'
    }

response = requests.request("GET", url, headers=headers, verify=False)
jsonObj=response.json()
userid=jsonObj['Resources'][0]['id']


url = "https://{}/SAAS/jersey/manager/api/scim/Users/{}".format(vidmFQDN,userid)
payload='{{"password":"{}"}}'.format(userNewPass)

response = requests.request("PATCH", url, data=payload, headers=headers, verify=False)
print(response)
