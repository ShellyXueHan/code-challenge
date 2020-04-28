# code-challenge
Code challenge assignment from Shelly a.k.a Xue Han.

# 1) Application Deployment

The deployed objects together serve as the `Maintenance Instance` for BCGov Production RocketChat (RC), with Ansible automation and High Availability. This Maintenance instance includes the latest stable RC app and MongoDb as the database, hosted on OpenShift. Running version of the application is available here: https://rocketchat-maintenance.pathfinder.gov.bc.ca

If you are interested in the ideas, thoughts, and background for this application setup, see [here](docs/background.md).

As for now, this instance is living on the OpenShift cluster where the prod RC is. `Ansible Playbook` automation makes it easy to migrate once a cloud cluster is ready (as one of the task for my next sprint :P). Following are what to expect from the Ansible Playbook.

***TASKS:***

The [Ansible Playbook](ansible/deployment.yml) bring up a RC Maintenance instance. It contains the following tasks:
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


***Infra-as-Code:***

As Ansible Playbooks are created as YAML files, it's easier reading to keep configuration templates in the same format. From a running instance, the following code has been created to codify the application manifests and tasks.
- Turn OpenShift object configurations into YAML templates
- Parameterize templates with Jinja2
- Include YAML format environment variable setups

The configurations are based from the original RC instance code base [here](https://github.com/BCDevOps/platform-services/tree/master/apps/rocketchat).


***RUN:***

- Ansible deployment is available [here](ansible/README.md).
- Manual deployment is also available is needed (but not recommended). See [here](.openshift/README.md) for more details.


# 2) Operational Plan Development

Anisble Playbook to automate the MongoDB backup-restore tasks, and verifies for the restore status.

***TASKS:***

The operational plan contains the following tasks:

- Create a new StatefulSet for MongoDB with only one pod
- Run default mongo server during startup
- Verify MongoDB service ready

- Run the script to do the following MongoDB tasks:
  - Get a dump from target database
  - Save in the mounted path with timestamp
  - Restore the data on local db
  - Mongo shell to verify the RocketChat database exists already

- Scale down the backup instance after completed


***Reason for this approach:***

The backup strategy was not completed for the production MongDB StatefulSet. There is only backup being created, but was never tested for restoring. So that comes the idea to extend the functionality with `restore` and `verify` steps. 

This operational plan is designed for the maintenance instance (but it would be easily modified to fit production database backup well). See the following reasoning:
- Why Ansible:
  - Nice automation, could be easily configured to apply for production MongoDB backup strategy
  - Consistent with deployment
  - Extra points!

- Why a StatefulSet:
  - Currently not running as CronJob, because the Maintenance instance is not heavily used and should be easy to teardown and bring up
  - But for production RC, a CroJob with daily backups should be created
  - StatefulSet provides a predictable pod name for executions

- Why not `nfs-backup` backup volume:
  - Using a `netapp-block-standard` as this data preservation is just a nice-to-have
  - But for production backups, we should use nfs instead to separate from cluster

- Why no use existing tools for OpenShift setup, like backup-container:
  - A bit over kill for this simple task and not enough customization


***RUN:***

- Ansible deployment is available [here](ansible/README.md).

