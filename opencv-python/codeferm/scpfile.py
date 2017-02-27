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
    logger.info(" Submitting %s" % command)
    proc = subprocess.Popen([command], shell=True)
    logger.info("Submitted process %d" % proc.pid)
    # scp file
    if deleteSource:
        deleteCommand = "; rm -f %s" % localFileName
    else:
        deleteCommand = ""
    command = "scp %s %s@%s:%s/%s%s" % (localFileName, userName, hostName, remoteDir, os.path.basename(localFileName), deleteCommand)
    logger.info(" Submitting %s" % command)
    proc = subprocess.Popen([command], shell=True)
    logger.info("Submitted process %d" % proc.pid)
