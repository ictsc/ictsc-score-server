# k8s setup
* required
    * terraform(0.12.5 <= x)
    * ansible(2.8.3 <= x)
    * terraform-provider-sakuracloud(1.15.2 <= x)
    * direnv
hint: [Terraform for さくらのクラウド](https://sacloud.github.io/terraform-provider-sakuracloud/installation/)
## claster setup
* 全て実行はこのカレントディレクトリで行ってください
* 事前準備として `.envrc` にさくらのクラウドのアクセストークンとシークレットとゾーンを書く。 `.envrc.sample` に例があるのでそこの `hoge` とかの変数をいい感じに埋めよう
* 埋めたら `direnv allow` で適用される。このカレントディレクトリでその環境変数が適用される。
* `terraform apply -auto-approve` をしてVMが上がるのを待とう。生成された `id_rsa` は `user:ubuntu` 向けに作られているものです
* `sh inventry.sh` でinventryfileを作成
* 事前準備として `var.yml`に 作成したいuserを書く。 `var.sample.yml` に例があるのでパスワードとかをいい感じに変えよう
* `ansible-playbook -u ubuntu --private-key=./id_rsa -i hosts setup.yml --extra-vars "ansible_sudo_pass=PUT_YOUR_PASSWORD_HERE"` でAnsibleを実行して、ictsc user作成とdocker install, k8s installが行なわれる
* これで` ssh -i ictsc ictsc@xxx.xxx.xxx.xxx` みたいな感じでログインできるようになります。
* masterになるサーバーにログインして`sudo kubeadm init --apiserver-advertise-address=192.168.100.1 --pod-network-cidr=10.244.0.0/16`をしよう。そこから出てきた情報をコピーして（`kubeadm join~~~`みたいなのがある）nodeになるサーバーに対してアクセスして貼り付けてsudoで実行しましょう。また、`mkdir -p $HOME/.kube`　みたいなのもコンソールに表示されていてコピペできるようになってるのでmasterサーバでやってください。これでkubectlが使えるようになります。
* masterになるサーバーで `kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml` をしてflannelをインストールしてください
* 
## TroubleShooting & Tips
* playbookを書き換えたら`ansible-playbook --private-key=./id_rsa -i hosts setup.yml --syntax-check` でいい感じに事前に構文チェックをしておくと良い。
* `terraform apply`が失敗したら`terraform destroy -force` とかで削除してから立て直す。
* [https://wiki.icttoracon.net/knowledge/score-server](https://wiki.icttoracon.net/knowledge/score-server)を参考にしている
* 接続先わかんなくなったら `terraform output`で接続先が確認できます。
* cloud-initとかこっちで書いてないのでrebootしたら `eth1` は消えます。
* 困ったらコンフィグ読んでほしい
