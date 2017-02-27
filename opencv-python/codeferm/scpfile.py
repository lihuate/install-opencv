"""
Copyright (c) Steven P. Goldsmith. All rights reserved.

Created by Steven P. Goldsmith on February 25, 2017
sgoldsmith@codeferm.com
"""

import os, subprocess

def copyFile(logger, hostName, userName, localFileName, remoteDir, deleteSource, timeout):
    """SCP file using command line."""
    # mkdir on remote host
    command = "ssh %s@%s \"%s\"" % (userName, hostName, "mkdir -p %s" % remoteDir)
    logger.info("%s" % command)
    subprocess.call(command, shell=True)
    # scp file
    if deleteSource:
        deleteCommand = "; rm -f %s" % localFileName
    else:
        deleteCommand = ""
    command = "scp %s %s@%s:%s/%s%s" % (localFileName, userName, hostName, remoteDir, os.path.basename(localFileName), deleteCommand)
    logger.info("%s" % command)
    subprocess.call(command, shell=True)
