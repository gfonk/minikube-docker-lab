# readme - mongo

goal: developer setup for local workstation

## reference
- [docker - official mongo](https://hub.docker.com/r/library/mongo/)
-  remove this:
  - [work link - news](https://wiki.inbcu.com/display/NEWSCONTAPI/Local+Development+Environment+Setup+and+Production+DB+dump)

- kubernetes:
  - [documentation on pod templates suck - u have to dig](http://kubernetes.io/docs/user-guide/pod-templates/)
  - [pod template - replicationcontroller](http://kubernetes.io/docs/user-guide/replication-controller/)
    - the example is really old

## requirements
  - version 3.0
  - persistant disk (in order to save the data)
  - 1 node only (for now)

## notes

- mongodb:
  - port 27017 - The default port for mongod and mongos instances. You can change this port with port or --port.
  - port 27018 - The default port when running with --shardsvr runtime operation or the shardsvr value for the clusterRole setting in a configuration file.

- kubernetes:
  - not going to use `deployment` as the controller (not sure if it's prod ready)

- docker:
  - grab the image from `hub.docker.com`
    - `docker pull mongo:3.0` (pull the image on local machine)
    - always good to grab the image locally (just in case you want to work offline)


```
$ docker images mongo
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
mongo               3.0                 261330dfe2d0        4 days ago          271.1 MB
```

cool

1. create the `rc` and `svc` file
2. test `rc` and `svc` file with basic attributes

```
$ touch mongo-{rc,svc}.yaml

# add some fundemental steps on file

$ k create -f mongo-rc.yaml
$ k expose rc mongo --type=NodePort
$ minikube service mongo --url
http://192.168.64.7:31727
```

test login, note: no username and no pasword

```
$ mongo  192.168.64.7:31727
MongoDB shell version: 3.2.3
connecting to: 192.168.64.7:31727/test
Server has startup warnings:
2016-10-26T07:37:25.101+0000 I CONTROL  [initandlisten]
2016-10-26T07:37:25.101+0000 I CONTROL  [initandlisten] ** WARNING: /sys/kernel/mm/transparent_hugepage/enabled is 'always'.
2016-10-26T07:37:25.101+0000 I CONTROL  [initandlisten] **        We suggest setting it to 'never'
2016-10-26T07:37:25.101+0000 I CONTROL  [initandlisten]
2016-10-26T07:37:25.101+0000 I CONTROL  [initandlisten] ** WARNING: /sys/kernel/mm/transparent_hugepage/defrag is 'always'.
2016-10-26T07:37:25.101+0000 I CONTROL  [initandlisten] **        We suggest setting it to 'never'
2016-10-26T07:37:25.101+0000 I CONTROL  [initandlisten]
>
```

ok, let's try to configure the `svc` file

```
$ k create -f mongo-svc.yaml
service "mongo" created

$ k get services
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
kubernetes   10.0.0.1     <none>        443/TCP     1d
mongo        10.0.0.209   <nodes>       27017/TCP   5s

$ k describe service mongo
Name:			mongo
Namespace:		default
Labels:			app=mongo
Selector:		component=mongo
Type:			NodePort
IP:			10.0.0.209
Port:			mongo	27017/TCP
NodePort:		mongo	32754/TCP
Endpoints:		<none>
Session Affinity:	None
```

something is wrong...

```
$ minikube service mongo --url
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
```

no endpoint...

```
$ k describe services mongo
Name:			mongo
Namespace:		default
Labels:			app=mongo
Selector:		component=mongo
Type:			NodePort
IP:			10.0.0.254
Port:			mongo	27017/TCP
NodePort:		mongo	31872/TCP
Endpoints:		<none>
Session Affinity:	None
```

not sure how to connect to the mongodb Server

- try endpoint?
- `mongo-endpoint.yaml` config is not working

```
$ k describe endpoints mongo
Name:		mongo
Namespace:	default
Labels:		<none>
Subsets:
  Addresses:		192.168.64.7
  NotReadyAddresses:	<none>
  Ports:
    Name	Port	Protocol
    ----	----	--------
    <unset>	9376	TCP

No events

$ mongo 192.168.64.7:9376
MongoDB shell version: 3.2.3
connecting to: 192.168.64.7:9376/test
2016-10-25T23:34:05.486-1000 W NETWORK  [thread1] Failed to connect to 192.168.64.7:9376, reason: errno:61 Connection refused
2016-10-25T23:34:05.487-1000 E QUERY    [thread1] Error: couldn't connect to server 192.168.64.7:9376, connection attempt failed :
connect@src/mongo/shell/mongo.js:226:14
@(connect):1:6

exception: connect failed
```

```
$ k delete service mongo

- In this directory:
  - svc file doesn't work
  - endpoint file doesn't work
  - mongo-loadbalancer-test.yaml doesn't work


This works... i need to figure out what is the fix.

```
$ k create -f mongo-rc.yaml
$ k expose rc mongo --type=NodePort
$ minikube service mongo --url
```

ok.  got it working.  i still need to do some homework on networking... let's start from scratch

```
00:02 $ k create -f mongo-rc.yaml
replicationcontroller "mongo" created

$ k create -f mongo-svc.yaml
service "mongo" created

$ k get services
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
kubernetes   10.0.0.1     <none>        443/TCP     1d
mongo        10.0.0.244   <pending>     27017/TCP   5s

$ k get services
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
kubernetes   10.0.0.1     <none>        443/TCP     1d
mongo        10.0.0.244   <pending>     27017/TCP   14s

$ minikube service mongo --url
http://192.168.64.7:32318

$ mongo 192.168.64.7:32318
MongoDB shell version: 3.2.3
connecting to: 192.168.64.7:32318/test
Server has startup warnings:
2016-10-26T10:03:43.652+0000 I CONTROL  [initandlisten]
2016-10-26T10:03:43.652+0000 I CONTROL  [initandlisten] ** WARNING: /sys/kernel/mm/transparent_hugepage/enabled is 'always'.
2016-10-26T10:03:43.652+0000 I CONTROL  [initandlisten] **        We suggest setting it to 'never'
2016-10-26T10:03:43.652+0000 I CONTROL  [initandlisten]
2016-10-26T10:03:43.652+0000 I CONTROL  [initandlisten] ** WARNING: /sys/kernel/mm/transparent_hugepage/defrag is 'always'.
2016-10-26T10:03:43.652+0000 I CONTROL  [initandlisten] **        We suggest setting it to 'never'
2016-10-26T10:03:43.652+0000 I CONTROL  [initandlisten]
>
```
