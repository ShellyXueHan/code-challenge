

# Ansible Playbook to deploy a HA Maintenance Instance for RocketChat

## Major components:
- Playbook `deployment.yml` that deploys HA Rocketchat and HA MongoDB ReplicaSet
- Playbook `db-operation.yml` for conducting the database backup-restore strategy
- Playbook shares the same environment setup at `vars.yml`
- Tasks and OpenShift manifests in `tasks/` folder
- Shell scripts are added as configmap to the deployment (there are .sh copy for readability)

## Running the Ansible Playbooks

1. Local environment setup:

  - python3 and pip3
  - Ansible - version 2.9.6 (installed with pip3)
  - oc cli - version 3.11 (corresponding to the cluster version, when migrating to OCP4, update this)
  - kubectl - version 1.11 (that comes with oc cli package)


2. Configure application settings and running playbooks

```shell
cd ansible
# Step 1: env var setup

# update the vars file to match existing app setup and targeted namespace
cp sample-vars.yml vars.yml

# Step 2: run playbook
# In case there are multiple python versions, specify python3

# ----- 1) Application Deployment -----
python3 $(which ansible-playbook) deployment.yml

# ----- 2) Operational Plan Development ---------
python3 $(which ansible-playbook) db-operation.yml

```

# TL;DR
The following documentation is included for integration with existing RC work.

## Features and Dependencies:

As OpenShift provides good orchestration feature on the pods and corresponding services and routes, I'm using Ansible to manipulate application with OpenShift manifests. The Playbooks are designed with idempotent tasks, using status checks and object operations are done by states. Here are the major modules used:

- [k8s modules](https://docs.ansible.com/ansible/latest/modules/k8s_module.html) to query and manage OpenShift Objects
- [kubectl connection plugin](https://docs.ansible.com/ansible/latest/plugins/connection/kubectl.html) to execute tasks in pods
- [uri modules](https://docs.ansible.com/ansible/latest/modules/uri_module.html) to make API request to application endpoints

With that, the playbook is able to provide the following:
- Tasks has dynamic name to specify what's being run
- When verifying the status of each tasks, `timeout-retry` has been implemented to avoid timing issue
- Some steps will take minutes to finish based on the available resources, especially pod execution step as it needs to setup host connections
- To provide idempotency, you might be seeing tasks with failure message in red, which is expected and will not exit the play
- If a task has not been passing status check for too long (over the time limit), the playbook will provide detail information on failure and exit itself

## Folder Structure
```
.
├── README.md
├── ansible.cfg
├── db-operation.yml
├── deployment.yml
├── sample-vars.yml
└── tasks
    ├── check_access.yml
    ├── clear_object.yml
    ├── create_object.yml
    ├── env-verify.yml
    ├── get_object.yml
    ├── rc_setup.yml
    ├── replica_set_operation.yml
    ├── switch_route.yml
    └── templates
        ├── backup-restore-verify.sh
        ├── configmap-scl-enable.yml
        ├── mongo-backup-manifest.yml
        ├── mongodb-manifest.yml
        ├── rocketchat-manifest.yml
        └── rocketchat-route-manifest.yml
```
