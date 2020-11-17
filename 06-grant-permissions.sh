echo -en '\n-------- 5.1 Login --------\n'
oc login $LAB_MASTER_API -u $OCP_USER -p $OCP_PASS

# grant permission user1 like mesh-admin
oc adm policy add-role-to-user edit user1 -n $SM_CP_NS
oc adm policy add-role-to-user admin user1 -n $BOOK_APP_NS