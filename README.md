# minikube-docker-lab
Personal lab (with notes) - minikube with docker

# [minikube](https://github.com/kubernetes/minikube)
- date: Mon Oct 24 11:52:09 HST 2016


- my environment:
	- mac
	- docker for mac installed, configured, and running
	- configured `~/.docker/config.json` for public and private images
	- using mac xhyve
	- no VPN running, no proxy needed
	- editor:
		- atom (w yamlLint)

### minikube - documentation and links
- [github - minikube](https://github.com/kubernetes/minikube)
- [github - minikube - docs](https://github.com/kubernetes/minikube/blob/master/docs/minikube.md)

- these links may bet outdated quickly:
	- [mac install](https://github.com/kubernetes/minikube/blob/v0.12.0/README.md)
	- [mac xhyve-driver](https://github.com/kubernetes/minikube/blob/v0.12.0/DRIVERS.md#xhyve-driver)

### kubernetes and kubectl - documentation and links
- [github - kubernetes](https://github.com/kubernetes/kubernetes)
- [cheat sheet](http://kubernetes.io/docs/user-guide/kubectl-cheatsheet/)

**install**

[mac install](https://github.com/kubernetes/minikube/blob/v0.12.0/README.md)


**install driver**

[mac xhyve-driver](https://github.com/kubernetes/minikube/blob/v0.12.0/DRIVERS.md#xhyve-driver)

```
$ brew install docker-machine-driver-xhyve

# docker-machine-driver-xhyve need root owner and uid
$ sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
$ sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
```

**start minikube with xhyve**

```
# minikube --vm-driver=xxx start
$ minikube --vm-driver=xhyve start

# minikube-start alias
$ echo "alias minikube-start='minikube --vm-driver=xhyve start'" >> ~/.basrhc
```

or place the config in minikube

```
$ minikube config set vm-driver xhyve
$ minikube stop
$ minikube start
```

**issues with starting**

```
# just in case - moving .kube out
mv .kube .kube-nbcu-latest/
```

woohoo - works

```
$ minikube --vm-driver=xhyve start
Starting local Kubernetes cluster...
Kubectl is now configured to use the cluster.
```

```
$ kubectl cluster-info
Kubernetes master is running at https://192.168.64.7:8443
kubernetes-dashboard is running at https://192.168.64.7:8443/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

intersesting - the install does create a `.kube` and `.minikube`

```
$ ls -lat | head -5
total 728
drwxr-xr-x+ 123 Gerald  staff   4182 Oct 24 10:17 .
drwxr-xr-x    3 Gerald  staff    102 Oct 24 10:17 .kube
drwxr-xr-x   15 Gerald  staff    510 Oct 24 10:17 .minikube
drwx------+  45 Gerald  staff   1530 Oct 24 10:12 Desktop
```

Testing install with **README.md**

- https://github.com/kubernetes/minikube/blob/v0.12.0/README.md

```
$ kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080
deployment "hello-minikube" created

$ kubectl expose deployment hello-minikube --type=NodePort
service "hello-minikube" exposed

$ kubectl get pod
NAME                              READY     STATUS    RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running   0          35s

$ curl $(minikube service hello-minikube --url)
CLIENT VALUES:
client_address=172.17.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://192.168.64.7:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=192.168.64.7:30299
user-agent=curl/7.43.0
BODY:
-no body in request-✔ ~
10:22 $ minikube stop
Stopping local Kubernetes cluster...
Machine stopped.
```

- from above:
	- ah interesting...
		- google [private registry](https://cloud.google.com/container-registry/)
		- exposed port on the local
			- `minikube service hello-minikube --url`
			- browser -> http://192.168.64.7:30299

**dashboard**

```
$ minikube dashboard
Opening kubernetes dashboard in default browser...
```

the service for the dashboard

```
$ k describe service kubernetes
Name:			kubernetes
Namespace:		default
Labels:			component=apiserver
			provider=kubernetes
Selector:		<none>
Type:			ClusterIP
IP:			10.0.0.1
Port:			https	443/TCP
Endpoints:		192.168.64.7:8443
Session Affinity:	ClientIP

$ k get service kubernetes --output=yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2016-10-24T20:17:30Z
  labels:
    component: apiserver
    provider: kubernetes
  name: kubernetes
  namespace: default
  resourceVersion: "7"
  selfLink: /api/v1/namespaces/default/services/kubernetes
  uid: e426c713-9a26-11e6-9eea-8acd2637f68d
spec:
  clusterIP: 10.0.0.1
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: 443
  sessionAffinity: ClientIP
  type: ClusterIP
status:
  loadBalancer: {}
```
