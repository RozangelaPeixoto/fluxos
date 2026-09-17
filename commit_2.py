import os
import subprocess
from pathlib import Path

repo_dir = Path(r"c:\Users\roxpm\Projetos_Java\FluxOS")

def run_cmd(cmd, env=None):
    subprocess.run(cmd, cwd=repo_dir, shell=True, env=env, check=True)

def commit(date_str, message):
    env = os.environ.copy()
    env["GIT_AUTHOR_DATE"] = date_str
    env["GIT_COMMITTER_DATE"] = date_str
    run_cmd(f'git commit -m "{message}"', env=env)

def main():
    run_cmd('git add lib/screens/')
    commit("2026-09-16T21:14:00-03:00", "feat: atualiza interfaces para seguir os layouts fornecidos")

if __name__ == "__main__":
    main()
