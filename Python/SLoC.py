#·SLoC.py

import sys
if sys.version_info[0:2] < (3,6):
    print('$', 'python', sys.argv[0], '|', 'require Python version >= 3.6', file=sys.stderr)
    exit(-1)

import os

def split_path(path):
    rez = []
    while 1:
        parts = os.path.split(path)
        if parts[0] == path:        # sentinel for absolute paths
            rez.insert(0, parts[0])
            break
        elif parts[1] == path:      # sentinel for relative paths
            rez.insert(0, parts[1])
            break
        else:
            path = parts[0]
            rez.insert(0, parts[1])
    return rez

def walk_directories(dirs, excl, t):
    norm = os.path.normcase
    paths_walked = set()
    for dir in dirs:
        dir = os.path.realpath(dir)
        if not os.path.isdir(dir): raise Exception(f'Dir "{dir}" does not exist.')
        for dirpath, dirnames, filenames in os.walk(dir):

            try:
                if (os.path.relpath(dirpath)[0:3] in ( '..' + os.sep, '..' )):
                    raise Exception()
                dirpath = norm(os.path.relpath(dirpath))
            except:
                dirpath = norm(dirpath)

            dirpath_split = split_path(dirpath)
            if any( norm(_) in dirpath_split for _ in excl ):
                continue

            if dirpath in paths_walked:
                continue
            paths_walked.add(dirpath)

            for file in filenames:
                for ext in t:
                    if norm(os.path.splitext(file)[1])[1:] == norm(ext):
                        yield ( dirpath, file )
                        break

import fileinput

def iter_files_lines(files_list):
    with fileinput.input(files_list) as line_iter:
        for line in line_iter:
            yield ( fileinput.filename(), fileinput.filelineno(), line )

def lines_skip_empty(t_lines):
    for t_line in t_lines:
        line = t_line[2]
        if line.isspace():
            continue
        yield t_line


if __name__ == '__main__':

    import argparse
    ArgParser = argparse.ArgumentParser()
    ArgParser.add_argument("-t", metavar='Ext', action='append', help='include file type (extension)', default=[], required=True)
    ArgParser.add_argument("-x", metavar='Dir', action='append', help='exclude directory', default=[])
    ArgParser.add_argument("rest", nargs='+', metavar='Dir', help='directories which to walk')
    args = ArgParser.parse_args()

    import time
    print('seconds=%i' % int(time.time()))

    t_lines = iter_files_lines( os.path.join(t[0], t[1]) for t in walk_directories(args.rest, args.x, args.t) )
    print('SLoC count=%09d' % sum(1 for dummy in lines_skip_empty(t_lines)))
    print('newl count=%09d' % fileinput.lineno())

    print('seconds=%i' % int(time.time()))

