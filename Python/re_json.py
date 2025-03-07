import json

## cat json arrays in text

data = []
...
with open('./wrangle/datas.json', 'x', encoding='utf-8', newline='\n') as fp:
    json.dump(data, fp, indent='\t')

data = []
...
with open('./wrangle/datas.json', 'a', encoding='utf-8', newline='\n') as fp:
    json.dump(data, fp, indent='\t')

fp = open('./wrangle/datas.json', 'r+b')
offset = fp.read().find(b'\n][\n')
try:
  if offset > -1:
    fp.seek(offset + 1)
    fp.write(b'\t,')
  else:
    fp.seek(0)
    offset = fp.read().find(b'\n][]')
    assert offset > -1
    fp.seek(offset + 2)
    fp.truncate()
finally:
    fp.close()


