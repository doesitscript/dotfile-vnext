ansible all -m ping -iinventory/inventory.yaml

[ERROR]: Task failed: ntlm: auth method ntlm requires a password

Task failed.
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

<<< caused by >>>

ntlm: auth method ntlm requires a password

server-225-win | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: ntlm: auth method ntlm requires a password",
    "unreachable": true
}
[ERROR]: Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname network-server-win: nodename nor servname provided, or not known                                                           

Task failed.
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

<<< caused by >>>

Failed to connect to the host via ssh: ssh: Could not resolve hostname network-server-win: nodename nor servname provided, or not known                                                                                 

network-server-win | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname network-server-win: nodename nor servname provided, or not known",                                                      
    "unreachable": true
}
[ERROR]: Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname dev-3090-win: nodename nor servname provided, or not known                                                                 

Task failed.
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

<<< caused by >>>

Failed to connect to the host via ssh: ssh: Could not resolve hostname dev-3090-win: nodename nor servname provided, or not known                                                                                       

dev-3090-win | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Failed to connect to the host via ssh: ssh: Could not resolve hostname dev-3090-win: nodename nor servname provided, or not known",                                                            
    "unreachable": true
}
[ERROR]: Task failed: Data could not be sent to remote host "network-server-wsl". Make sure this host can be reached over ssh: ssh: Could not resolve hostname network-server-wsl: nodename nor servname provided, or not known                                                                                                     
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

network-server-wsl | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Data could not be sent to remote host \"network-server-wsl\". Make sure this host can be reached over ssh: ssh: Could not resolve hostname network-server-wsl: nodename nor servname provided, or not known",                                                                                              
    "unreachable": true
}
[ERROR]: Task failed: Data could not be sent to remote host "dev-3090-wsl". Make sure this host can be reached over ssh: ssh: Could not resolve hostname dev-3090-wsl: nodename nor servname provided, or not known     
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

dev-3090-wsl | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Data could not be sent to remote host \"dev-3090-wsl\". Make sure this host can be reached over ssh: ssh: Could not resolve hostname dev-3090-wsl: nodename nor servname provided, or not known",                                                                                                          
    "unreachable": true
}
mac-dev | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
[ERROR]: Task failed: Data could not be sent to remote host "192.168.50.158". Make sure this host can be reached over ssh: ssh: connect to host 192.168.50.158 port 22: Operation timed out                             
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

server-225-wsl | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Data could not be sent to remote host \"192.168.50.158\". Make sure this host can be reached over ssh: ssh: connect to host 192.168.50.158 port 22: Operation timed out",                      
    "unreachable": true
}