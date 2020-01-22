#!/bin/bash

ansible-playbook -i \""${target_ec2_ip},"\" -e \""@var-file.yml"\" playbooks/kubectl.yml