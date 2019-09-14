# k8s setup
* required
    * terraform(0.12.5 <= x)
    * ansible(2.8.3 <= x)
    * terraform-provider-sakuracloud(1.15.2 <= x)
    * direnv
    * pipenv & python3.7
hint: [Terraform for さくらのクラウド](https://sacloud.github.io/terraform-provider-sakuracloud/installation/)
## claster setup
* 全て実行はこのカレントディレクトリで行ってください
* 事前準備
    * `.envrc` にさくらのクラウドのアクセストークンとシークレットとゾーンを書く。 `.envrc.sample` に例があるのでそこの `hoge` とかの変数をいい感じに埋めよう
    * 埋めたら `direnv allow` で適用される。このカレントディレクトリでその環境変数が適用される。
    * `var.yml`に ansibleで作成したいuserを書く。 `var.sample.yml` に例があるのでパスワードとかをいい感じに変えよう
    * `wget https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml` を `cluster_provisioning`のディレクトリでしておく
* `terraform apply -auto-approve` をしてVMが上がるのを待とう。生成された `id_rsa` は `user:ubuntu` 向けに作られているものです
* `sh inventry.sh` でinventryfileを作成
* `ssh-keygen  -f ~/.ssh/ictsc` でこの名前の鍵を作成
* `ansible-playbook -u ubuntu --private-key=./id_rsa -i hosts setup.yml --extra-vars "ansible_sudo_pass=PUT_YOUR_PASSWORD_HERE"` でAnsibleを実行して、ictsc user作成とdocker install, k8s installが行なわれる
    * これで`ssh -i ictsc ictsc@xxx.xxx.xxx.xxx` みたいな感じでログインできるようになります。
* masterになるサーバーにログインして`sudo kubeadm init --apiserver-advertise-address=192.168.100.1 --pod-network-cidr=10.244.0.0/16`をしよう。そこから出てきた情報をコピーして（`kubeadm join~~~`みたいなのがある）nodeになるサーバーに対してアクセスして貼り付けてsudoで実行しましょう。また、`mkdir -p $HOME/.kube`　みたいなのもコンソールに表示されていてコピペできるようになってるのでmasterサーバでやってください。これでkubectlが使えるようになります。

## application setup
* `env.yaml`を作り、各パラメーターを埋める。 `env.sample.yaml` にテンプレートがあるのでパスワードとかFQDNをいい感じに変えよう
  * 別途FQDNの設定は自分でよしなにしておく必要があります。
* `pipenv install` をしたあと `pipenv shell` でサブシェルに入って `python deploy_ready.py` を叩く。これで各パラメーターを入れたk8sのmanifestが出来上がる。
* ここのカレントディレクトリで `scp -i ictsc -r ./deploy_ready_output ictsc@xxx.xxx.xxx.xxx:/home/ictsc`でmasterサーバーにファイルを転送する
  * ここでいうmasterServerというのは　`k8s-master-01-server` のことです。
* `https://helm.sh/docs/using_helm/#installing-helm` をしていい感じにinstallしてほしい

### Try kubectl apply!
kubectl applyした時に前後関係があるので気持ち1~2秒ずつ打っていくといいです
```sh
# flannelをinstall
# 全体の構成に必須なので一度のみ  
kubectl apply -f kube-flannel.yml

# nginx ingressをinstall
# 全体の構成に必須なので一度のみ  
kubectl apply -f mandatory.yaml

# cert-managerをinstall
# 全体の構成に必須なので一度のみ  
kubectl apply -f 00-crds.yaml
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v0.9.1 \
  jetstack/cert-manager
kubectl apply -f 00-crds.yaml

# cert-managerで動く証明書の設定
kubectl apply -f secret_cloudflare.yaml 
kubectl apply -f cluster-issuer.yaml
kubectl apply -f cretificate.yaml
kubectl apply -f ingress.yaml

# applicationのinstall
kubectl -f redis.yaml,ui.yaml,db.yaml,api.yaml,service-nodeport.yaml
```

これを通じて無事立ち上げることができました！

あとは
*  `kubectl exec -it pod/api-5f9cd6794-9z9sr rails db:setup`みたいな感じで初期データ流し込みをする
* `http://xxx.xxx.xxx.xxx:/`にアクセスできてloginができたら無事一通り立ってる感じ。おめでとう！

## その他
* `kubectl apply -f monitering_manifests.yaml` で同一クラスタ内にnodeexpoterなどの諸々監視を実行することができます

## TroubleShooting & Tips
* `terraform apply`が失敗したら`terraform destroy -force` とかで削除してから立て直す。
* playbookを書き換えたら`ansible-playbook --private-key=./id_rsa -i hosts setup.yml --syntax-check` でいい感じに事前に構文チェックをしておくと良い。
* kubeadmでコピー忘れたら雑に `kubeadm reset` でjoinやinitしてた情報ごと削除できる
* `kubectl delete -f redis.yaml,ui.yaml,db.yaml,api.yaml`で削除。
    * もしマニフェストファイルを変更する場合は削除してから書き換えて適用する方が良い。
* `kubectl get all` で上がってるかどうかとか見れる。READYが1/1ならあがっているということ。0/1ならログを見てみたりしよう。
  * `kubectl logs <pod name>`で可能
* 時々DBが上がるのが失敗したりするのでそのときはログ(ex. kubectl logsやkubectl describe pod)見てから kubectl deleteしてapplyをして見てみる
* [https://wiki.icttoracon.net/knowledge/score-server](https://wiki.icttoracon.net/knowledge/score-server)を参考にしている
* 接続先わかんなくなったら `terraform output`で接続先が確認できます。
* 雑にクラスタを作るための物なのでterraformのパラメーターやディフォルトパスワードとして設定してる `PUT_YOUR_PASSWORD_HERE`とかはよしなに変えることとをお勧めします。（普通に利用する分にはその都度生成される秘密鍵のみの接続になるので問題はないです）
