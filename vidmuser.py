import requests
import json

from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

vidmFQDN = "vidm.domain.local"
vidmUser = "admin"
vidmPass ="password"

userName   = "localuser01"
userPass   = "VMware123"
familyName = "localuser01"
givenName  = "loacluser01"
email = "localuser@domain.local"

jsonContents ="""{
  "emails": [
    {
      "value": "useremail"
    }
  ],
  "name": {
    "familyName": "userfamilyname",
    "givenName": "usergivenname"
  },
  "password": "userpassword",
  "schemas": [
    "urn:scim:schemas:core:1.0",
    "urn:scim:schemas:extension:workspace:1.0"
  ],
  "urn:scim:schemas:extension:workspace:1.0": {
    "domain": "System Domain"
  },
  "userName": "userid"
}"""

jsonContents = jsonContents.replace('useremail',email)
jsonContents = jsonContents.replace('userfamilyname',familyName)
jsonContents = jsonContents.replace('usergivenname',givenName)
jsonContents = jsonContents.replace('userpassword',userPass)
jsonContents = jsonContents.replace('userid',userName)

url = "https://{}/SAAS/API/1.0/REST/auth/system/login".format(vidmFQDN)
payload = '{{"username":"{}","password":"{}","issueToken":"true"}}'.format(vidmUser, vidmPass)
headers ={"accept":"application/json","Content-Type":"application/json"}

response = requests.request("POST", url, data=payload, headers=headers, verify=False)
session_token=response.json()['sessionToken']

url = "https://{}/SAAS/jersey/manager/api/scim/Users".format(vidmFQDN)
headers = {
        'Authorization': 'Bearer '+session_token,
        'Content-Type': 'application/json',
        'accept': 'application/json'
    }

jsonData = json.loads(jsonContents)
response = requests.request("POST", url, data=jsonContents, headers=headers, verify=False)

print(response.json())


