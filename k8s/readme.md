# k8s setup
* required
    * terraform(0.12.5 <= x)
    * ansible(2.8.3 <= x)
    * terraform-provider-sakuracloud(1.15.2 <= x)
    * direnv
hint: [Terraform for さくらのクラウド](https://sacloud.github.io/terraform-provider-sakuracloud/installation/)
## claster setup
事前準備として
* `.envrc` にさくらのクラウドのアクセストークンとシークレットとゾーンを書く。 `.envrc.sample` に例があるのでそこの `hoge` とかの変数をいい感じに埋めよう
* 埋めたら `direnv allow` で適用される。このカレントディレクトリでその環境変数が適用される。
* `terraform apply -auto-approve` をしてVMが上がるのを待とう
* `sh inventry.sh` とかでhostsを作成
* `var.yml`に 作成したいuserを書く。 `var.sample.yml` に例があるのでパスワードとかをいい感じに変えよう
* `ansible-playbook -u ubuntu --private-key=./id_rsa -i hosts setup.yml --extra-vars "ansible_sudo_pass=PUT_YOUR_PASSWORD_HERE"` でAnsibleを実行して、ictsc user作成とdocker install, k8s installが行なわれる
* 


## TroubleShooting & Tips
* `ansible-playbook --private-key=./id_rsa -i hosts setup.yml --syntax-check` でいい感じに事前に構文チェックをしておくと良い。
* `terraform apply`が失敗したら`terraform destroy -force` とかで削除してから立て直す。
