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
