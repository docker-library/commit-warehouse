#!/bin/bash
host="$(hostname --ip-address || echo '127.0.0.1')"
curl --connect-timeout 3 --speed-time 3 --fail "http://${host}:8080/bonita/login.jsp" || exit 1