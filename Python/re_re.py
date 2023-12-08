import re

reLeadingWhite = re.compile(r'^\s+', re.MULTILINE)
reTrailingWhite = re.compile(r'\s+$', re.MULTILINE)
reInlineWhite = re.compile('[\x09\x20\xA0]+')

text = 'vertical\n\nspacing'
collapsed = reInlineWhite.sub(' ', reTrailingWhite.sub('', reLeadingWhite.sub('', text)))
