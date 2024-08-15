import bs4, re

reWhite = re.compile(r'\s+')
reSpaces = re.compile('\x20+')
reLeadingSpacesMulti = re.compile(r'^\x20+', re.MULTILINE)
reTrailingSpacesMulti = re.compile(r'\x20+$', re.MULTILINE)

soup = bs4.BeautifulSoup('<pre>', 'lxml')
body = soup.find_all('body')[-1]

id_str_pre = set()
for tag in body.select('pre'):
    for s in tag.strings:
        id_str_pre.add(id(s))
for s in list(body.strings):
    if id(s) in id_str_pre: continue
    s.replace_with(reWhite.sub(' ', s))
del id_str_pre

for tag in body.select('pre'):
    for s in list(tag.strings):
        s.replace_with(s.replace(' ', '\xA0'))

for tag in body.select('p, div'):
    tag.insert_before('\n')
    #tag.insert(0, '\n')
    #tag.append('\n')
    tag.insert_after('\n')

def collapse_newlines(tag):
    run = False
    for c in list(tag.children):
        if isinstance(c, bs4.element.NavigableString):
            if run:
                if c in '\n ':
                    c.extract()
                else:
                    run = False
            else:
                if c == '\n':
                    run = True
        else:
            run = False
            collapse_newlines(c)

for tag in body.select('br'):
    tag.replace_with('\n')

def collapse_body_text(text):
    text = reSpaces.sub(' ', reTrailingSpacesMulti.sub('', reLeadingSpacesMulti.sub('', text)))
    text = text.replace('\xA0', ' ')
    return text

print(collapse_body_text(body.get_text()))

