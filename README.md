# 소개
Kubernetes 가 화두가 된지는 이미 조금 되었지만, AWS의 EKS를 주제로 실제 사용한 경험을 바탕으로 hands-on을 포함하여 진행한 모임은 많지 않아 준비해 보았습니다.

이미 온라인에는 EKS workshop 에 촛점이 맞춰진 좋은 hands-on 자료는 많습니다. <br>
다만, 실무에서 많이 사용되고 있는 3rd party tools 을 활용한 Hands-on 자료는 부족하기에, 이번 기회에 사용 경험을 바탕으로 Terraform 과 Ansible을 활용한 EKS 를 구축하는 workshop 을 준비하였습니다.<br>
또한 실제 환경 구축/운영 중에 놓칠 수 있는 실무 노하우를 포함하여 자료를 구성했습니다.

기존에 널리 알려진 Hands-on 자료는 아래 링크에서 참고할 수 있습니다.
* [EKS Workshop](https://github.com/stevenshim/easy-ssh-ec2)
* [aws-quickstart-amazon-eks](https://github.com/aws-quickstart/quickstart-amazon-eks)

## Prerequisites
이 자료는 아래의 지식을 필요로 합니다.
* AWS 의 EC2, VPC, IAM 등의 AWS Core Services 의 기초 지식
* 3rd party tools (Terraform, Ansible) 의 기초 지식
* Docker Container 의 기초 지식
* Kubernetes 관련 기초 지식

## 톺아보기
* [Part 1 - EKS 시작하기 (Automation 기반 구성)](description/part1/)
* [Part 2 - EKS 살펴보기 (EKS에서 AWS Resource 제어)](description/part2/)

