import os
import subprocess
import datetime
from pathlib import Path

repo_dir = Path(r"c:\Users\roxpm\Projetos_Java\FluxOS")

def run_cmd(cmd, env=None):
    subprocess.run(cmd, cwd=repo_dir, shell=True, env=env, check=True)

def commit(date_str, message):
    env = os.environ.copy()
    # date_str format: "2026-09-03T19:21:00-03:00"
    env["GIT_AUTHOR_DATE"] = date_str
    env["GIT_COMMITTER_DATE"] = date_str
    run_cmd(f'git commit -m "{message}"', env=env)

def main():
    if (repo_dir / ".git").exists():
        run_cmd('rmdir /s /q .git')
    
    run_cmd('git init')
    
    # Ignore Layout folder
    with open(repo_dir / ".gitignore", "a") as f:
        f.write("\nLayout FluxOS/\n")
    
    # Step 1: 03/09/2026 19:21 - Initial project structure
    # Add pubspec and basic main
    run_cmd('git add pubspec.yaml pubspec.lock android ios web windows macos linux .gitignore README.md analysis_options.yaml')
    main_dart_path = repo_dir / "lib" / "main.dart"
    
    main_dart_content = """import 'package:flutter/material.dart';
void main() { runApp(const MyApp()); }
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(title: 'FluxOS', home: Scaffold(body: Center(child: Text('FluxOS'))));
  }
}
"""
    main_dart_path.write_text(main_dart_content, encoding='utf-8')
    run_cmd('git add lib/main.dart')
    commit("2026-09-03T19:21:00-03:00", "Initial commit: cria projeto base Flutter")

    # Step 2: 04/09/2026 20:10 - Models and database core
    run_cmd('git add lib/models lib/services')
    commit("2026-09-04T20:10:00-03:00", "feat: adiciona modelos e serviço de banco de dados SQLite")

    # Step 3: 05/09/2026 21:07 - Core, theme and state provider
    run_cmd('git add lib/core lib/providers')
    commit("2026-09-05T21:07:00-03:00", "feat: adiciona tema e gerenciamento de estado global")

    # The script will continue and overwrite files and commit
    
if __name__ == "__main__":
    main()
