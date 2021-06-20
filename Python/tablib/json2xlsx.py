# json2xlsx via tablib
#
# Requirements:
# - pip install tablib[xlsx]
#

import sys

fn = 'temp'

cols = ['type', 'name', 'id']
nest = ('properties', 'tags')

cols_ilen = len(cols)


import json

js = json.loads(open(fn + '.json').read())

for n in nest:
  s = set()
  for el in js:
  # try:
      if isinstance(el[n], dict):
           s |= set(el[n])
  # except:
  #     pass
  cols.extend(n+'.'+s for s in sorted(s))


import tablib

ds = tablib.Dataset()
ds.headers = cols

for el in js:
  a = []
  a.extend(el[p] for p in cols[:cols_ilen])
  for n in nest:
    for c in cols:
      if c.startswith(n+'.'):
        try:
          a.append(el[n][c[(len(n+'.')):]])
        except:
          a.append(None)
  ds.append(a)

print('$', sys.argv[0], '|', 'rows count=%i' % len(ds))


open(fn + '.xlsx', 'wb').write(ds.xlsx)
