ssh server-225-win
wsl: The specified request is unsupported. 
Error code: CreateInstance/CreateVm/ConfigureNetworking/0x803b0015
wsl: Failed to configure network (networkingMode Mirrored), falling back to networkingMode None.
joshc@DESKTOP-VLLM:/mnt/c/Users/joshc$ exit
logout
Shared connection to desktop-vllm closed.
(.venv) Joshs-MBP:dotfile-vnext joshc$ 

# live logs of ssh.service
joshc@DESKTOP-VLLM:/mnt/c/Users/joshc$ journalctl -fu ssh.service
Feb 20 23:30:53 DESKTOP-VLLM systemd[1]: Dependency failed for ssh.service - OpenBSD Secure Shell server.
Feb 20 23:30:53 DESKTOP-VLLM systemd[1]: ssh.service: Job ssh.service/start failed with result 'dependency'. 


###**8
ssh server-225-win-powershell
wsl: The specified request is unsupported. 
Error code: CreateInstance/CreateVm/ConfigureNetworking/0x803b0015
wsl: Failed to configure network (networkingMode Mirrored), falling back to networkingMode None.
<3>WSL (362 - Relay) ERROR: CreateProcessParseCommon:996: getpwnam(joshc) failed 0
Windows PowerShell


ssh server-225-win
#<3>WSL (319 - Relay) ERROR: CreateProcessParseCommon:996: getpwnam(joshc) failed 0
root@DESKTOP-VLLM:/mnt/c/Users/joshc# 

ssh server-225-wsl -vvv
OpenSSH_8.6p1, LibreSSL 3.3.6
debug1: Reading configuration data /Users/joshc/.ssh/config
debug1: /Users/joshc/.ssh/config line 26: Applying options for server-225-wsl
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: /etc/ssh/ssh_config line 21: include /etc/ssh/ssh_config.d/* matched no files
debug1: /etc/ssh/ssh_config line 54: Applying options for *
debug3: expanded UserKnownHostsFile '~/.ssh/known_hosts' -> '/Users/joshc/.ssh/known_hosts'
debug3: expanded UserKnownHostsFile '~/.ssh/known_hosts2' -> '/Users/joshc/.ssh/known_hosts2'
debug1: Authenticator provider $SSH_SK_PROVIDER did not resolve; disabling
debug1: Connecting to desktop-vllm port 22.
ssh: connect to host desktop-vllm port 22: Operation timed out
(.venv) Joshs-MBP:dotfile-vnext joshc$ 

# need to verify that my cloudconfig  and my ubuntu.yml aren'tcausing problems  bcuase i'm pretty sure both are configureing 
 cat /etc/wsl.conf
[boot]
systemd=true
command=service ssh start
[user]
default=joshc

i checked the windows host and currently form the host: Get-Content .\.wslconfig
[wsl2]
networkingMode=mirrored
#####
ssh server-225-wsl
times out


nc -z -w 5 192.168.50.158 22
# troubleshooting
sshd -t

sudo systemctl restart ssh.service
cat /etc/ssh/sshd_config

ss -tlnp
 ss -tlnp
State  Recv-Q Send-Q   Local Address:Port       Peer Address:Port      Process
LISTEN 0      4096           0.0.0.0:22              0.0.0.0:*   

# make sure on windows nothing is conflicing with your port (22)
netstat -ano | findstr :22


PS C:\Users\joshc> netstat -ano | findstr :22
PS C:\Users\joshc> netstat -ano | findstr :22
  TCP    0.0.0.0:2222           0.0.0.0:0              LISTENING       17916
  TCP    0.0.0.0:2223           0.0.0.0:0              LISTENING       17916
  TCP    127.0.0.1:22           0.0.0.0:0              LISTENING       20624
  TCP    192.168.50.158:2222    192.168.50.33:58793    ESTABLISHED     17916
  TCP    192.168.50.158:2223    192.168.50.33:58804    ESTABLISHED     17916