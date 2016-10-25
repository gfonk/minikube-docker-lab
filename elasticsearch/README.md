# Elasticsearch for Kubernetes

Reference:

- [elasticsearch-kubernetes-examples](https://github.com/kubernetes/kubernetes/tree/master/examples/elasticsearch)


### elasticsearch

- [lab from kubernetes](https://github.com/kubernetes/kubernetes/tree/master/examples/elasticsearch)
	- with some changes:
		- pulling from hub.docker.com
		- image: elasticsearch:2.4.1


- noticed the different types of `kind:`
- where do i find the reference for the different types?

```
$ ls -1 *.yaml
es-rc.yaml
es-svc.yaml
service-account.yaml

$ grep kind: *.yaml
es-rc.yaml:kind: ReplicationController
es-svc.yaml:kind: Service
service-account.yaml:kind: ServiceAccount
```

copy and paste

```
$ k create -f service-account.yaml
serviceaccount "elasticsearch" created

$ k create -f es-svc.yaml
service "elasticsearch" created

$ k create -f es-rc.yaml
replicationcontroller "elasticsearch" created
```

validating service

```

$ k get pods
NAME                  READY     STATUS    RESTARTS   AGE
elasticsearch-rsa59   1/1       Running   0          12s

$ k logs elasticsearch-rsa59
[2016-10-25 00:43:58,907][INFO ][node                     ] [Smart Alec] version[2.4.1], pid[1], build[c67dc32/2016-09-27T18:57:55Z]
[2016-10-25 00:43:58,907][INFO ][node                     ] [Smart Alec] initializing ...
[2016-10-25 00:43:59,589][INFO ][plugins                  ] [Smart Alec] modules [reindex, lang-expression, lang-groovy], plugins [], sites []
[2016-10-25 00:43:59,612][INFO ][env                      ] [Smart Alec] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/sda1)]], net usable_space [15.4gb], net total_space [17.8gb], spins? [possibly], types [ext4]
[2016-10-25 00:43:59,612][INFO ][env                      ] [Smart Alec] heap size [1007.3mb], compressed ordinary object pointers [true]
[2016-10-25 00:44:02,112][INFO ][node                     ] [Smart Alec] initialized
[2016-10-25 00:44:02,112][INFO ][node                     ] [Smart Alec] starting ...
[2016-10-25 00:44:02,240][INFO ][transport                ] [Smart Alec] publish_address {172.17.0.3:9300}, bound_addresses {[::]:9300}
[2016-10-25 00:44:02,256][INFO ][discovery                ] [Smart Alec] elasticsearch/bS55H1eARhyiaYVSdKs1lg
[2016-10-25 00:44:05,459][INFO ][cluster.service          ] [Smart Alec] new_master {Smart Alec}{bS55H1eARhyiaYVSdKs1lg}{172.17.0.3}{172.17.0.3:9300}, reason: zen-disco-join(elected_as_master, [0] joins received)
[2016-10-25 00:44:05,483][INFO ][http                     ] [Smart Alec] publish_address {172.17.0.3:9200}, bound_addresses {[::]:9200}
[2016-10-25 00:44:05,483][INFO ][node                     ] [Smart Alec] started
[2016-10-25 00:44:05,547][INFO ][gateway                  ] [Smart Alec] recovered [0] indices into cluster_state
$
```

scale to 3 nodes

```
$ k scale --replicas=3 rc elasticsearch
replicationcontroller "elasticsearch" scaled

$ k get pods
NAME                  READY     STATUS    RESTARTS   AGE
elasticsearch-phypm   1/1       Running   0          12s
elasticsearch-ps85i   1/1       Running   0          12s
elasticsearch-rsa59   1/1       Running   0          2m
```

check out logs - notice no changes to the number of nodes in cluster...

```
$ k logs elasticsearch-rsa59
[2016-10-25 00:43:58,907][INFO ][node                     ] [Smart Alec] version[2.4.1], pid[1], build[c67dc32/2016-09-27T18:57:55Z]
[2016-10-25 00:43:58,907][INFO ][node                     ] [Smart Alec] initializing ...
[2016-10-25 00:43:59,589][INFO ][plugins                  ] [Smart Alec] modules [reindex, lang-expression, lang-groovy], plugins [], sites []
[2016-10-25 00:43:59,612][INFO ][env                      ] [Smart Alec] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/sda1)]], net usable_space [15.4gb], net total_space [17.8gb], spins? [possibly], types [ext4]
[2016-10-25 00:43:59,612][INFO ][env                      ] [Smart Alec] heap size [1007.3mb], compressed ordinary object pointers [true]
[2016-10-25 00:44:02,112][INFO ][node                     ] [Smart Alec] initialized
[2016-10-25 00:44:02,112][INFO ][node                     ] [Smart Alec] starting ...
[2016-10-25 00:44:02,240][INFO ][transport                ] [Smart Alec] publish_address {172.17.0.3:9300}, bound_addresses {[::]:9300}
[2016-10-25 00:44:02,256][INFO ][discovery                ] [Smart Alec] elasticsearch/bS55H1eARhyiaYVSdKs1lg
[2016-10-25 00:44:05,459][INFO ][cluster.service          ] [Smart Alec] new_master {Smart Alec}{bS55H1eARhyiaYVSdKs1lg}{172.17.0.3}{172.17.0.3:9300}, reason: zen-disco-join(elected_as_master, [0] joins received)
[2016-10-25 00:44:05,483][INFO ][http                     ] [Smart Alec] publish_address {172.17.0.3:9200}, bound_addresses {[::]:9200}
[2016-10-25 00:44:05,483][INFO ][node                     ] [Smart Alec] started
[2016-10-25 00:44:05,547][INFO ][gateway                  ] [Smart Alec] recovered [0] indices into cluster_state$
$
```

service - exposing - note the error

```
$ k expose rc elasticsearch --type=NodePort
Error from server: services "elasticsearch" already exists
```

```
$ minikube service elasticsearch --url
http://192.168.64.7:32165
```

```
$ curl http://192.168.64.7:32165/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

Note: there is only one node in this cluster, I must have removed a config from the original kubernetes example.

I tried the original [example](https://github.com/kubernetes/kubernetes/tree/master/examples/elasticsearch) - worked

```
$ curl http://192.168.64.7:30040/_cluster/health?pretty
{
  "cluster_name" : "myesdb",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0
}
```
