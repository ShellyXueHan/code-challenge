# 1) Application Deployment Details

Anisble Playbook to automate the deployment of HA RocketChat and MongoDB ReplicaSet


***TASKS:***

The [Ansible Playbook](../ansible/deployment.yml) bring up a RC Maintenance instance. It contains the following tasks:
- Setup local environment and OpenShift namespace:
  - Verify environment setup and prerequisites
  - List objects in namespace matching label
  - Clear up the namespace, preserve PVCs and secrets when needed

- Deploy the components:
  - Deploy HA MongoDB ReplicaSet as an OpenShift StatefulSet
  - Deploy HA RC app

- Test the success of the deployment and rollback when failed:
  - Verify MongoDB service ready
  - Verify deployment has expected ready pods
  - Rollback DeploymentConfig when not successful

- Final step to setup RC maintenance notification:
  - Create default chat channel and post notification message
  - Switch Production RC route to point to Maintenance instance
  - (for now, it's only switching the dev RC instance to avoid affecting prod chat)


During each step, corresponding output results are displayed for progress reference. There will be prompts for interaction, please see the options provided during the run. *Please note that when tasks have not succeed over the retry limits, or when unexpected errors occur, the Playbook will quit and error out. Double check your network connection and cluster status. Playbook is setup to be idempotent, so just run again.*


***OUTCOME:***

As a result of the playbook, the following OpenShift objects are created:
- HA StatefulSet of MongoDB ReplicaSet:
  - 3 replicas with Anti Affinity setup to ensure HA setting
  - Persistent Volumes with `netapp-block-standard` type to improve performance
  - services for MongoDB and internal ReplicaSet operation
  - Secret for MongoDB access
  - Mounted script to enable RHSCL for kubectl execution setup

- HA deployment of RC app:
  - 3 replicas with a Horizontal Pod Autoscaler
  - Local RC ImageStream with proper tags
  - Exposed service and route
  - Secret for RC admin credential
  - Persistent Volume (via PVC) to hold uploaded assets
  - Configmap for initial RC setup

- A maintenance instance accessible at the origin production URL
  - New route with the production host
