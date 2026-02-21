netsh interface portproxy add v4tov4 `
  listenaddress=0.0.0.0 `
  listenport=22 `
  connectaddress=172.22.240.57 `
  connectport=22

  netsh interface portproxy add v4tov4 `
>>   listenaddress=0.0.0.0 `
>>   listenport=2222 `
>>   connectaddress=172.22.240.57 `
>>   connectport=22