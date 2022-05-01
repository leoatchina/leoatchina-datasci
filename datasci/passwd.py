#/usr/bin/env python

from notebook.auth import passwd
import sys

try:
    password = sys.argv[1]
    print(passwd(password))
except Exception as e:
    pass
