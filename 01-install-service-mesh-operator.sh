echo '-------- 1. Service Mesh operator Installation --------'

mkdir -p ./01-installation
echo 'apiVersion: v1
kind: Namespace
metadata:
  name: openshift-operators-redhat 
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-operators-redhat 
  namespace: openshift-operators-redhat
spec: {}
---' > ./01-installation/00-ns-operator-group.yaml


echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: "4.5"
  installPlanApproval: Automatic
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: elasticsearch-operator' > ./01-installation/01-es-operator.yaml


echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-operators-redhat
spec:
  channel: "stable"
  installPlanApproval: Automatic
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: jaeger-product' > ./01-installation/02-jaeger-operator.yaml


echo 'apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: "1.0"
  installPlanApproval: Automatic
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: servicemeshoperator' > ./01-installation/04-servicemesh-operator.yaml



echo '-------- 1.1 Login --------'
oc login $LAB_MASTER_API -u $OCP_USER -p $OCP_PASS

echo '-------- 1.2 Apply Operator Group --------'
oc apply -f ./01-installation/00-ns-operator-group.yaml

echo '-------- 1.3 Apply ElasticSearch Operator Subscription --------'
oc apply -f ./01-installation/01-es-operator.yaml

echo '-------- 1.4 Apply Jaeger Operator Subscription --------'
oc apply -f ./01-installation/02-jaeger-operator.yaml

echo '-------- 1.5 Apply Kiali Operator Subscription --------'
oc apply -f ./01-installation/03-kiali-operator.yaml

echo '-------- 1.6 Apply ServiceMesh Operator Subscription --------'
oc apply -f ./01-installation/04-servicemesh-operator.yaml

echo -en '\n--------Wait until service mesh opertor is ready --------\n'

while (true); do
  REPLICAS_READY=$(oc get deployment istio-operator -n openshift-operators -o jsonpath='{.status.readyReplicas}')
  if [[ ${REPLICAS_READY} -eq 1 ]] ; then
      echo "Operator is ready!"
      break
  else
      echo "Waiting for replicas ready..."
  fi
  sleep 10
done
