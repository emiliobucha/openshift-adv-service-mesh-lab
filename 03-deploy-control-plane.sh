echo '-------- 3. Deploy Service Mesh Control Plane --------'

echo '-------- 3.1 Login --------'
oc login $LAB_MASTER_API -u $OCP_USER -p $OCP_PASS

echo '-------- 3.2 Create new project --------'
oc new-project $SM_CP_NS

echo '-------- 3.3 Deploy SM Control Plane --------'
oc apply -n $SM_CP_NS -f ./03-control-plane/05-deploy-control-plane.yaml

while (true); do
  REPLICAS_READY=$(oc get deployment -n $SM_CP_NS istio-pilot -o jsonpath='{.status.readyReplicas}')
  if [[ ${REPLICAS_READY} -eq 1 ]] ; then
      echo "Operator is ready!"
      break
  else
      echo "Waiting for replicas ready..."
  fi
  sleep 10
done
