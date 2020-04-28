### Background for this project:
The BCGov Production RocketChat has been an essential chat service provided by the Platform Services Team. To better support the community, we could like to keep the app available all the time. However, considering that will be operational tasks or cluster issues that would require application downtime, a maintenance instance for the application living on another cluster will be ideal in this case.

### Ideas:
So here comes the idea where we could spin up the Maintenance RC on cloud cluster which hosts the production connection when needed. To make this an efficient task to do during high demand times, I've created `Ansible Playbook` that could deploy the instance in one command run.
