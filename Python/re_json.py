import json

## cat json arrays in text

data = []
...
with open('./wrangle/datas.json', 'a', encoding='utf-8') as fp:
    json.dump(data, fp, indent='\t')

data = []
...
with open('./wrangle/datas.json', 'a', encoding='utf-8') as fp:
    json.dump(data, fp, indent='\t')

fp = open('./wrangle/datas.json', 'r+b')
offset = fp.read().find(b'\n][')
assert offset > -1
fp.seek(offset + 1)
fp.write(b'\t,')
fp.close()

