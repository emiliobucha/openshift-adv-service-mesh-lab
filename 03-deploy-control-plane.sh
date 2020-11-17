echo '-------- 3. Deploy Service Mesh Control Plane --------'

mkdir -p ./03-control-plane
echo 'apiVersion: maistra.io/v1
kind: ServiceMeshControlPlane
metadata:
  name: service-mesh-installation
spec:
  version: v1.1
  threeScale:
    enabled: false
  istio:
    global:
      mtls:
        enabled: false
        auto: false
      disablePolicyChecks: true
      proxy:
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 128Mi
    gateways:
      istio-egressgateway:
        autoscaleEnabled: false
      istio-ingressgateway:
        autoscaleEnabled: false
        ior_enabled: false
    mixer:
      policy:
        autoscaleEnabled: false
      telemetry:
        autoscaleEnabled: false
        resources:
          requests:
            cpu: 100m
            memory: 1G
          limits:
            cpu: 500m
            memory: 4G
    pilot:
      autoscaleEnabled: false
      traceSampling: 100.0
    kiali:
      dashboard:
        user: admin
        passphrase: redhat
    tracing:
      enabled: true' > ./03-control-plane/05-deploy-control-plane.yaml


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
