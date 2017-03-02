"""
Copyright (c) Steven P. Goldsmith. All rights reserved.

Created by Steven P. Goldsmith on February 25, 2017
sgoldsmith@codeferm.com
"""

import os, subprocess

curRemoteDir = None

def copyFile(logger, hostName, userName, localFileName, remoteDir, deleteSource, timeout):
    """SCP file using command line."""
    global curRemoteDir
    # Create remote dir only once
    if curRemoteDir != remoteDir:
        curRemoteDir = remoteDir
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
    command = "sleep 2; scp %s %s@%s:%s/%s%s" % (localFileName, userName, hostName, remoteDir, os.path.basename(localFileName), deleteCommand)
    logger.info(" Submitting %s" % command)
    proc = subprocess.Popen([command], shell=True)
    logger.info("Submitted process %d" % proc.pid)
