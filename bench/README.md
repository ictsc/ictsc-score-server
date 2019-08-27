# APIの簡易ベンチマークスクリプト

## Install

```sh
pip install locustio
```

## Lunch

APIサーバーが動いているサーバーを指定してLocustを起動する。  

```sh
locust --host=http://localhost:8900
```

自身の `http://localhost:8089` でLocustのWebインターフェースが起動している。  

* `Number of users to simulate` 最大ユーザー数
* `Hatch rate` 1秒あたりのユーザー増加数
