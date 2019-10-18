## 5. Resource Destory
Workshop 에서 사용한 Resource 를 정리 할 때, 아래 순서를 꼭 지켜야 합니다.

* kubectl 명령을 통해 ALB Ingress, NLB, CLB 등을 먼저 제거
* Terraform 을 이용해 전체 Infrastructure destory

```
$ k delete ns default
```

```
$ tf destroy -var-file local.tfvars -var='kubectl_ec2_keypair=aws_krug_workshop'
```