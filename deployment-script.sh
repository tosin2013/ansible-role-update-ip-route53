#!/bin/bash 

if [ ! -f .env ]; then
  echo "Environment file not found"
  exit 1
else
    source .env
fi

if [ ! -f /tmp/requirements.yml ]; then
  cat >/tmp/requirements.yml<<EOF
---
collections:
- amazon.aws
- community.general
- ansible.posix
roles: 
- name: ansible_role_update_ip_route53
    src: https://github.com/tosin2013/ansible-role-update-ip-route53.git
    version: master
EOF
fi

# Ensure required environment variables are set
: "${AWS_ACCESS_KEY:?Environment variable AWS_ACCESS_KEY is required}"
: "${AWS_SECRET_KEY:?Environment variable AWS_SECRET_KEY is required}"
: "${IP_ADDRESS:?Environment variable IP_ADDRESS is required}"
: "${ZONE_NAME:?Environment variable ZONE_NAME is required}"
: "${GUID:?Environment variable GUID is required}"
: "${ACTION:?Environment variable ACTION is required}"
: "${VERBOSE_LEVEL:?Environment variable VERBOSE_LEVEL is required}"


ansible-galaxy install -r /tmp/requirements.yml --force -vv
pip3 install boto3 botocore


CLUSTER_NAME="sample-cluster"
cat >/tmp/playbook.yml<<EOF
- name: Populate OpenShift DNS Entries
  hosts: localhost
  connection: local
  become: yes

  vars:
  - update_ip_r53_aws_access_key:  ${AWS_ACCESS_KEY}
  - update_ip_r53_aws_secret_key: ${AWS_SECRET_KEY}
  - use_public_ip: true
  - private_ip: "${IP_ADDRESS}"
  - update_ip_r53_records:
    - zone: ${ZONE_NAME}
      record: api.${CLUSTER_NAME}.${GUID}.${ZONE_NAME}
    - zone: ${ZONE_NAME}
      record: "*.apps.${CLUSTER_NAME}.${GUID}.${ZONE_NAME}"
  roles:
  - ansible_role_update_ip_route53
EOF

if [ "${ACTION}" != "delete" ]; then 
  ansible-playbook  /tmp/playbook.yml ${VERBOSE_LEVEL} || exit $?
fi

