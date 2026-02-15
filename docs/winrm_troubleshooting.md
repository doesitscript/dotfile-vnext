# WinRM Troubleshooting

## "ConvertFrom-Json ... System.Object[]" / "Module result deserialization failed: No start of json char found"

When running Ansible against Windows over WinRM (e.g. `ansible server-225-win -m ping -i inventory/inventory.yaml`), the pipeline wrapper on the Windows host can receive the module payload as multiple lines. PowerShell then builds an array for `$codeJson`, but `ConvertFrom-Json -InputObject` requires a single string, so the task fails.

### What we changed in this project

1. **Venv patch (definitive fix)**  
   The file `.venv/lib/python3.14/site-packages/ansible/executor/powershell/bootstrap_wrapper.ps1` was patched so that when `$codeJson` is an array it is joined into one string before calling `ConvertFrom-Json`. After upgrading ansible-core (e.g. `pip install -U ansible-core`), re-apply this patch.

2. **ansible.cfg**  
   The `[winrm]` section documents this issue and points here. If the venv patch is not applied, you can try `pipelining = false` under `[winrm]` as a workaround (slower but may avoid the split payload).

### Re-applying the venv patch after upgrade

Target file (path relative to project root):

```text
.venv/lib/python3.14/site-packages/ansible/executor/powershell/bootstrap_wrapper.ps1
```

Find this block (around lines 9–15):

```powershell
$codeJson = foreach ($in in $input) {
    if ([string]::Equals($in, "`0`0`0`0")) {
        break
    }
    $in
}
$code = ConvertFrom-Json -InputObject $codeJson
```

Insert **after** the closing `}` of the `foreach` and **before** the `$code = ConvertFrom-Json` line:

```powershell
# When stdin is split (e.g. CRLF or WinRM line-by-line), $codeJson is [Object[]]; ConvertFrom-Json requires a string
if ($codeJson -is [Array]) {
    $codeJson = $codeJson -join "`n"
}
```

So the result looks like:

```powershell
$codeJson = foreach ($in in $input) {
    if ([string]::Equals($in, "`0`0`0`0")) {
        break
    }
    $in
}
# When stdin is split (e.g. CRLF or WinRM line-by-line), $codeJson is [Object[]]; ConvertFrom-Json requires a string
if ($codeJson -is [Array]) {
    $codeJson = $codeJson -join "`n"
}
$code = ConvertFrom-Json -InputObject $codeJson
```

Note: the exact path may change with your Python version (e.g. `python3.13` instead of `python3.14`).

### Other workarounds (macOS controller)

From `docs/suggested_improvements.md`: if WinRM/PSRP fails with other errors on macOS, try:

```bash
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=yes
export no_proxy=*
```

And ensure `pywinrm` is installed in the env used by Ansible (e.g. `pip install 'pywinrm[ntlm]'` or as suggested in that doc).
