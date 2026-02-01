step 6 — do the local windows bootstrap on server-225 (wsman/psremoting/winrm https + wsl features + facts)

this step runs on the target windows machine (server-225) from an elevated powershell, in repo root.

commands to run (powershell as admin, on server-225)

cd D:\develop\dotfile-vnext
.\bin\bootstrap-local.ps1
echo $LASTEXITCODE


if the exit code is 3010, reboot, then run the same commands again:

cd D:\develop\dotfile-vnext
.\bin\bootstrap-local.ps1
echo $LASTEXITCODE


step 7 — do the local wsl bootstrap on server-225 (ssh in wsl + generate host_vars overlays)

commands to run (inside wsl on server-225, from the repo root path mounted in /mnt)
example if your repo is on D:\

cd /mnt/d/develop/dotfile-vnext
chmod +x bin/bootstrap-local.sh
./bin/bootstrap-local.sh


step 8 — verify the generated host_vars exist and look sane

commands to run (powershell, on server-225 or wherever you have the repo)

cd D:\develop\dotfile-vnext
dir inventory\host_vars | findstr server-225
type inventory\host_vars\server-225-win.yaml
type inventory\host_vars\server-225-wsl.yaml


step 9 — only now: remote verification from your controlling machine (mac-dev or your controller)

winrm test

cd /path/to/dotfile-vnext
ansible -i inventory/inventory.yaml server-225-win -m win_ping --ask-vault-pass -vv


wsl ssh test

cd /path/to/dotfile-vnext
ansible -i inventory/inventory.yaml server-225-wsl -m ping -vv


if either test fails, do this single diagnostic (it tells you what values ansible actually resolved after all vars precedence)

ansible-inventory -i inventory/inventory.yaml --host server-225-win --ask-vault-pass


if you paste the output of step 9 failures (the last ~30 lines), i’ll tell you exactly which variable or connection field is wrong and where it’s coming from.