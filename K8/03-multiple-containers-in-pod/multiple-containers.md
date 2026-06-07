Tutorial Commands
=================
# Deploy the Pod
kubectl apply -f nginx-with-logger.yaml

# Wait until it’s running
kubectl get pods -o wide

# Generate traffic to NGINX
kubectl exec -it nginx-with-logger -c nginx -- curl localhost

# Get logs from Fluentd sidecar
kubectl logs -f pod/nginx-with-logger -c fluentd-sidecar

# -c fluentd-sidecar → tells Kubernetes to get logs from the container named fluentd-sidecar.
# Without -c, kubectl would try to show logs from the first container, which is nginx in your Pod.

# -f → “follow” logs (like tail -f), so new log lines are streamed in real time.

# Cleanup
kubectl delete pod nginx-with-logger

