# ICTSC Score Server Web UI

## Run Production

```
cd ~
git clone ***
cd ui
npm install
npm run build:prod
```

以上のコマンドで `/dist/ ディレクトリに静的ファイルが生成されます。

## Deploy Nginx

```
server {
  listen 80 default_server;
  root /home/ubuntu/ictsc-score-server/ui/dist;
  index index.html;

  location /api {
    proxy_pass "http://****/api";
    proxy_set_header origin "http://****";
    proxy_set_header referer "http://****";
  }

  location / {
    try_files $uri $uri/ /index.html =404;
  }
}
```
