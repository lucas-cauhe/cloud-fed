## Deploy OPA engine

`sudo podman run -v /home/cephadm/rego-policies:/policies -p 8181:8181 docker.io/openpolicyagent/opa     run --server --log-level debug --addr=0.0.0.0:8181 /policies`

## Run the following command to test a policy

`curl -s -H 'Content-Type: application/json' --data @rego/naming/examples/vm_alloc.json http://10.0.11.221:8181/v1/data/naming/compliant | jq`
