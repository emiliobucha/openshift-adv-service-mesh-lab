echo -en '\n-------- 3. Deploy Book Info Application --------\n'

echo -en '\n-------- 3.1 Login --------\n'
oc login $LAB_MASTER_API -u $OCP_USER -p $OCP_PASS

echo -en '\n-------- 3.2 Creating project --------\n'
oc new-project $BOOK_APP_NS

echo -en '\n-------- 3.3 Deploying new Bookinfo Application --------\n'
oc apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/platform/kube/bookinfo.yaml -n $BOOK_APP_NS

echo -en '\n-------- 3.4 Expose service --------\n'
oc expose service productpage

echo -en '\n-------- 3.5 Exposed service URL --------\n'
echo -en "\n$(oc get route productpage --template '{{ .spec.host }}')\n"