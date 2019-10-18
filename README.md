# 소개
Kubernetes 가 화두가 된지는 이미 조금 되었지만, AWS의 EKS를 주제로 실제 사용한 경험을 바탕으로 hands-on을 포함하여 진행한 모임은 많지 않아 준비해 보았습니다.

이미 온라인에는 EKS workshop 에 촛점이 맞춰진 hands-on 자료는 많습니다.
* [EKS Workshop](https://github.com/stevenshim/easy-ssh-ec2)
  * eksctl 명령어를 사용함.
* [aws-quickstart-amazon-eks](https://github.com/aws-quickstart/quickstart-amazon-eks)
  * cloudformation 을 사용함.

다만, 근래 많이 사용되고 있는 3rd party tools인 Terraform 과 Ansible 을 활용하여 EKS 를 구축하는 workshop 을 준비하였습니다.

기존에 흔히 접하는 workshop 에서는 설명이 자세하지 않았지만, 실제 환경을 운영중에 꼭 알아야 하는 놓칠 수 있는 정보들을 좀 더 자세히 보기로 했습니다.

이 자료는 아래의 지식을 필요로 합니다.
* AWS 의 EC2, VPC, IAM 등의 기본 지식과 실제 사용 경험
* Docker Container 의 기본 지식과 실제 사용 경험
* 3rd party tools (Terraform, Ansible) 의 기본 지식과 실제 사용 경험
* Kubernetes 관련 기본 지식

# 톺아보기
* [Part 1 - EKS 시작하기](description/part1/README.md)
* [Part 2 - EKS 살펴보기 (AWS Resource 제어 관련)](description/part2/README.md)