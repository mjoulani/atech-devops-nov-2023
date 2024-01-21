

def nationalize(name):
    url = "https://api.nationaliz.io/?name="
    data = requests.get(url+name)
    if data.status_code != 200 :return None
    newdata=data.json()
    if newdata['count'] == 0 : return None
    name_cuntry=newdata['country'][0]['country_id']
    percent=newdata['country'][0]['probability'] * 100
    jsondata = requests.get("https://archivenelson-shoevision.codio.io/.guides/data/countryISO2Name.json").json()
    #if data.status_code != 200: return None
    print(jsondata[name_cuntry]+" "+ str(percent) +"%")

    return jsondata[name_cuntry],percent