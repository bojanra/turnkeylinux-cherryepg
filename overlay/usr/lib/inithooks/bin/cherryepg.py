#!/usr/bin/python
"""Set cherryepg user password

Option:
    --pass=     unless provided, will ask interactively

"""

import sys
import getopt

from executil import getoutput
from dialog_wrapper import Dialog

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h", ['help', 'pass='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "cherryepg Password",
            "Enter new password for the 'cherryepg' user account.")

    getoutput("echo \"%s\"\n\"%s\" | passwd cherryepg" % ( password, password))

if __name__ == "__main__":
    main()

