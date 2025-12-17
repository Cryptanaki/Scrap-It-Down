import sys
import subprocess
import os

try:
    import yaml
except Exception:
    print('PyYAML not found; installing...')
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pyyaml'])
    import yaml

def validate_path(target_path):
    files = []
    if os.path.isdir(target_path):
        for name in os.listdir(target_path):
            if name.endswith('.yml') or name.endswith('.yaml'):
                files.append(os.path.join(target_path, name))
    elif os.path.isfile(target_path):
        files.append(target_path)
    else:
        raise SystemExit(f'Path not found: {target_path}')

    if not files:
        print('No workflow files found')
        return

    for f in files:
        print(f'Validating {f}')
        try:
            with open(f, 'r', encoding='utf-8') as fh:
                yaml.safe_load(fh)
        except Exception as e:
            print(f'YAML parse error in: {f}', file=sys.stderr)
            raise
    print('All workflow YAML files parsed successfully.')


if __name__ == '__main__':
    target = sys.argv[1] if len(sys.argv) > 1 else os.path.join('.', '.github', 'workflows')
    validate_path(target)
