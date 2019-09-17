<!--
.. title: Security advisory: CVE-2018-12543
.. slug: security-advisory-cve-2018-12543
.. date: 2018-09-27 10:36:19 UTC+01:00
.. tags: Security,Releases
.. category:
.. link:
.. description:
.. type: text
-->

Mosquitto 1.6.6 and 1.5.9 have been released to address two security vulnerabilities.

Titles and links will be updated once the CVE numbers are assigned.

# CVE-xxxx-xxxxx

A vulnerability exists in Mosquitto versions 1.5 to 1.6.5 inclusive.

If a client sends a SUBSCRIBE packet containing a topic that consists of
approximately 65400 or more '/' characters, i.e. the topic hierarchy separator,
then a stack overflow will occur.

The issue is fixed in Mosquitto 1.6.6 and 1.5.9. Patches for older versions are
available at <https://mosquitto.org/files/cve/2019-hier>

The fix addresses the problem by restricting the allowed number of topic
hierarchy levels to 200. An alternative fix is to increase the size of the
stack by a small amount.

# CVE-yyyy-yyyyy

A vulnerability exists in Mosquitto version 1.6 to 1.6.4 inclusive.

If an MQTT v5 client connects to Mosquitto, sets a last will and testament,
sets a will delay interval, sets a session expiry interval, and the will delay
interval is set longer than the session expiry interval, then a use after free
error occurs, which has the potential to cause a crash in some situations.

The issue is fixed in Mosquitto 1.6.5. Patches for older versions are available
at <https://mosquitto.org/files/cve/2019-will-delay>

# Version 1.6.6 Changes

The complete list of fixes addressed in version 1.6.6 is:

## Security

* Restrict topic hierarchy to 200 levels to prevent possible stack overflow.
  Closes [#1412].

## Broker
* Restrict topic hierarchy to 200 levels to prevent possible stack overflow.
  Closes [#1412].
* `mosquitto_passwd` now returns 1 when attempting to update a user that does
  not exist. Closes [#1414].

[#1412]: https://github.com/eclipse/mosquitto/issues/1412
[#1414]: https://github.com/eclipse/mosquitto/issues/1414
