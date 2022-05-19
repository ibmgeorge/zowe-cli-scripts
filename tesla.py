import http.client, urllib, requests, time, datetime

def sendmsg(msg):
    conn = http.client.HTTPSConnection("api.pushover.net:443")
    conn.request("POST", "/1/messages.json",
        urllib.parse.urlencode({
        "token": "a14sur8zzpp9upg3iyk11aug9z81am",
        "user": "urmwqac6m872yzwhaowygxbtou9p2s",
        "message": msg,
        }), { "Content-type": "application/x-www-form-urlencoded" })
    ret = conn.getresponse().getcode()
    conn.close
    return ret

print("program starting")
ret = sendmsg("Starting to find Model Y")
url = 'https://www.tesla.com/en_au/modely/design'
while True:
    print(datetime.datetime.now()," Checking..." )
    r = requests.get(url)
    if (r.status_code==200):
        sendmsg("Model Y is available")
    time.sleep(300)


