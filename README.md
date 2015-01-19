# mylarPrefPane
A helping preference pane for Mylar management on OSX

MylarPrefPane is a preference pane for OSX that tries to ease Mylar server Management by simplifying some tasks
1 Daemonization of the server so the system starts it up automaticaly
2 Simple start/stop handling
3 Simple testing facilities to diagnose if server is working ok or not

LIMITATIONS
· For the moment, can only start/stop and daemonize in the localhost
· Can't install the server as root so it can be started automatically when booted, needs to be logged in as the user that installed the server
· Needs help locating the Mylar.py install directory (maybe will try to autofind the Mylar.py in the usual places in the future)

All this work is inspired by the outstanding work made by evilhero on Mylar at:
https://github.com/evilhero/mylar

Only trying to improve its ease of use.
Assume any failure to work correctly is my fault, not his, so don't pester him if the prefpane doesn't work ;)
