from datetime import datetime, UTC
import json
import requests
from time import sleep

headers = { 'api-key': '' }

def get_body(input):
  return {
    'input': input,
  }

def fetch_(uri, din, good_status_codes = [ 200 ]):
    body = get_body(din)
    response = requests.post(uri, headers=headers, json=body)
    assert response.status_code in good_status_codes, f'HTTP {response.status_code}: {response.text}'
    data = response.json()['data']#.get('data')
    return data


flog = open(R'*.log', 'w', encoding='utf-8')
def plog(line):
    text = datetime.now(UTC).isoformat()[:-13] + 'Z'
    if line:
        text += ': ' + line
    print(text, file=flog, flush=True)


d_given = []

with open(R'*.dGiven.json', encoding='utf-8') as fin:
    d_given = json.load(fin)

d_rez = []

backoff_init, backoff_max = -1, 7
regular_step, backoff_step = 0, 15 # seconds

plog()
for d in d_given[len(d_rez):]:
    print(d['id'])
    backoff = backoff_init
    while True:
        try:
            r = fetch_('', d)
            d_rez.append(r)
            regular_step and sleep(regular_step)
        except AssertionError as e:
            plog(str(e))
            if not e.args[0].startswith('HTTP 429: '): raise
            if backoff > backoff_max:
                e.args += (f'{backoff=}',)
                raise
            if backoff < 0:
                timespan = regular_step + 1
                backoff = 0
            else:
                timespan = backoff_step * 2**backoff
                backoff += 1
            plog(f'backoff {timespan=}')
            sleep(timespan)
        else:
            break

plog()
flog.close()

with open(R'*.dResults.json', 'w', encoding='utf-8') as fout:
    json.dump(d_rez, fout, indent='\t')

