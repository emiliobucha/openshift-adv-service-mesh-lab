echo -en '\n-------- 4. Creating SM MemberRoll --------\n'

mkdir -p ./04-service-mesh-member-roll

echo "apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
spec:
  members:
  - bookinfo" > ./04-service-mesh-member-roll/06-service-mesh-member-roll.yaml

echo -en '\n-------- 4.1 Login --------\n'
oc login $LAB_MASTER_API -u $OCP_USER -p $OCP_PASS -n $SM_CP_NS

echo -en '\n-------- 4.2 Creating SM MemberRoll --------\n'
oc apply -f ./04-service-mesh-member-roll/06-service-mesh-member-roll.yaml

echo -en '\n-------- 4.3 Checking --------\n'
echo -en '\n-------- Waiting NS Configuration --------\n'
while (true); do
  MAP=$(oc get project $BOOK_APP_NS -o template --template='{{.metadata.labels}}')
  
  if [[ ${MAP} == *"kiali.io/member-of:${SM_CP_NS}"* && ${MAP} == *"maistra.io/member-of:${SM_CP_NS}"* ]] ; then
      echo "Bookinfo namespace was included to service mesh!!"
      break
  else
      echo "Waiting for configuration..."
  fi
  sleep 10
done

echo -en '\n-------- Waiting Role Binding creations --------\n'
while (true); do
  ROLES=$(oc get RoleBinding  -n $BOOK_APP_NS -l release=istio -o wide | awk '{if(NR>1)print}' | wc -l)
  
  if [[ ${ROLES} -ge 6 ]] ; then
      echo "RoleBindings are created"
      break
  else
      echo "Waiting for role bindings..."
  fi
  sleep 10
done

echo -en '\n-------- Waiting Secrets creations --------\n'
while (true); do
  SECRETS=$(oc get secrets -n $BOOK_APP_NS | grep istio | wc -l)
  
  if [[ ${SECRETS} -ge 7 ]] ; then
      echo "Secrets are created"
      break
  else
      echo "Waiting for Secrets..."
  fi
  sleep 10
done


echo -en '\n-------- 4.4 Patch all deployment imjecting the Envoy Proxy --------\n'

for i in $(oc get deploy -n $BOOK_APP_NS | grep -v NAME | awk '{print $1}')
do
  oc patch deployment/$i -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}' -n $BOOK_APP_NS
done
sleep 60
for POD in $(oc get pods -n $BOOK_APP_NS  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}')
do
    oc get pod $POD  -n $BOOK_APP_NS -o jsonpath='{.metadata.name}{":\t\t"}{.spec.containers[*].name}{"\n"}'
done