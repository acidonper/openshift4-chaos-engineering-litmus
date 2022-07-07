#!/bin/bash
##
# Setup Openshift Environment
##

waitpodup(){
  x=1
  test=""
  while [ -z "${test}" ]
  do 
    echo "Waiting ${x} times for pod ${1} in ns ${2}" $(( x++ ))
    sleep 1 
    test=$(oc get po -n ${2} | grep ${1})
  done
}

waitoperatorpod() {
  NS=openshift-operators
  waitpodup $1 ${NS}
  oc get pods -n ${NS} | grep ${1} | awk '{print "oc wait --for condition=Ready -n '${NS}' pod/" $1 " --timeout 300s"}' | sh
}

echo "Creating istio namespace..."
# Create Istio Namespace
oc new-project istio-system

echo "Installing Istio operator..."
oc apply -f ./scripts/files/operator_istio.yaml
sleep 30

# Wait for Istio Operator are ready
echo "Waiting for Istio Operators is ready..."
waitoperatorpod kiali
waitoperatorpod jaeger
waitoperatorpod istio

# Preventive wait
sleep 30

# Aplying Controlplane and Memberrole objects
echo "Installing Istio control plane..."
oc apply -f ./scripts/files/smcp.yaml
oc apply -f ./scripts/files/smmr.yaml

# Wait for Istio Operator are ready
echo "Waiting for Istio control plane is ready..."
oc wait --for condition=Ready -n istio-system smmr/default --timeout 300s