from datetime import datetime, UTC

def get_ts():
    #return datetime.now(UTC).isoformat().replace('+00:00', 'Z')
    return datetime.now(UTC).isoformat()[:-13] + 'Z'

