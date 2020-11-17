## If you get the error like that 
#######
## Internal error occurred: failed calling webhook "smcp.mutation.maistra.io": 
## Post https://admission-controller.openshift-operators.svc:443/mutate-smcp?timeout=30s: 
## no endpoints available for service "admission-controller"
#######
## Delete all validatingwebhookconfiguration and mutatingwebhookconfigurations
oc delete validatingwebhookconfiguration/openshift-operators-redhat.servicemesh-resources.maistra.io
oc delete mutatingwebhookconfigurations/openshift-operators-redhat.servicemesh-resources.maistra.io
oc delete mutatingwebhookconfiguration.admissionregistration.k8s.io/openshift-operators-redhat.servicemesh-resources.maistra.io
oc delete validatingwebhookconfiguration.admissionregistration.k8s.io/openshift-operators-redhat.servicemesh-resources.maistra.io
oc delete -n openshift-operators-redhat daemonset/istio-node
oc delete clusterrole/istio-admin clusterrole/istio-cni clusterrolebinding/istio-cni
oc get crds -o name | grep '.*\.istio\.io' | xargs -r -n 1 oc delete
oc get crds -o name | grep '.*\.maistra\.io' | xargs -r -n 1 oc delete