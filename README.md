# ios-dev-machine
An experiment in using iPad for everyday development

## Dependencies

- gomplate
- ansible
- terraform

## Config file

```
domainName: 
username: 
# pub is inferred by adding .pub
privateSshKey: 

machines:
  - name: test-1
    provider: gcp
    machineType: f1-micro
    image: ubuntu-1904
    zone: us-east1-c
    domainRecordName: dev-machine-1

```

## Setup

- use ansible to bootstrap machines
- use packer to create machines, install Ansible and trigger inital ansible playbook for bootstrap
- use packer to create a domain for dev machine to make accessing it easier

### Ansible Stages

- install mosh
- create normal user
- copy over ssh keys (disable root login and password login)
- copy over dotfiles

- create modules for different dev set up tasks
	- vim
	- rust
	- golang
	- ruby
	- python

- future: install vs code server

- resources:
	- https://alex.dzyoba.com/blog/terraform-ansible/
    - https://github.com/theia-ide/theia
