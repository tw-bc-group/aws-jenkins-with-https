## session-manager module 用法

### Description

Provision [SSM Documents](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-configure-preferences-cli.html),
[EC2 Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) and
[Instance Profiles for Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-instance-profile.html).

This module provides recommended settings:

- No open inbound ports
- Loggable session activity

### Module 用法
#### Minimal without ec2 instance

```hcl
module "session_manager" {
  source        = "./modules/ec2-session-manager/"
}
// From this session_manager module, you can get iam_instance_profile_id and other variables, you can see the variables list in output.tf file.
```

#### Minimal with ec2 instance

```hcl
module "session_manager" {
  source        = "./modules/ec2-session-manager/"
  name          = "example"
  instance_type = "t2.micro"
  subnet_id     = "${var.subnet_id}"
  vpc_id        = "${var.vpc_id}"
}
```

#### Complete

```hcl
module "session_manager" {
  source        = "./modules/ec2-session-manager/"
  name          = "example"
  instance_type = "t2.micro"
  subnet_id     = "${var.subnet_id}"
  vpc_id        = "${var.vpc_id}"

  ssm_document_name             = "SSM-SessionManagerRunShell-for-example"
  s3_bucket_name                = "${var.s3_bucket_name}"
  s3_key_prefix                 = "prefix"
  s3_encryption_enabled         = false
  cloudwatch_log_group_name     = "${var.cloudwatch_log_group_name}"
  cloudwatch_encryption_enabled = false
  ami                           = "${var.ami}"
  vpc_security_group_ids        = ["${var.vpc_security_group_ids}"]
  iam_policy                    = "${var.iam_policy}"
  iam_path                      = "/service-role/"
  description                   = "This is example"

  tags = {
    Environment = "prod"
  }
}
```

### Inputs

| Name                          | Description                                                           |  Type  |           Default            | Required |
| ----------------------------- | --------------------------------------------------------------------- | :----: | :--------------------------: | :------: |
| instance_type                 | The type of instance to start.                                        | string |              -               |   yes    |
| name                          | The name of the Session Manager.                                      | string |              -               |   yes    |
| subnet_id                     | The VPC Subnet ID to launch in.                                       | string |              -               |   yes    |
| vpc_id                        | The VPC ID.                                                           | string |              -               |   yes    |
| ami                           | The AMI to use for the instance.                                      | string |           `` | no            |
| cloudwatch_encryption_enabled | Specify true to indicate that encryption for CloudWatch Logs enabled. | string |            `true`            |    no    |
| cloudwatch_log_group_name     | The name of the log group.                                            | string |           `` | no            |
| description                   | The description of the all resources.                                 | string |    `Managed by Terraform`    |    no    |
| iam_path                      | Path in which to create the IAM Role and the IAM Policy.              | string |             `/`              |    no    |
| iam_policy                    | The policy document. This is a JSON formatted string.                 | string |           `` | no            |
| s3_bucket_name                | The name of the bucket.                                               | string |           `` | no            |
| s3_encryption_enabled         | Specify true to indicate that encryption for S3 Bucket enabled.       | string |            `true`            |    no    |
| s3_key_prefix                 | The prefix for the specified S3 bucket.                               | string |           `` | no            |
| ssm_document_name             | The name of the document.                                             | string | `SSM-SessionManagerRunShell` |    no    |
| tags                          | A mapping of tags to assign to all resources.                         |  map   |             `{}`             |    no    |
| user_data                     | The user data to provide when launching the instance.                 | string |           `` | no            |
| vpc_security_group_ids        | A list of security group IDs to associate with.                       |  list  |             `[]`             |    no    |


### session manager 用法：
1. 通过网页端 AWS 控制台：
* 登陆到 [AWS System Manager](https://console.aws.amazon.com/systems-manager)
* 在左侧目录面板中选择 **Session Manager**，点击进入
* 点击 **start session**，可以在 instance list 中选择希望操作的 instance
* 之后就会挑转到基于网页的 shell 界面，可以输入命令对 ec2 的 instance 进行操作（默认的 user 是 ***ssm_user***）

2. 通过 AWS CLI 连接：
* [安装 AWS CLI](https://docs.amazonaws.cn/cli/latest/userguide/cli-chap-install.html)【推荐在虚拟环境中安装】
* [为 AWS CLI 安装 Session Manager Plugin](https://docs.aws.amazon.com/zh_cn/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
* 配置 AWS CLI 的 Credential：`aws configure`
```bash
# Log as follow:
$ aws configure
AWS Access Key ID [****************JMU7]: A*************Q
AWS Secret Access Key [****************/JEe]: e*************1
Default region name [cn-north-1]: us-west-2
Default output format [None]:
```
* 连接 EC2 Instance：`aws ssm start-session --target instance-id`(instance-id 为 EC2 实例 ID，可在 AWS EC2 的控制面板中获得)

### 要能够正常使用 session manager 的前置条件：
* EC2 实例要 attach 一个具有 `AmazonEC2RoleforSSM` 权限的 IAM Role
* EC2 实例上要安装好 SSM Agent。
> 默认情况下，SSM 代理 预先安装在以下 Amazon 系统映像 (AMI) 上：  
  2006 年 11 月或以后发布的 Windows Server 2003-2012 R2 AMI 
  Windows Server 2016 和 2019  
  Amazon Linux  
  Amazon Linux 2  
  Ubuntu Server 16.04  
  Ubuntu Server 18.04
  ----- 该数据来自 AWS 官网 - [使用 SSM 代理](https://docs.aws.amazon.com/zh_cn/systems-manager/latest/userguide/ssm-agent.html)
  
  如果 instance 启动起来后，发现仍然无法通过 Session Manager 访问，可以参考如下链接手动安装 SSM Agent：
  [在 Amazon EC2 Linux 实例上手动安装 SSM 代理](https://docs.aws.amazon.com/zh_cn/systems-manager/latest/userguide/sysman-manual-agent-install.html)

* 进入到 System Manager 的用户，应该具有 SSM 的权限

### 参考文档
* [什么是 AWS Systems Manager？](https://docs.aws.amazon.com/zh_cn/systems-manager/latest/userguide/what-is-systems-manager.html)
* [排除 Session Manager的故障](https://docs.aws.amazon.com/zh_cn/systems-manager/latest/userguide/session-manager-troubleshooting.html#session-manager-troubleshooting-instances)
* [新功能 – AWS Systems Manager Session Manager 支持通过 Shell 访问 EC2 实例 -- AWS 官方博客](https://aws.amazon.com/cn/blogs/china/new-session-manager/#)
* [Securing Amazon EC2 Instances](https://aws.amazon.com/answers/security/aws-securing-ec2-instances/)
* [Controlling EC2 OS Access](https://aws.amazon.com/cn/answers/security/aws-controlling-os-access-to-ec2/?nc1=h_ls)
* [Additional Sample IAM Policies for Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-examples.html)