# k8s setup
* required
    * terraform(0.12.5 <= x)
    * ansible(2.8.3 <= x)
    * terraform-provider-sakuracloud(1.15.2 <= x)
    * direnv
hint: [Terraform for さくらのクラウド](https://sacloud.github.io/terraform-provider-sakuracloud/installation/)
## claster setup
* 全て実行はこのカレントディレクトリで行ってください
* 事前準備
     `.envrc` にさくらのクラウドのアクセストークンとシークレットとゾーンを書く。 `.envrc.sample` に例があるのでそこの `hoge` とかの変数をいい感じに埋めよう
    * 埋めたら `direnv allow` で適用される。このカレントディレクトリでその環境変数が適用される。
    * `var.yml`に ansibleで作成したいuserを書く。 `var.sample.yml` に例があるのでパスワードとかをいい感じに変えよう
* `terraform apply -auto-approve` をしてVMが上がるのを待とう。生成された `id_rsa` は `user:ubuntu` 向けに作られているものです
* `sh inventry.sh` でinventryfileを作成
* `ansible-playbook -u ubuntu --private-key=./id_rsa -i hosts setup.yml --extra-vars "ansible_sudo_pass=PUT_YOUR_PASSWORD_HERE"` でAnsibleを実行して、ictsc user作成とdocker install, k8s installが行なわれる
    * これで` ssh -i ictsc ictsc@xxx.xxx.xxx.xxx` みたいな感じでログインできるようになります。
* masterになるサーバーにログインして`sudo kubeadm init --apiserver-advertise-address=192.168.100.1 --pod-network-cidr=10.244.0.0/16`をしよう。そこから出てきた情報をコピーして（`kubeadm join~~~`みたいなのがある）nodeになるサーバーに対してアクセスして貼り付けてsudoで実行しましょう。また、`mkdir -p $HOME/.kube`　みたいなのもコンソールに表示されていてコピペできるようになってるのでmasterサーバでやってください。これでkubectlが使えるようになります。
* ここのカレントディレクトリで`wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml` をして `scp -i ictsc -r ../k8s ictsc@xxx.xxx.xxx.xxx:/home/ictsc`でmasterサーバーにファイルを転送する
* `kubectl apply -f kube-flannel.yml,redis.yaml,ui.yaml,db.yaml,api.yaml`でupする
* ポートのレンジの都合上それを変更する適用を現状書く必要がある。
```
$ sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
 ~~~~~
spec:
  containers:
  - command:
    - kube-apiserver
    ~~~~~~
    - --service-node-port-range=80-32767
$ sudo systemctl restart kubelet
```
みたいにすると良い。

*  `kubectl exec -it pod/api-5f9cd6794-9z9sr rails db:setup`みたいな感じで初期データ流し込みをする
* 
## TroubleShooting & Tips
* `terraform apply`が失敗したら`terraform destroy -force` とかで削除してから立て直す。
* playbookを書き換えたら`ansible-playbook --private-key=./id_rsa -i hosts setup.yml --syntax-check` でいい感じに事前に構文チェックをしておくと良い。
* kubeadmでコピー忘れたら雑に `kubeadm reset` でjoinやinitしてた情報ごと削除できる
* `kubectl delete -f kube-flannel.yml,redis.yaml,ui.yaml,db.yaml,api.yaml`で削除。
    * もしマニフェストファイルを変更する場合は削除してから書き換えて適用する方が良い。
* log
* `kubectl get all` で上がってるかどうかとか見れる。READYが1/1ならあがっているということ。0/1ならログを見てみたりしよう。
* 時々DBが上がるのが失敗したりするのでそのときはログ(ex. kubectl logsやkubectl describe pod)見てから kubectl deleteしてapplyをして見てみる
* [https://wiki.icttoracon.net/knowledge/score-server](https://wiki.icttoracon.net/knowledge/score-server)を参考にしている
* 接続先わかんなくなったら `terraform output`で接続先が確認できます。
