## 3. ALB Ingress controller
EKS에서 Ingress를 ALB를 활용해 사용하려면 아래와 같은 추가 조치가 필요합니다.
* IAM 설정 변경
* ALB Ingress Controller Plugin 설치

**관련문서**
* [AWS Doc: ALB Ingress Controller](https://docs.aws.amazon.com/en_pv/eks/latest/userguide/alb-ingress.html)
* [Github: ALB Ingress Controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller)
* [Workshop: ALB Ingress Controller](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation/)

### 3-1. Kubelet 사전 설정 체크하기
`kubelet` 은 `--cloud-provier=aws` 을 포함하여 실행되어야 합니다.

이 Workshop에서는 Worker Node가 모두 AWS에서 제공하는 EKS 최적화 AMI를 사용하므로 `--cloud-provider=aws` 설정은 이미 적용되어 있습니다.

아래 내용은 Worker Node에서 직접 `kubelet`이 어떻게 실행되었는지 확인해본 내용입니다.
```
$ ps -ef | grep kubelet
root      3689     1  1 04:42 ?        00:00:29 /usr/bin/kubelet --cloud-provider aws --config /etc/kubernetes/kubelet/kubelet-config.json --kubeconfig /var/lib/kubelet/kubeconfig --container-runtime docker --network-plugin cni --node-ip=172.16.10.80 --pod-infra-container-image=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/eks/pause-amd64:3.1
```

### 3-2. IAM 권한 설정하기
앞으로 설치될 ALB Ingress Controller Plugin은 EKS Master 에서 직접 제공하는 기능이 아니라, 사용자의 Worker Node에 별도의 pod가 생성되어 ALB를 제어하는 방식입니다.<br>
따라서, Worker Node에는 ALB 제어와 관련된 권한이 필요합니다.

**NOTE**
<br>
본 Workshop의 Terraform 을 이용해 설치 한 경우, 이미 적용이 완료되어있습니다.

**적용 방법**

1. AWS Console의 IAM 메뉴로 이동합니다.
2. Roles 메뉴로 이동합니다.
3. EKS Worker Node에 적용된 Role을 선택합니다. (Workshop에서는 eks_worker_nodes_role)
4. Permission 탭 중, 우측에 Add inline policy 를 선택합니다.
5. JSON 탭에 이동하여 `worker_node_role_alb_control_policy.json`의 내용을 복하사여 넣은 뒤 Review 로 넘어갑니다.
6. 이해하기 쉬운 이름을 지정 후 저장합니다. (예: eks-worker-node-alb-control-policy)


### 3-3. ALB Ingress Controller Plugin 설치하기
ALB Ingress Controller Plugin은 아래 설치 방법들을 제공합니다.
* `helm` 을 이용한 설치 방법.
* `kubectl` 명령을 직접 수행하여 설치하는 방법.

이 Workshop 에서는 Ansible 명령(`playbooks/roles/kubectl/tasks/alb-ingress-controller.yml` 참조)을 통해 이미 설치가 완료되어 있습니다.

수동 설치는 아래 문서를 참고하시기 바랍니다.

**참고문서**
* [ALB Ingress Controller 설치하기](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/controller/setup/#installation)


### 3-4. Ingress 만들기

아래와 같이 `alb-ingress.yaml`을 생성합니다.

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
    - host: console.awskrug.com
      http:
        paths:
          - backend:
              serviceName: console
              servicePort: 80
            path: /*
    - host: api.awskurg.com
      http:
        paths:
          - backend:
              serviceName: api
              servicePort: 80
            path: /*
```
```
$ k create -f alb-ingress.yaml
$ k get ing
```

#### ALB Ingress Controller 상태 확인하기
이 Workshop 에서는 ALB Ingress Controller 를 kube-system Namespace에 배포하였습니다.

아래 처럼 log를 기반으로 분석할 수 있습니다.
```
$ k logs -n kube-system $(kubectl get po -n kube-system | egrep -o "alb-ingress[a-zA-Z0-9-]+")
```

#### ALB Ingress 생성 실패 경우
KubeDNS / CoreDNS 는 Worker Node 에 설치 되는데 Ingress Controller 가 DNS Lookup을 못 하는 경우가 있을 수 있습니다. <br>
Worker의 Security Group 규칙에 Worker Node 사이에 UDP 53 포트가 허용되어 있어야 합니다.

Error Log - timeout
```
E1018 06:02:05.933771       1 :0] kubebuilder/controller "msg"="Reconciler error" "error"="failed to build LoadBalancer configuration due to failed to get AWS tags. Error: RequestError: send request failed\ncaused by: Post https://tagging.ap-northeast-2.amazonaws.com/: dial tcp: i/o timeout"  "controller"="alb-ingress-controller" "request"={"Namespace":"default","Name":"awskrug-ingress"}
```

