"""
Copyright (c) Steven P. Goldsmith. All rights reserved.

Created by Steven P. Goldsmith on February 25, 2017
sgoldsmith@codeferm.com
"""

import os, subprocess

def copyFile(logger, hostName, userName, localFileName, remoteDir, timeout):
    """SCP file using command line."""
    # mkdir on remote host
    command = "ssh %s@%s \"%s\"" % (userName, hostName, "mkdir -p %s" % remoteDir)
    logger.info("%s" % command)
    subprocess.call(command, shell=True)
    # scp file
    command = "scp %s %s@%s:%s%s%s" % (localFileName, userName, hostName, remoteDir, os.sep, os.path.basename(localFileName))
    logger.info("%s" % command)
    subprocess.call(command, shell=True)
