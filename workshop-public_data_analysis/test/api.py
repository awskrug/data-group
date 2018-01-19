import requests

def test_requests():
  url = "https://google.com"

  res = requests.get(url,params=None)

  return res

print(test_requests().content)