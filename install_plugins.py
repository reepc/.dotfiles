import os

file = "./zsh_plugins.list"

with open(file, "r") as f:
    for line in f.readlines():
        url = line.strip()
        target_path = f"{os.environ['HOME']}/.oh-my-zsh/custom/plugins/{url.split('/')[-1].replace('.git', '')}"
        if not os.path.exists(target_path):
            os.system(f"git clone {url} {target_path}")
        else:
            print(f"Plugin {url} already installed.")