echo '-------- 1. Service Mesh operator Installation --------'

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
