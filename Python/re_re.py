import re

reWSEmbed = re.compile('[\x09\x20\xA0]+')
reWSPrefix = re.compile(r'^\s+', re.MULTILINE)
reWSPostfix = re.compile(r'\s+$', re.MULTILINE)

text = 'vertical\n\nspacing'
collapsed = reWSEmbed.sub(' ', reWSPrefix.sub('', reWSPostfix.sub('', text)))
