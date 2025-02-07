import codecs
import sys

filepath = sys.argv[1]

with open(filepath, 'rb') as rb:
    raw = rb.read(3)
if raw.startswith(codecs.BOM_UTF8):
    content = open(filepath, encoding='utf-8-sig').read()
else:
    try:
        content = open(filepath, encoding='cp1252').read()
    except UnicodeDecodeError:
        content = open(filepath, encoding='utf-8', errors='replace').read()

