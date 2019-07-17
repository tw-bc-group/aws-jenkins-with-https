## HTTPS 证书自动安装

### Prerequisite

* 需要有一个域名
* 需要将该域名采用[CloudFlare](https://dash.cloudflare.com)进行 DNS 解析
> 因为 CloudFlare 可编程，可以通过获取 CloudFlare 下的 key 之后通过 CloudFlare 的 API 自动向域名中添加 DNS Record，以此来自动化 HTTPS 颁发过程中的域名 challenge 步骤
* 在[这里](https://dash.cloudflare.com/profile)获取 CloudFlare 的 API Keys，找到 `Global API Key`，点击右侧 `View` 即可获得该 API Key

### Usage

```bash
./issue_ssl_certificate.sh example.com **CF_Key**  **CF_Email**
# 证书将会被颁发在 ~/.acme.sh/example.com 文件夹下
# Logs as follow:
# -----END CERTIFICATE-----
#  [Mon Jul  1 07:32:13 UTC 2019] Your cert is in  /home/ubuntu/.acme.sh/example.com/example.com.cer
#  [Mon Jul  1 07:32:13 UTC 2019] Your cert key is in  /home/ubuntu/.acme.sh/example.com/example.com.key
#  [Mon Jul  1 07:32:13 UTC 2019] The intermediate CA cert is in  /home/ubuntu/.acme.sh/example.com/ca.cer
#  [Mon Jul  1 07:32:13 UTC 2019] And the full chain certs is there:  /home/ubuntu/.acme.sh/example.com/fullchain.cer
```

### Renew HTTPS Cert

由于我们采用了 acme.sh 的脚本，当 acme.sh 安装成功之后，它就会自动的创建一个 cron job，daily 的对证书进行检查和更新。
可以通过 `crontab -l` 查看如下：
```bash
$ crontab -l
> 8 0 * * * "/home/ubuntu/.acme.sh"/acme.sh --cron --home "/home/ubuntu/.acme.sh" > /dev/null
# '8 0 * * *'代表: 每日 0 时 8 分执行 job
```

因此，理论上我们不用手动的更新证书，所有的证书都会被自动更新。
但如果真的想更新证书的话，可以通过如下命令对证书进行更新：
```bash
$ acme.sh --renew -d example.com --force
# Logs as follow:
# [Tue Jul  2 10:15:22 UTC 2019] Renew: 'example.com'
# [Tue Jul  2 10:15:23 UTC 2019] Single domain='example.com'
# [Tue Jul  2 10:15:23 UTC 2019] Getting domain auth token for each domain
# [Tue Jul  2 10:15:23 UTC 2019] Getting webroot for domain='example.com'
# [Tue Jul  2 10:15:23 UTC 2019] example.com is already verified, skip dns-01.
# [Tue Jul  2 10:15:23 UTC 2019] Verify finished, start to sign.
# [Tue Jul  2 10:15:23 UTC 2019] Lets finalize the order, Le_OrderFinalize: https://acme-v02.api.letsencrypt.org/acme/finalize/60345109/652840377
# [Tue Jul  2 10:15:25 UTC 2019] Download cert, Le_LinkCert: https://acme-v02.api.letsencrypt.org/acme/cert/03a7773e87a105da2d07eb47052bbc60d112
# [Tue Jul  2 10:15:25 UTC 2019] Cert success.
# -----BEGIN CERTIFICATE-----
# MIIFTjCCBDagAwIBAgISA6d3Po
# ......
# WyjrSxvgyvapJdjnK/N/3PaZ
# -----END CERTIFICATE-----
# [Tue Jul  2 10:15:25 UTC 2019] Your cert is in  /home/ubuntu/.acme.sh/example.com/example.com.cer
# [Tue Jul  2 10:15:25 UTC 2019] Your cert key is in  /home/ubuntu/.acme.sh/example.com/example.com.key
# [Tue Jul  2 10:15:25 UTC 2019] The intermediate CA cert is in  /home/ubuntu/.acme.sh/example.com/ca.cer
# [Tue Jul  2 10:15:25 UTC 2019] And the full chain certs is there:  /home/ubuntu/.acme.sh/example.com/fullchain.cer
```

### Scope

通过此脚本只能用来颁发 HTTPS 证书，至于要如何使用该 HTTPS 证书，此脚本暂时不涉及，请暂时自行配置。