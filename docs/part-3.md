# 3) Bonus Round

# Upgrade and Migration Planning

The upgrade plan uses the following components:
- the existing CI/CD pipeline setup to build and deploy RocketChat in different environments
- Maintenance Instance deployed here
- Database backup strategy created here

***Step 1:***
All upgrades should be tested out in dev/test environments using the CI/CD pipeline. Make sure all images are tagged/versioned correctly. The test should also include integration with the other customized components, such as KeyCloak and Reggie.

***Step 2:***
Get the Maintenance Instance up and running as mentioned in assignment part 1. Involve community and schedule maintenance time, notify users if any downtime expected, including the planned route switch so there's no surprise when user hits the maintenance instance. It could also serve as a plan to communicate the progress with the community as it goes. Even if no app downtime expected, it's still good to have a plan B.

***Step 3:***
Before Starting upgrade in production, make a backup of the data. Use Database backup strategy from assignment part 2 to take a backup and verify. In the case where upgrade fails and corrupt data, the backup could be used with minimum missing chats.

***Step 4:***
Start the production upgrade. Depending on the upgrade contents, different approach could be used:

- Minor Version Upgrade
  - use `Rolling` deployment strategy to minimize impact on users
  - but do need to make sure there's no breaking changes, both on app and data
  - refer to release note for details and test out in dev/test environment 

- Major Version Upgrade
  - use `Recreate` deployment strategy to avoid any incompatibility
  - switch to Maintenance Instance during the upgrade
  - this applies to cluster migration as well

- Database and StatefulSet Upgrade
  - If the change is immutable for a StatefulSet, it's recommended to switch the app to maintenance instance
  - Scale down app connected to the database while updating it
  - Bring up a backup StatefulSet to copy over the data, and continue with CI/CD pipeline to create the updated StatefulSet

***Step 5:***
After upgrade is completed, notify users on the maintenance chat. Switch the route to point back to production app. Monitor for some more time on usage and logs.

***Step 6:***
Document the process, have retrospective meeting to continuously improve.



# Some security considerations

Regrading to the current setup, here are some ideas which are solved/going to be solved on our OpenShift platform:

- User login is no authorization - could implement Reggie + KeyCloak
- Database connection using default ports and default admin username - update manifest to use randomly generated 
- No network security policy defined - Aporeto
- OpenShift secrets can be easily decoded - Vault
