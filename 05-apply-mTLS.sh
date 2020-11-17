echo -en '\n-------- 5. Securing  --------\n'

echo -en '\n-------- 5.1 Login --------\n'
oc login $LAB_MASTER_API -u $OCP_USER -p $OCP_PASS -n $BOOK_APP_NS

echo -en '\n-------- 5.2 Setting probes --------\n'
for i in $(oc get deploy -n $BOOK_APP_NS | awk '/\-v/ {print $1}')
do
  oc set probe deploy -n $BOOK_APP_NS $i --liveness -- echo ok
  oc set probe deploy -n $BOOK_APP_NS $i --readiness -- echo ok
done



echo -en '\n-------- 5.3 Creating certifates and ingress gateway--------\n'
echo "
[ req ]
req_extensions     = req_ext
distinguished_name = req_distinguished_name
prompt             = no

[req_distinguished_name]
commonName=$BOOK_APP_NS.apps.$SUBDOMAIN_BASE

[req_ext]
subjectAltName   = @alt_names

[alt_names]
DNS.1  = $BOOK_APP_NS.apps.$SUBDOMAIN_BASE
DNS.2  = *.$BOOK_APP_NS.apps.$SUBDOMAIN_BASE
" > cert.cfg

openssl req -x509 -config cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:2048 -sha256 -keyout tls.key -out tls.crt

echo -en '\n------------ Create secrets for istio-ingressgateway--------\n'

oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n $SM_CP_NS

echo -en '\n------------ Patch deployment istio-ingressgateway--------\n'

oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n $SM_CP_NS


echo -en '\n-------- 5.4 Creating bookinfo wildcard --------\n'

oc apply -f ./05-mTLS/10-wildcard-gateway.yaml -n $SM_CP_NS


echo -en '\n-------- 5.5 Creating policies--------\n'

for DEPLOY in $(oc get deploy -o jsonpath='{.items[*].metadata.labels.app}')
do
  template=`cat "./05-mTLS/07-policy-template.yaml" | sed "s/{{DEPLOY_NAME}}/$DEPLOY/g"`
  echo "$template" | oc apply -n $BOOK_APP_NS -f -
done

echo -en '\n-------- 5.5 Creating destinationrules--------\n'
for DEPLOY_LABEL in $(oc get deploy -o jsonpath='{.items[*].metadata.labels.app}')
do
  if [[ ${DEPLOY_LABEL} == *"reviews"* ]]
  then
    continue
  else
    template=`cat "./05-mTLS/08a-destinationrule-template.yaml" | sed "s/{{DEPLOY_NAME}}/$DEPLOY_LABEL/g"`
    echo "$template" | oc apply -n $BOOK_APP_NS -f -
  fi
done

oc apply -n $BOOK_APP_NS -f ./05-mTLS/08b-destinationrule-reviews.yaml


echo -en '\n-------- 5.6 Creating virtual services--------\n'


oc apply -n $BOOK_APP_NS -f ./05-mTLS/09-virtualservices.yaml

echo -en '\n-------- 5.6 Creating productpage route--------\n'

oc patch deploy productpage-v1 -p '{"spec": {"template": {"metadata": {"labels": {"maistra.io/expose-route": "true"}}}}}'
oc apply -n $SM_CP_NS -f ./05-mTLS/11-productpage-route.yaml