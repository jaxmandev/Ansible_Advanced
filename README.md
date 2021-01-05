# IAC with Ansible

Ansible is a IAC (Infrastructure as Code) configuration management tool.

## How it works

Ansible uses the SSH connection to access a machine or a group of machines. Afterwards it performs the specified action that is set by a used. It also allows to create a list of instructions or better known as tasks inside of playbooks. These playbooks are a standardised way to provision a cloud machine without having to manually access it. This creates a much more efficient work-flow where machines can be deployed within seconds added to a group and when a playbook is executed all the machines in the group will have identical packages installed. Ansible is also multi-platform, meaning that even if the initial playbook was written for Ubuntu, Ansible will translate the commands onto another OS such as CentOS or Fedora.

## How to set it up

- Create a controller and host machine in aws.
- Copy `server_files` to your controller machine into `~/` folder with any name you want.
- Edit the `app_installation.yaml` from `provisions` folder to match your folder name you've set above and database IP address, also ensure that you change the `hosts` name to your desired group.
- Copy the `provisions` folder onto your controller machine.
- Run the `startup_bash.sh` on the controller machine to install ansible and its dependancies.
- Edit the `hosts` on the controller machine to match the host name of your machine group from ansible (located in `/etc/ansible/hosts` file, see below) this name should also be the same name you've used in `app_installation.yaml`.
- Run the `app_installation.yaml` file.

## Main sections

Setting up hosts in `/etc/ansible/hosts` file.

```bash
[app]
172.31.36.118 ansible_connection=ssh ansible_ssh_private_key_file=/home/ubuntu/.ssh/eng74hubertawskey.pem

[public_app]
34.243.13.122 ansible_connection=ssh ansible_ssh_private_key_file=/home/ubuntu/.ssh/eng74hubertawskey.pem
```

## Main commands

Ping a host machine

```bash
ansible app -m ping
```

Ping all host machines

```bash
ansible all -m ping
```

Run different commands in all or individual machines

```bash
ansible all -a "date"
```

Run different commands as sudo

```bash
ansible app -a "apt update" --become
```

## Writing a playbook

A playbook can be stored anywhere in your system, but it must use the `.yaml` extension. A playbook is a set of tasks or instructions that ansible will run on the machine in order. A playbook allows a wide and complex range of instructions to be created. It also allows the use of variables, notifications, file editing etc.
</br>

To create a playbook, we need to create a new file that is followed by `.yaml` for example `my_playbook.yaml`. Inside of that playbook we use a specific syntaxing format, similar to a JSON dictionaries, or Python's lists. The file being with `---` to indicate that its the beginning of the file. The first object in our list is the name of our playbook, what host we would like to use and other global variables, such as do we need `sudo` or should we test the connection before running the instructions.

```yaml
---
- name: app installation
  hosts: app
  gather_facts: yes
  become: true
```

Afterwards we can begin making our `tasks:`. An example of a simple task is to get the `sudo apt update` and `sudo apt upgrade` to be executed on our host machine.

```yaml
tasks:
  - name: Running APT Update && Upgrade
    apt:
      upgrade: "yes"
      update_cache: yes
      force_apt_get: yes
      cache_valid_time: 3600
```

Here we use a list object with `-` and give our task a name, followed by what ansible module we would like to use. As we are trying to use the ubuntu's package manager, ansible has a module called `apt`. We can then specify the arguments of that module found in the official documentation. Rather than writing the command we can explicitly state all the parameters of the command and this way our ansible is more flexibile as to what system it can run on. If we used `sudo apt update` we would not be able to run that same command on CentOS or Fedora. However, ansible knows what we would like to achieve and is OS-aware therefore, it will run the respective command on the system it's being used on.

## Task 1

Check uptime of the machine

```bash
ansible app -a "uptime"
```

Returned:

```bash
172.31.36.118 | CHANGED | rc=0 >>
15:57:03 up 20 min,  2 users,  load average: 0.00, 0.00, 0.00
```

Update and upgrade machine's packages

```bash
ansible app -m apt -a "upgrade=yes" --become
```

Returned:

```bash
172.31.36.118 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "msg": "Reading package lists...\nBuilding dependency tree...\nReading state information...\nCalculating upgrade...\n0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.\n",
    "stderr": "",
    "stderr_lines": [],
    "stdout": "Reading package lists...\nBuilding dependency tree...\nReading state information...\nCalculating upgrade...\n0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.\n",
    "stdout_lines": [
        "Reading package lists...",
        "Building dependency tree...",
        "Reading state information...",
        "Calculating upgrade...",
        "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded."
    ]
}
```

## Task 2

*How to copy within the host machine*

```yaml
- name: Copying a file within the host machine
  copy:
    src: "/home/ubuntu/old_folde/file.md"
    dest: /home/ubuntu/new_folder/copied_file.md
    remote_src: yes
```

*How to synchronize a folder between host and controller*

```yaml
- synchronize:
    src: "/home/ubuntu/local_folder/"
    dest: "/home/ubuntu/remote_folder/"
```

*How to make a file inside of the host machine*

```yaml
- name: Making an empty file with permissions
  file:
    path: /home/ubuntu/some_folder/empty_file.md
    state: touch
    mode: '0755'
```

*How to start / restart a service*

```yaml
- name: Ensuring nginx is started
  service:
    name: nginx
    state: started
```

*How to change a line in a file*

```yaml
- name: Ensuring public IP is current
  lineinfile:
    path: /etc/nginx/nginx.conf
    regexp: "^(.*)server_name(.*)$"
    line: "server_name 192.168.0.1;"
    backrefs: yes
```

*How to use variables*

```yaml
vars:
  variable_1: 'First Variable'
  variable_2: 'Second Variable'

tasks:
  - name: Copy a file
    src: {{ variable_1 }}/some_file.md
    dest: {{ variable_2 }}/some_file.md
```

*How to use templates*

```yaml
vars:
  variable_1: 'First Variable'
  variable_2: 'Second Variable'

tasks:
  - name: Template Example
    template:
      src: some_file.j2
      dest: /home/ubuntu/some_folder/output.txt
```

some_file.j2

```j2
{{ variable_1 }}
testing...
{{ variable_2 }}
```

output.txt

```txt
First Variable
testing...
Second Variable
```

*How to use Handlers and Notifications*

```yaml
tasks:
  - name: Copying config file for nginx
    copy:
      src: "/home/ubuntu/{{ app_destination }}/config_files/nginx.conf"
      dest: /etc/nginx/
      remote_src: yes
    notify:
      - Restarting Nginx

handlers:
  - name: Restarting Nginx
    service:
      name: nginx
      state: restarted
```

*How to run shell commands*

```yaml
- name: Getting Public IP
  command: "curl ifconfig.me"

# Alternative version

- name: Getting Public IP
  shell: "curl ifconfig.me"
```

*How to call a playbook from another playbook*

```yaml
- include: playbook_1.yaml
  vars:
    first_var: true
    second_var: 123.123.123.123

- include: playbook_2.yaml
  vars:
    third_var: 10
```
