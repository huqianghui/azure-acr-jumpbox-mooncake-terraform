# azure-acr-jumpbox-mooncake-terraform

为了从azure global 适配到mooncake，做了如下几点变更。

1. terraform provide 需要增加china环境配置。

2. 为了提升vhdx文件下载速度，把对应文件保存到mooncake的blob storage。

3. 因为在mooncake上，北三没有azure arc，同时东二北二开不出来资源， 所以host的location在北三，但是azure arc在东二。需要修改里面配置。

4. 默认的认证都是az global，也需要登录到 azureChinaCloud

5. 因为mooncake目前还没有azure arc enabled kubernetes 和 azure arc enabled data service。所以删除掉了这两部分内容。只保留了azure arc enbaled server 这一部分。

最后运行结果如下：

<img width="1440" alt="Screen Shot 2023-03-26 at 12 25 10 PM" src="https://user-images.githubusercontent.com/7360524/228122259-d44f152b-d2f4-4898-ba5b-93024e4e7bff.png">

<img width="1440" alt="Screen Shot 2023-03-26 at 12 25 19 PM" src="https://user-images.githubusercontent.com/7360524/228122262-2fa75f4b-7fcb-4fa4-92f8-cac7cd5ecee8.png">
