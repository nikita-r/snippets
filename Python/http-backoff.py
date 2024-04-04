from datetime import datetime, UTC
import json
import requests
from time import sleep

headers = { 'api-key': '' }

def get_body(din):
  return {
    'input': din,
  }

def fetch_(uri, din, good_status_codes = [ 200 ]):
    body = get_body(din)
    response = requests.post(uri, headers=headers, json=body)
    assert response.status_code in good_status_codes, f'HTTP {response.status_code}: {response.text}'
    data = response.json()['data']#.get('data')
    return data

dgiven = []

with open(R'*.dgiven.json', encoding='utf-8') as fin:
    dgiven = json.load(fin)

dresults = []

flog = open(R'*.log', 'w', encoding='utf-8')
def plog(line):
    text = datetime.now(UTC).isoformat()[:-13] + 'Z'
    if line:
        text += ': ' + line
    print(text, file=flog, flush=True)

plog()
backoff, backoff_max, backoff_sec = -1, 7, 15
for din in dgiven[len(dresults):]:
    print(din['id'])
    while True:
        try:
            rdata = fetch_('', din)
            dresults.append(rdata)
            #sleep(0.25)
            backoff = -1
        except AssertionError as e:
            plog(str(e))
            if not e.args[0].startswith('HTTP 429: '): raise
            if backoff > backoff_max:
                e.args += (f'{backoff=}',)
                raise
            if backoff < 0:
                timespan = 1
                backoff = 0
            else:
                timespan = backoff_sec * 2**backoff
                backoff += 1
            plog(f'backoff {timespan=}')
            sleep(timespan)
        else:
            break

plog()
flog.close()

with open(R'*.dresults.json', 'w', encoding='utf-8') as fout:
    json.dump(dresults, fout, indent='\t')

