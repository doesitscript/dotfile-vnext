[localhost] TASK: python : Install Python versions with pyenv (debug)> p task
TASK: python : Install Python versions with pyenv
[localhost] TASK: python : Install Python versions with pyenv (debug)> p task.args
{'_raw_params': 'pyenv install {{item}} --skip-existing',
 'creates': "{{ '~/.pyenv/versions/' + item | expanduser }}"}
[localhost] TASK: python : Install Python versions with pyenv (debug)> p task.vars
{}
[localhost] TASK: python : Install Python versions with pyenv (debug)> p host
localhost
[localhost] TASK: python : Install Python versions with pyenv (debug)> p result
<ansible.executor.task_result.TaskResult object at 0x10ea5feb0>
[localhost] TASK: python : Install Python versions with pyenv (debug)> p result._result
{'_ansible_no_log': False,
 'failed': True,
 'msg': "Unexpected templating type error occurred on ({{ '~/.pyenv/versions/' "
        '+ item | expanduser }}): expected str, bytes or os.PathLike object, '
        'not float'}
[localhost] TASK: python : Install Python versions with pyenv (debug)>