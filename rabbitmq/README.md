# readme - mongo

goal: developer setup for local workstation

## reference
- [docker - official mongo](https://hub.docker.com/r/library/rabbitmq/tags/)
-  remove this:
  - [work link - news](https://wiki.inbcu.com/display/NEWSCONTAPI/Local+Development+Environment+Setup+and+Production+DB+dump)

- kubernetes:
  - [documentation on pod templates suck - u have to dig](http://kubernetes.io/docs/user-guide/pod-templates/)
  - [pod template - replicationcontroller](http://kubernetes.io/docs/user-guide/replication-controller/)
    - the example is really old

## requirements
  - version 3.5.7
  - persistant disk (in order to save the data)
  - 1 node only (for now)

## notes

- `docker pull rabbitmq:3.5.7-management`
- ports:
  - 5672
  - 8080


```
$ k create -f rabbitmq-rc.yaml
$ k create -f rabbitmq-svc.yaml
```

console onto container

```
k exec -ti rabbitmq-ti999 /bin/bash
```

example of services

```
$ k describe service rabbitmq
Name:			rabbitmq
Namespace:		default
Labels:			<none>
Selector:		app=rabbitmq
Type:			LoadBalancer
IP:			10.0.0.28
Port:			rabbitmq-default	5672/TCP
NodePort:		rabbitmq-default	31712/TCP
Endpoints:		172.17.0.2:5672
Port:			rabbitmq-console	15672/TCP
NodePort:		rabbitmq-console	30429/TCP
Endpoints:		172.17.0.2:15672
Session Affinity:	None

$ minikube service rabbitmq --url
http://192.168.64.7:31712

# open browser to http://192.168.64.7:30429/#/
```
