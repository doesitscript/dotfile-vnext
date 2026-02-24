[33ma3f7951[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmain[m[33m, [m[1;31morigin/main[m[33m, [m[1;31morigin/HEAD[m[33m)[m Syncing
[33m66a1c93[m Alpha: network-server group_vars and WSL host_vars configuration
[33mb508a21[m Refactor bootstrap-local.ps1: extract WSL into standalone script, simplify WinRM setup
[33m04ab558[m Daily just to bootstrapt network-server
[33md1dcad3[m modernize python, node, mcp-servers roles; add cursor extension installer
[33mf9d3eaf[m[33m ([m[1;33mtag: [m[1;33mstable-skip-unconfigured[m[33m)[m stable-skip-unconfigured: guard broad-group playbooks against offline hosts
[33md45f6ee[m stable: clean up hyperv_networking, rename WSL-Bridge to External, all SSH working
[33maca1cf2[m[33m ([m[1;33mtag: [m[1;33mhypv-feature-alpha[m[33m)[m hypv-feature: extract shared Hyper-V feature tasks, add standalone playbook
[33ma28b0b3[m stable: decouple Hyper-V from WSL, consolidate shared roles, fix provisioning
[33m4e7860b[m WIP troubleshoot conenction
[33m15d4924[m stable: fully functioning networking without gimmicks
[33m4e8bde8[m[33m ([m[1;33mtag: [m[1;33malpha-prerelease[m[33m)[m Add wsl-reset tag, drop redundant authorized_keys task, cleanup
[33mc44f6f2[m Fix idempotency: dedup sshd_config ports, touch→win_copy, skip offline hosts
[33mcbb953d[m Prelim
[33ma00014d[m Alpha planning ssh/dockersetup
[33m9af0c01[m[33m ([m[1;33mtag: [m[1;33mprerelease-ssh-all-surfaces[m[33m)[m prerelease: all SSH surfaces verified — clean connections, no warnings
[33m6c364f2[m[33m ([m[1;33mtag: [m[1;33malpha-wsl-direct-ssh[m[33m)[m alpha: WSL direct SSH, port forwarding, systemctl/segfault fixes (preliminary — all running)
[33m6211b15[m[33m ([m[1;33mtag: [m[1;33mssh-stable[m[33m)[m stable: fact-driven SSH config, orchestration pipeline, role refactoring
[33m1afdf11[m fix: OpenSSH default shell, dual-port PowerShell SSH, pwsh role, and controller docs
[33m54be563[m Fixing remoting inprogress
[33m5c98ccb[m Tmux
[33m22d5614[m FIxes tmux
[33m06e4ca7[m add tmux role, generic role template, and cursor Remote-SSH support
[33m1e2ce56[m[33m ([m[1;33mtag: [m[1;33mv0.5.0[m[33m)[m stable: bootstrap chain fully operational with SSH key deployment
[33m71dd19b[m stable: bootstrap chain verified end-to-end on server-225
[33m345f2cd[m fix bootstrap inprogress
[33m4458c19[m refactored asset
[33mdeae91f[m Not ADMINISTRATORgit add .git add .git add .git add .git add .!
[33mc0b7067[m fix regen key again and change defaut termianl
[33mfbb05fc[m broken update key
[33m6d16c56[m FIx duplicate header in ansible.cfg
[33m68c82ac[m Trial of ansible install of docker
[33m3270a40[m Preprocess and setup docker
[33m46c586a[m Daily
[33m9e011e7[m Refactor ssh setup
[33mb739e7a[m Large Refactor
[33mddb9c90[m Minor refactor
[33m805b818[m README: two sides of the coin = execution node + boostrap_windows_ssh_via_winrm
[33m55d12d0[m[33m ([m[1;33mtag: [m[1;33mv0.2.0[m[33m, [m[1;33mtag: [m[1;33mstable-v0.2.0[m[33m)[m Pre-cleanup for mac ssh and windows server ssh setup
[33m05b654b[m Fixes ssh on llm server **** . Verify ssh
[33mc5cfff0[m testing a restart at end
[33mcccca12[m closest to runnable in a while
[33m334aa93[m Just some cleanup
[33m0e743be[m v2
[33mdeefc37[m fixserver ssh
[33m0fd6b1f[m ssh setup
[33m64c4f94[m separate
[33m26f2ec8[m One ess error
[33m75d2f36[m fixing bugs
[33mc2a2633[m SSHD Minmized nodes
[33m8456020[m Pre OpenSSH setup
[33mb4da46a[m ssh setup via winrm
[33m99521b3[m  Reduced scripts using ansible
[33m8f6b372[m Fix winrm on client
[33mae8abb3[m Add bashrc.d and reconfigure hub. prioritiezes wsl paths
[33m4473275[m Pre-organize
[33m837830b[m [WIP]Successful WSMAN remote
[33ma25d6a1[m Debug winrm
[33mb3fab15[m Setup ssh
[33me44b347[m openssh gen and vaulted
[33mb0131d5[m Git fixing wsl push
[33m88f8b85[m Setup ssh
[33mc29ecfd[m Git fixing wsl push
[33mb1a803f[m Git fixing wsl push
[33m860866b[m No errors bootstrap
[33mc7194b2[m winrm and ssh no errors in script
[33m3220efe[m Setup ssh
[33m446958a[m CLosing gap
[33m6f6080a[m windows pip reqiremtns and powerslle providers
[33m59f5a60[m Git fixing push
[33mf7c33d0[m fixing auto provision keys
[33m72626c2[m Setup ssh
[33me441789[m Setup openssh and default bash terminal
[33m3eeb353[m Pre openssh setup
[33m84dada3[m Fix debug error mac
[33mba8ca98[m Fix debug error mac
[33m4ccaee8[m Fix debug error mac
[33m8da47f0[m Debug
[33m4160b96[m Fix debug error mac
[33m5d5d760[m Debug
[33m08b1f59[m Fix debug error mac
[33m8563828[m Debug
[33m5ac47e3[m fix mac error
[33m0d7a71c[m Archives bootstrap and bootstrap_updates; hands-free vault and path refs
[33mb036b7b[m Automate controller SSH key; align bootstrap with Ansible docs and FQCN
[33m6d78952[m[33m ([m[1;33mtag: [m[1;33mstable[m[33m)[m stable: bootstrap chain works
[33m1d92d66[m Fixed all bootstrap chaining
[33m4c8b8e0[m feat(bootstrap): full SSH key creation via bootstrap scripts [BETA]
[33m5d6eec0[m add collect facts from fz command
[33me4f1e2c[m add collect facts from fz command
[33mb5d4653[m Pre shortentool startup
[33m6970b52[m Can run local single roles
[33m139574c[m fixing bootstrap and run single role
[33m8fdc9b4[m Logging updated
[33m0246c06[m Normalize bootstrap logging/error output to repo contract.
[33mfc2a6c1[m Minor role update
[33mcb31dc6[m[33m ([m[1;33mtag: [m[1;33malpha-refactor-complete[m[33m)[m Complete cross-platform bootstrap and inventory refactor.
[33mef4ad60[m Test python3 setup and require line for ansible
[33mbd6af6a[m Pre-upgrade repo
[33m0a59e1f[m WIP-addroles
[33m532b49c[m  minor refactor
[33mcc53cdb[m Document Windows bootstrap entrypoint and harden local bootstrap flow.
[33mfae708f[m Update bootstrap redeploy flow and WSL distro mapping.
[33m549fd59[m bootstrap-ansible-local: fix UnregisterIfExists $true so it never runs wsl --install (no download)
[33m171bd5c[m Test bootstrap after major revision. Runs
[33mf3c4a35[m Add initial Ansible Architect Rules and instructions for Cursor Docs integration
[33ma4518f7[m Fix encoding on server-225.json
[33mf95638b[m Fix bug: Writing files with wrong encoding causing invisible header errors
[33md38cd84[m adding auto provision ansible
[33mba3c67e[m[33m ([m[1;33mtag: [m[1;33mv1.0.0[m[33m)[m MAJOR UPDATE: Stable release with auto-login using WSL user and password
[33m390260f[m Fix cloud-init schema error by using WriteAllLines instead of Out-File
[33m31f2159[m successful ingest but didn't like the schema
[33m286595f[m trying to add a wsl.cfg
[33m89fdb33[m Fix host_var generation - resolve PowerShell-YAML module installation issues
[33m1cfb504[m Fix exit logic in wsl_auto.ps1 to properly exit when WSL host_vars file doesn't exist
[33m597358d[m Pre auto user create
[33mac4bc44[m Improve passwordless sudo detection and automation in bootstrap-local.sh
[33m948a757[m Fix: Use sudo grep for sshd_config checks in bootstrap-local.sh
[33m4c9db9a[m[33m ([m[1;33mtag: [m[1;33mv0.1.1[m[33m)[m Fix: Add Administrator account warning to prevent WSL setup issues
[33maa1ec61[m Migrate Ansible template functionality to bootstrap-local.ps1
[33m1655a17[m[33m ([m[1;33mtag: [m[1;33mv0.1.0-alpha[m[33m)[m Bootstrap script improvements: YAML loading, IP detection, and WSL handling
[33m015a9f3[m alpha: refactor bootstrap to use WinRM HTTP and dynamic node detection
[33mb42fb7f[m Refactored for dyanmic local runs first time
[33mc1ccd72[m WinRM now with http
[33ma7728f8[m Normalize line endings to LF per .gitattributes
[33m7d61a8a[m Shortens docker setup
[33mb0b5e6f[m Long wsl install
[33m50d4bb3[m preubuntu  botscro pre-install distro
[33m484c9d4[m Alpha Bootstrap. Need  distro before continue with bootstrap
[33mfd50e82[m Converting to file based passwords, no vault
[33m2af2db6[m Step 4 generating facts now, not hand jam
[33m7e1d341[m Step 3 git keep
[33mb298914[m Finish step 2
[33m5414179[m add step 1 files
[33md1b1245[m Pre-fix bootstrap remote setup and inentory
[33mfa73877[m Fixes commit and pull in current session
[33m9578767[m Added prelim bootstrap for early setup.
[33m7a8dace[m Add bin/fz CLI with subcommands, guardrails, and ergonomics
[33mb38a4e0[m Add bin/ scaffold and venv + ansible wrapper behavior
[33m63cd215[m pre bin pre bootstrap
[33mc919ff5[m Checkpoint 9: Secrets & rendering pipeline (vault + templates)
[33mdbcfc5a[m Checkpoint 8: Dev-3090 bootstrap + dev stacks (dual runtime support)
[33mf6a03a5[m Checkpoint 7: Network-server bootstrap + network stacks
[33me86c6ac[m Checkpoint 5: Implement common baseline and health checks
[33mb08ecd1[m Not checked?
[33m0845e25[m inital questionare done
[33ma20c7c2[m First pass at answering questionnaires
[33m4d50c5f[m ON QUESTION 20
[33mfca24d7[m Add hostname mapping configuration and update checkpoint documentation
[33me4eac31[m Step 1 complete: questionnaire created
[33m6ccd475[m Add actuals
[33m4ee7299[m Stop implementation. We are entering a validation and parameter-injection phase. Do not modify any files until instructed.
[33mff04e45[m[33m ([m[1;33mtag: [m[1;33mv0.1.0[m[33m)[m Reorganize files into content/ directory and add assemble_checkpoints.md
[33m876c284[m Initial commit
