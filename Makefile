.PHONY: start
start:
	minikube start --driver="docker" --addons=metrics-server --cpus no-limit --memory no-limit
	# kubectl create ns strimzi
	kubectl create ns kraft 
	kubectl create ns kafka 
	kubectl create ns redpanda 
	kubectl create ns monitoring

.PHONY: stop
stop:
	minikube stop
	minikube delete


# https://spring.academy/guides/kubernetes-prometheus-grafana
.PHONY: monitoring
monitoring:
	helm install prometheus bitnami/kube-prometheus --namespace monitoring -f resources/prometheus.yaml
	helm install grafana bitnami/grafana --namespace monitoring -f resources/grafana.yaml


# provision one broker for each platform
.PHONY: start-all-platforms
start-all-platforms:
	# kafka
	# kubectl apply -f strimzi/kafka-persistent-single.yaml -n kafka
	helm install kafka oci://registry-1.docker.io/bitnamicharts/kafka -f resources/kafka.yaml -n kafka
	
	# kraft
	# kubectl apply -f strimzi/kraft-single.yaml -n kraft
	helm install kafka oci://registry-1.docker.io/bitnamicharts/kafka -f resources/kraft.yaml -n kraft
	
	# redpanda
	helm install redpanda redpanda/redpanda --namespace redpanda -f resources/redpanda.yaml


# .PHONY: delete
# delete: 
# 	kubectl delete -f strimzi/kraft-single.yaml -n kraft
# 	kubectl delete -f strimzi/kafka-persistent-single.yaml -n kafka
# 	helm uninstall redpanda -n redpanda


.PHONY: start-all-benchmarks
start-all-benchmarks: 
	helm install benchmark-kafka ./omb/helm/benchmark -n kafka -f omb/helm/kafka.yaml
	helm install benchmark-kraft ./omb/helm/benchmark -n kraft -f omb/helm/kraft.yaml
	helm install benchmark-redpanda ./omb/helm/benchmark -n redpanda -f omb/helm/redpanda.yaml

.PHONY: get-reports
get-reports:
	kubectl cp <pod_name>:/*.json omb/... -n <namespace>


# .PHONY: strimzi
# strimzi: 
# 	helm install strimzi strimzi/strimzi-kafka-operator --version 0.41.0 -f ./resources/operator-strimzi.yaml -n strimzi

# vaix 
