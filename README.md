# update-ip-route53
This is an Ansible role that updates DNS records on Amazon's Route 53 (AWS) with
your public IP address.

Please note that as part of this role, `openssl`, [boto](https://github.com/boto/boto), and
[pyOpenSSL](https://github.com/pyca/pyopenssl) will be installed. If you are using CentOS/Red Hat, the role will
install `pip` (requires [EPEL](https://fedoraproject.org/wiki/EPEL)) and then install `boto` and `pyOpenSSL` in a
Python virtualenv instead because the packaged version of `pyOpenSSL` is not recent enough.

If you are not using this role on Debian/Ubuntu, CentOS/Red Hat,
`openssl`, `boto`, and `pyOpenSSL` must be installed manually before using this role.

[![ansible-lint](https://github.com/tosin2013/ansible-role-update-ip-route53/actions/workflows/ansible-lint.yml/badge.svg)](https://github.com/tosin2013/ansible-role-update-ip-route53/actions/workflows/ansible-lint.yml)

## Requirements

Ansible 2.9+ is required for this role. This role also must be run by root or
through sudo/become.


## Role Variables

#### Required Variables
* **update_ip_r53_aws_access_key** - the access key to an AWS user that is allowed to add records to the specified zone.
* **update_ip_r53_aws_secret_key** - the secret key to an AWS user that is allowed to add records to the specified zone.
* **update_ip_r53_records** - the list of dictionaries describing the Route 53 (AWS) domain/zones the public IP address
    should be updated on. All the accepted keys map to the `route53` parameters. The required keys are `zone` and
    `record`. The optional keys are `type` (defaults to `A`) and `wait`.

#### Optional Variables
* **update_ip_r53_virtualenv_dir** - the path to create the Python virtualenv to install the Python dependencies on
    CentOS/Red Hat.

## Example Playbook

**When using public IP address**
```yaml
- name: Update host.example.com and host2.example.com
  hosts: host
  become: yes

  vars:
  - update_ip_r53_aws_access_key: SomeAccessKey
  - update_ip_r53_aws_secret_key: SomeSecretKey
  - use_public_ip: true
  - update_ip_r53_records:
    - zone: example.com
      record: host.example.com
    - zone: example.com
      record: host2.example.com

  roles:
  - ansible_role_update_ip_route53
```

**When using private ip address**
```yaml
- name: Update host.example.com and host2.example.com
  hosts: host
  become: yes

  vars:
  - update_ip_r53_aws_access_key: SomeAccessKey
  - update_ip_r53_aws_secret_key: SomeSecretKey
  - use_public_ip: false
  - private_ip: "192.168.1.10"
  - update_ip_r53_records:
    - zone: example.com
      record: host.example.com
    - zone: example.com
      record: host2.example.com

  roles:
  - ansible_role_update_ip_route53
```

## Environment Variables

To run this script, you will need to set the following environment variables in a `.env` file:

- `AWS_ACCESS_KEY`: Your AWS access key.
- `AWS_SECRET_KEY`: Your AWS secret key.
- `IP_ADDRESS`: The IP address you want to use.
- `ZONE_NAME`: The DNS zone name.
- `GUID`: The GUID for your cluster.
- `ACTION`: The action to perform (e.g., `create`, `delete`).
- `VERBOSE_LEVEL`: The verbosity level for the Ansible playbook (e.g., `-v`, `-vv`, `-vvv`).

### Example `.env` File

```
AWS_ACCESS_KEY=your_aws_access_key_here
AWS_SECRET_KEY=your_aws_secret_key_here
IP_ADDRESS=your_ip_address_here
ZONE_NAME=your_zone_name_here
GUID=your_guid_here
ACTION=your_action_here
VERBOSE_LEVEL=-v
```

## Running the Deployment Script

1. Ensure you have the required environment variables set in your `.env` file.
2. Run the deployment script using the following command:

```bash
source .env && ./deployment-script.sh
```

## License

MIT
