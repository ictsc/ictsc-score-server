from collections import OrderedDict

import re
import oyaml as yaml
import os
import shutil


path = os.path.abspath(".")
repatter = re.compile("^__VAR__.*")


targets_file = [
    "api.yaml", # applcartion
    "redis.yaml",
    "ui.yaml",
    "db.yaml",
    "ingress.yaml", # FQDN, Cert
    "mandatory.yaml",
    "cretificate.yaml",
    "cluster-issuer.yaml",
    "prometeheus-configmap.yaml", # monitering
]

env_yaml_path =  "/env.yaml"
output_dir = "/deploy_ready_output"


class PyColor:
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    PURPLE = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"
    END = "\033[0m"
    BOLD = "\038[1m"
    UNDERLINE = "\033[4m"
    INVISIBLE = "\033[08m"
    REVERCE = "\033[07m"



def search_val(yaml_ctx, env_yaml: dict):

    if isinstance(yaml_ctx, str):
        match = repatter.match(yaml_ctx)
        if match:
            match_string = match.group()
            # print(match_string)
            # print(env_yaml[match_string])
            yaml_ctx = env_yaml[match_string]

    elif isinstance(yaml_ctx, list):
        for x in range(len(yaml_ctx)):
            yaml_ctx[x] = search_val(yaml_ctx[x], env_yaml)

    elif isinstance(yaml_ctx, dict):
        keys = yaml_ctx.keys()
        for key in keys:
            yaml_ctx[key] = search_val(yaml_ctx[key], env_yaml)

    return yaml_ctx


def main():
    if os.path.exists(path + output_dir):
        shutil.rmtree(path + output_dir)

    os.mkdir(path + output_dir)

    with open(path + env_yaml_path) as f:
        env_yaml = list(yaml.load_all(f,Loader=yaml.UnsafeLoader))

    for e in targets_file:
        if os.path.exists(path + "/" + e):
            with open(path + "/" + e ) as f:
                origin_yaml = list(yaml.load_all(f,Loader=yaml.UnsafeLoader))
                write_yaml = search_val(origin_yaml, env_yaml[0])
                print(write_yaml)
            with open(path + output_dir + "/" + e, mode="w") as f:
                yaml.dump(write_yaml,f)


if __name__ == "__main__":
    main()
