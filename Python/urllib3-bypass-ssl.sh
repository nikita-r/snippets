#·urllib3-bypass-ssl.sh
cd `python -c 'import urllib3; print(urllib3.__path__[0])'`
sed -i 's/^        context\.verify_mode = resolve_cert_reqs(self\.cert_reqs)$/        context.verify_mode = ssl.CERT_NONE/' \
    connection.py
python -m compileall
