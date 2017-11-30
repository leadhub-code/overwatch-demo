#!/usr/bin/env python3

from functools import partial
import os
from pathlib import Path
import subprocess
from time import sleep


run_tasks = [
    {
        'command': ['/venv-hub/bin/overwatch-hub', '-v', '/overwatch-hub/sample_configuration.yaml'],
    }, {
        'command': ['/venv-agents/bin/overwatch-web-agent', '-v', '/overwatch-basic-agents/sample_configuration.yaml'],
    }, {
        'cwd': '/overwatch-web',
        'env': {
            'OVERWATCH_WEB_CONF': '/overwatch-web/sample_configuration.yaml',
            'INSECURE_SESSION_SECRET_OK': '1',
        },
        'command': ['yarn', 'start'],
    }, {
        'command': ['/usr/sbin/nginx', '-c', '/nginx.conf'],
    }
]

print = partial(print, flush=True)


def main():
    ensure_dir('/overwatch-hub/local')
    ensure_dir('/overwatch-basic-agents/local')
    processes = []
    try:
        for task in run_tasks:
            env = {**os.environ, **task['env']} if task.get('env') else None
            p = subprocess.Popen(task['command'], cwd=task.get('cwd'), env=env)
            processes.append(p)
            print('Started', task)
            sleep(1)
            check_processes(processes)
        while True:
            check_processes(processes)
            sleep(1)
    finally:
        for p in processes:
            p.terminate()
        for p in processes:
            p.wait()


def check_processes(processes):
    for p in processes:
        if p.poll() is not None:
            raise Exception('Process {} has exited with code {}'.format(p.pid, p.returncode))


def ensure_dir(dir_path):
    dir_path = Path(dir_path)
    if not dir_path.exists():
        dir_path.mkdir(parents=True)
        print('Created directory', dir_path)


if __name__ == '__main__':
    main()
