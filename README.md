## AWS Jenkins server with HTTPS cert enable

### Prerequisite
* 需要有一个域名
* 需要有 [CloudFlare](https://dash.cloudflare.com) 账户
* 在 CloudFlare 中添加一个 Site 为你的域名
> 此时无需添加任何 DNS 解析的 record，只需保证能用 CloudFlare 解析域名即可
* 安装 [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
* 在[这里](https://dash.cloudflare.com/profile)获取 CloudFlare 的 API Keys，找到 `Global API Key`，点击右侧 `View` 即可获得该 API Key

> 关于 HTTPS Certificate 相关内容，请参考 [https-certificate/README.md](https-certificate/README.md)

### Usage

* 将 `secret.auto.tfvars.example` 文件拷贝并更名为 `secret.auto.tfvars`，并填充文件内 `access_key` 和 `secret_key` 等值为 aws 账户真实的值。
* 将 `terraform.tfvars.example` 文件拷贝并更名为 `terraform.tfvars`，并填充文件内所有变量为真实的值。
> 该脚本暂时只支持对于 Ubuntu 系统的自动化，因此建议其中 ami 变量选择 Ubuntu 系统的 Instance
* 执行 `terraform init` 初始化 terraform module。
* 执行 `terraform plan` 预演 terraform 在真实执行时，会更改（新建、删除、更新）的 aws resource。
* 若 `terraform plan` 执行无误，且查看其输出为期望的 resource 结果时，执行 `terraform apply` 执行 terraform 脚本。
* 若 `terraform apply` 执行无误，则可以在输出 log 中看到 `jenkins_public_ip`，为 Jenkins 的公有 IP 地址。
* 至 [CloudFlare](https://dash.cloudflare.com) 对 Jenkins 公有 IP 进行 DNS 解析，添加 A record 即可。
* 等待一段 DNS 的解析时间，则可以通过 `https://your-domain:https_port` 访问，若看到 Jenkins 登陆页面，则证明脚本运行成功。
> 可以通过 `dig your-domain` 或者 `dig trace your-domain` 或者 `nslookup your-domain` 三条命令，查看命令的返回值是否为 Jenkins 的公有 Ip 的值。