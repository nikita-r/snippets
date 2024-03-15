
from datetime import datetime, UTC

def get_ts_z():
    #return datetime.now(UTC).isoformat().replace('+00:00', 'Z')
    return datetime.now(UTC).isoformat()[:-13] + 'Z'


def predicated_index(P, S):
    for i in range(len(S)): # checks if is a duck-typed sequence
        if P(S[i]): return i
    raise ValueError('element satisfying P not found in S')


