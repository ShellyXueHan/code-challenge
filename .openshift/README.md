### Run on OpenShift
Use the OpenShift manifests to build and deploy the app.
```shell
cd .openshift
# Step 1: env setup
# update the maintenance.env file to match your setup
cp maintenance.env.sample maintenance.env
# switch to the namespace for deployment
oc project <namespace>

# Step 2: Deploy MongoDB
oc process --ignore-unknown-parameters=true -f mongodb-manifest.yaml --param-file=maintenance.env | oc apply -f -

# Step 3: Deploy RC app
oc process --ignore-unknown-parameters=true -f rocketchat-manifest.yaml --param-file=maintenance.env | oc apply -f -
```
