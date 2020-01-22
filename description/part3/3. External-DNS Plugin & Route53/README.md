## 4. External-dns plugin & Route53
`external-dns` 플러그인을 이용하면 ALB 생성 시, ALB Routing 규칙에 따른 Hostname 레코드를 Route53에 등록/관리 할 수 있습니다.<br>
즉, ALB 에 규칙 추가/변경 시, 수동으로 직접 Route53에 레코드 관리를 할 필요 없이, Ingress 설정만 가지고도 DNS Record 관리가 가능합니다.


### 4-1. 사전 요구사항
`external-dns` 역시 Worker Node 내에서 동작하는 방식으로, Pod가 배포된 Worker Node에는 Route53을 제어할 수 있는 IAM 권한이 필요합니다.

이 Workshop에서는 Terraform 을 통해 사전에 Route53 권한을 할당하였습니다. (참고 `eks_worker_node_r53_controll_policy.json`)

### 4-2. 설치하기

이 Workshop에서는 Ansible 을 통해 `external-dns` 설치를 하도록 합니다.

```
$ ansible-playbook -i "<YOUR_KUBECTL_COMMAND_EC2_IP>," -e "dns_host_zone=<YOUR_DNS_HOST>" playbooks/external-dns.yml

### example
$ ansible-playbook -i "13.125.170.172," -e "dns_host_zone=wondermz.com" playbooks/external-dns.yml
```

**참고 문서**
* [external-dns 설치](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/external-dns/setup/)

### 4-3. alb-ingress controller 를 이용한 record 추가
Record 추가는 ALB Ingress 가 배포되어 있는 경우, 자동으로 수집되어 추가됩니다.<br>
ingress 가 배포된게 없는 경우 아래와 같이 설정하여 배포하면 됩니다.

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    alb.ingress.kubernetes.io/healthcheck-path: /check
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: instance
    kubernetes.io/ingress.class: alb
  labels:
    app.kubernetes.io/name: aws-krug-alb-ingress
  name: awskrug-ingress
spec:
  rules:
    - host: console.wondermz.com
      http:
        paths:
          - backend:
              serviceName: console
              servicePort: 80
            path: /*
    - host: api.wondermz.com
      http:
        paths:
          - backend:
              serviceName: api
              servicePort: 80
            path: /*
```

### 4-4. 참고 사항
* `external-dns` 는 아직 alpha feature 입니다.
* 가급적 record 관리 방식은 upsert-only 로 하길 권장합니다. (dns 레코드 삭제/변경 시 레코드가 퍼지는 시간 고려)
* `external-dns` 는 namespace 별 관리 하는 편이 좋습니다. (프로젝트/환경별 dns 관리)