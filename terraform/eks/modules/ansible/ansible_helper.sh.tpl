#!/bin/bash

ansible-playbook -i \""${target_ec2_ip},"\" -e \""eks_cluster_name=${eks_cluster_name} eks_worker_role_arn=${eks_worker_role_arn} "\" playbooks/kubectl.yml