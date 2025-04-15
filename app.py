import requests
import os
import json

env_variables = os.environ
 

def getIp():
    url = "https://api.ipify.org?format=json"
    response = requests.get(url)
    ip = response.json().get("ip")
    print(f"Your public IP address is: {ip}")
    return ip

def checkAllowSendTelegram():
    try:
        DUCKDNS_SENDTELEGRAM=env_variables['DUCKDNS_SENDTELEGRAM']
    except:
        DUCKDNS_SENDTELEGRAM=False
    return bool(DUCKDNS_SENDTELEGRAM)

def sendtelegram(text):
    try:
        DUCKDNS_BOTKEY = env_variables['DUCKDNS_BOTKEY']
    except KeyError:
        print("DUCKDNS_BOTKEY not found in environment variables.")
        return
    try:
        DUCKDNS_CHATID = env_variables['DUCKDNS_CHATID']
    except KeyError:
        print("DUCKDNS_CHATID not found in environment variables.")
        return

    body =  {}
    botkey = DUCKDNS_BOTKEY
    chat = DUCKDNS_CHATID
    
    url = f"https://api.telegram.org/{botkey}/sendMessage"

    headers = {
            'Content-Type': 'application/json'
        }

    body["chat_id"]=chat
    body["text"]=f"updateDuckDNS \n\n {text}"
    response = requests.request("POST", url, headers=headers, data=json.dumps(body))
    text1 = response.text
    print(text1)


def main():
    ip= getIp()
    token=None
    domain=None
    try:
        token = env_variables['DUCKDNS_TOKEN']
    except KeyError:
        print("DUCKDNS_TOKEN not found in environment variables.")
    try:
        domain = env_variables['DUCKDNS_DOMAIN']
    except KeyError:
        print("DUCKDNS_DOMAIN not found in environment variables.")
    if not token or not domain:
        print("Please set the DUCKDNS_TOKEN and DUCKDNS_DOMAIN environment variables.")
        return 
    baseurl=f"http://www.duckdns.org/update?domains={domain}&token={token}&ip={ip}&verbose=true"
    r = requests.get(baseurl)
    if r.status_code == 200:
        result =r.text.replace("\n","\t").replace("\t\t","\t")
        print(result)
        if checkAllowSendTelegram()==True:
            sendtelegram(result)
    else:
        print(f"Failed to update DuckDNS: {r.status_code} - {r.text}")

if __name__ == "__main__":
    main()
