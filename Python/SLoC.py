#·SLoC.py

import sys
if sys.version_info[0:2] < (3,6):
    print('$', 'python', sys.argv[0], '|', 'require Python version >= 3.6', file=sys.stderr)
    exit(-1)

import os
from typing import List

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

            if excl:
                dirpath_split = split_path(dirpath)
                if any( norm(_) in dirpath_split for _ in excl ):
                    continue

            if dirpath in paths_walked:
                continue
            paths_walked.add(dirpath)

            for file in filenames:
                if norm(os.path.splitext(file)[1])[1:] in ( norm(ext) for ext in t ):
                    yield ( dirpath, file )

import fileinput

def iter_files_lines(files_list):
    openhook = fileinput.hook_encoded(encoding="utf-8", errors="surrogateescape")
    with fileinput.input(files_list, openhook=openhook) as line_iter:
        for line in line_iter:
            yield ( fileinput.filename(), fileinput.filelineno(), line )

def lines_skip_empty(t_lines: List[str]):
    for t_line in t_lines:
        line = t_line[2]
        if line.isspace():
            continue
        yield t_line


if __name__ == '__main__':

    import argparse
    ArgParser = argparse.ArgumentParser()
    ArgParser.add_argument("-t", action='append', required=True, help='include file type (extension)', metavar='Ext')
    ArgParser.add_argument("-x", action='append', default=[], help='exclude directory', metavar='Dir')
    ArgParser.add_argument("dirs", nargs='+', help='directories which to walk', metavar='Dir')
    args = ArgParser.parse_args()

    from time import time
    print('seconds=%i' % time())

    import cProfile
    prof_pr = cProfile.Profile()
    prof_pr.enable()

    t_lines = iter_files_lines( os.path.join(t[0], t[1]) for t in walk_directories(args.dirs, args.x, args.t) )
    print('SLoC count=%09d' % sum(1 for dummy in lines_skip_empty(t_lines)))
    print('newl count=%09d' % fileinput.lineno())

    prof_pr.disable()

    print('seconds=%i' % time())

    import shutil
    COLUMNS, LINES = shutil.get_terminal_size()
    print()
    print('='*COLUMNS)

    import pstats, io
    ostringstream = io.StringIO()
    prof_st = pstats.Stats(prof_pr, stream=ostringstream)
    prof_st.strip_dirs()
    prof_st.sort_stats(pstats.SortKey.CUMULATIVE)
    prof_st.print_stats(LINES-2)
    print(ostringstream.getvalue())
    ostringstream.close()

