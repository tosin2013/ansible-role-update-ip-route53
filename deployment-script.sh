#!/bin/bash 

if [ ! -f /tmp/requirements.yml ]; then
  cat >/tmp/requirements.yml<<EOF
---
collections:
-  amazon.aws
roles: 
- name: ansible_role_update_ip_route53
    src: https://github.com/tosin2013/ansible-role-update-ip-route53.git
    version: master
EOF
fi


ansible-galaxy install -r /tmp/requirements.yml --force -vv
pip3 install boto3 botocore


CLUSTER_NAME="sample-cluster"
cat >/tmp/playbook.yml<<EOF
- name: Populate OpenShift DNS Entries
  hosts: localhost
  connection: local
  become: yes

  vars:
  - update_ip_r53_aws_access_key:  @param:AWS_ACCESS_KEY@
  - update_ip_r53_aws_secret_key: @param:AWS_SECRET_KEY@
  - use_public_ip: true
  - private_ip: "@param:IP_ADDRESS@"
  - update_ip_r53_records:
    - zone: @param:ZONE_NAME@
      record: api.${CLUSTER_NAME}.@param:GUID@.@param:ZONE_NAME@
    - zone: @param:ZONE_NAME@
      record: "*.apps.${CLUSTER_NAME}.@param:GUID@.@param:ZONE_NAME@"
  roles:
  - ansible_role_update_ip_route53
EOF

if [ "@param:ACTION@" != "delete" ]; then 
  ansible-playbook  /tmp/playbook.yml @param:VERBOSE_LEVEL@ || exit $?
fi

