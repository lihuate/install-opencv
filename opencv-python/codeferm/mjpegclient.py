"""
Copyright (c) Steven P. Goldsmith. All rights reserved.

Created by Steven P. Goldsmith on February 3, 2017
sgoldsmith@codeferm.com
"""

"""Socket based MJPEG frame grabber.

@author: sgoldsmith

"""

import socket, base64, numpy, cv2
from urllib.parse import urlparse

def open(url, timeout):
    """Open socket"""
    # Set socket timeout
    socket.setdefaulttimeout(timeout)
    # Parse URL
    parsed = urlparse(url)
    port = parsed.port
    # Set port to default if not set
    if not port:
        port = 80
    # See if query string present
    if not parsed.query:
        path = parsed.path
    else:
        path = "%s%s%s" % (parsed.path, "?", parsed.query)   
    # See if we need to do HTTP basic access authentication
    if parsed.username is None:
        # Build HTTP header
        lines = [
            "GET %s HTTP/1.1" % path,
            "Host: %s" % parsed.hostname,
        ]
    else:
        # Base64 encode username and password
        token = base64.encodestring("%s:%s" % (parsed.username, parsed.password)).strip()
        # Build HTTP header
        lines = [
            "GET %s HTTP/1.1" % path,
            "Host: %s" % parsed.hostname,
            "Authorization: Basic %s" % token,
        ]
    # AF_INET: IPv4 protocols (both TCP and UDP)
    # SOCK_STREAM: a connection-oriented, TCP byte stream
    streamSock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    streamSock.connect((parsed.hostname, port))
    # Socket file in read, write, binary mode and no buffer
    socketFile = streamSock.makefile("rwb", buffering=None)
    # Send HTTP GET for MJPEG stream
    socketFile.write("\r\n".join(lines).encode('utf-8') + b"\r\n\r\n")
    socketFile.flush()
    # Read in HTTP headers
    line = socketFile.readline()
    boundary = b""
    while len(line) > 0 and line.strip() != b"" and boundary == b"":
        if line.lower().find(b"content-type: multipart") >= 0:
            parts = line.split(b":")
            if len(parts) > 1 and parts[0].lower() == b"content-type":
                # Extract boundary string from content-type
                content_type = parts[1].strip()
                boundary = content_type.split(b";")[1].split(b"=")[1]
        line = socketFile.readline()
    return socketFile, streamSock, boundary

def getFrameLength(socketFile, boundary):
    """Get frame length from stream"""
    line = socketFile.readline()
    # Find boundary
    while len(line) > 0 and line.count(boundary) == 0:
        line = socketFile.readline()
    length = 0
    # Read in chunk headers
    while len(line) > 0 and line.strip() != "" and length == 0:
        parts = line.split(b":")
        if len(parts) > 1 and parts[0].lower().count(b"content-length") > 0:
            # Toss \r\n
            socketFile.readline()
            # Grab chunk length
            length = int(parts[1].strip())
        line = socketFile.readline()
    return length

def getFrame(socketFile, boundary):
    """Get raw frame data from stream and decode"""
    jpeg = socketFile.read(getFrameLength(socketFile, boundary))
    return jpeg, cv2.imdecode(numpy.fromstring(jpeg, numpy.uint8), cv2.IMREAD_COLOR)
