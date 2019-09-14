from collections import OrderedDict

import re
import oyaml as yaml
import os
import shutil


path = os.path.abspath(".")
repatter = re.compile("^__VAR__.*")



apps_manifests = [
    "api.yaml", # applcartion
    "redis.yaml",
    "ui.yaml",
    "db.yaml",
]

cluster_provisioning_manifests = [
    "ingress.yaml", # FQDN, Cert
    "mandatory.yaml",
    "cretificate.yaml",
    "cluster-issuer.yaml",
    "00-crds.yaml",
    "secret_cloudflare.yaml",
    "mandatory.yaml",# nginx ingress ctl
    "service-nodeport.yaml",
    "kube-flannel.yml", # flannel
    "monitering_manifests.yaml", # monitering
]

targets_dir ={
    "apps": apps_manifests,
    "cluster_provisioning": cluster_provisioning_manifests,
}

env_yaml_path =  "/env.yaml"
output_dir = "/deploy_ready_output"

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

    for dir, files in targets_dir.items():
        for file in files:
            if os.path.exists(path + "/" + dir +  "/" + file):
                with open(path + "/" + dir +  "/" + file) as f:
                    origin_yaml = list(yaml.load_all(f,Loader=yaml.UnsafeLoader))
                    write_yaml = search_val(origin_yaml, env_yaml[0])

                with open(path + output_dir + "/" + file, mode="w") as f:
                    f.write(yaml.dump_all(write_yaml))


if __name__ == "__main__":
    main()
