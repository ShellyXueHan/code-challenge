

# Ansible Playbook to deploy Maintenance Instance for RocketChat

As OpenShift provides good orchestration feature on the pods and corresponding services and routes, I'm using Ansible to manipulate application with OpenShift manifests. The Playbooks are designed with idempotent tasks, using status checks and object operations are done by states. Here are the major modules used:

- [k8s modules](https://docs.ansible.com/ansible/latest/modules/k8s_module.html) to query and manage OpenShift Objects
- [kubectl connection plugin](https://docs.ansible.com/ansible/latest/plugins/connection/kubectl.html) to execute tasks in pods
- [uri modules](https://docs.ansible.com/ansible/latest/modules/uri_module.html) to make API request to application enddpoints

## Running the Ansible Playbooks

1. Local environment setup:

  - python3 and pip
  - Ansible - version 2.9.6
  - oc cli - version 3.11 (corresponding to the cluster version, when migrating to OCP4, update this)


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

## Features

- Tasks has dynamic name to specify what's being run
- When verifying the status of each tasks, `timeout-retry` has been implemented to avoid timing issue
- Some steps will take minutes to finish based on the available resources, especially pod execution step as it needs to setup host connections
- To provide idempotency, you might be seeing tasks with failure message in red, which is expected and will not exit the play
- If a task has not been passing status check for too long (over the time limit), the playbook will provide detail information on failure and exit itself


## Structure of the Playbooks
```
├── README.md
├── ansible.cfg
├── db-operation.yml
├── deployment.yml
├── sample-vars.yml
├── tasks
│   ├── check_access.yml
│   ├── clear_object.yml
│   ├── create_object.yml
│   ├── env-verify.yml
│   ├── get_object.yml
│   ├── rc_setup.yml
│   ├── replica_set_operation.yml
│   ├── switch_route.yml
│   └── templates
│       ├── backup-restore-verify.sh
│       ├── configmap-scl-enable.yml
│       ├── mongo-backup-manifest.yml
│       ├── mongodb-manifest.yml
│       ├── rocketchat-manifest.yml
│       └── rocketchat-route-manifest.yml
└── vars.yml
```

There are two main playbooks, `deployment.yml` for deploy the maintenance instance, and `db-operation.yml` for conducting the database backup-restore strategy. The playbooks run the tasks included in `tasks/` folder and use the OpenShift manifests in `tasks/templates` to create and manage objects.

Shell scripts are added as configmaps to the deployment. There is also an original copy for readability at `tasks/templates`.
