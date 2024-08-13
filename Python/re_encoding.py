import codecs
import sys

filepath = sys.argv[1]

with open(filepath, 'rb') as rb:
    raw = rb.read(3)
if raw.startswith(codecs.BOM_UTF8):
    fp = open(filepath, encoding='utf-8-sig')
else:
    fp = open(filepath, encoding='cp1252', errors='replace')

