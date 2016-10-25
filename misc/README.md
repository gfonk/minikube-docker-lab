# Misc Questions/Spikes

#### question: how do i deploy an image to the cluster from hub.docker.com?

- similar to : `kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080`

```
# commands i'm testing
# want to see an exposed port for the browser

$ kubectl run hello-world --image=hello-world:latest --port=8888
$ kubectl expose deployment hello-world --type=NodePort


$ kubectl run hello-world --image=hello-world:latest --port=8888
deployment "hello-world" created

$ kubectl expose deployment hello-world --type=NodePort
service "hello-world" exposed

$ k get pods
NAME                              READY     STATUS             RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running            1          39m
hello-world-3201287124-pj253      0/1       CrashLoopBackOff   2          1m

$ k get services
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
hello-minikube   10.0.0.51    <nodes>       8080/TCP   39m
hello-world      10.0.0.132   <nodes>       8888/TCP   24s
kubernetes       10.0.0.1     <none>        443/TCP    44m

$ minikube service hello-world --url
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
```

yikes... doesn't look good...

let's try to delete


```
$ k get pods
NAME                              READY     STATUS             RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running            1          41m
hello-world-3201287124-pj253      0/1       CrashLoopBackOff   4          3m

$ k delete pod hello-world-3201287124-pj253
pod "hello-world-3201287124-pj253" deleted

$ k get pods
NAME                              READY     STATUS              RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running             1          42m
hello-world-3201287124-af8fr      0/1       ContainerCreating   0          3s

$ k get pods
NAME                              READY     STATUS             RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running            1          42m
hello-world-3201287124-af8fr      0/1       CrashLoopBackOff   1          10s
✔ ~
11:04 $
```

ok deleted; trying again

```
$ k get pods
NAME                              READY     STATUS      RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running     1          43m
hello-world-3201287124-af8fr      0/1       Completed   3          1m

$ k get pods
NAME                              READY     STATUS      RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running     1          43m
hello-world-3201287124-af8fr      0/1       Completed   3          1m

$ k get services
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
hello-minikube   10.0.0.51    <nodes>       8080/TCP   43m
hello-world      10.0.0.132   <nodes>       8888/TCP   3m
kubernetes       10.0.0.1     <none>        443/TCP    47m

$ kubectl expose deployment hello-world --type=NodePort
Error from server: services "hello-world" already exists


$ k service hello-world --url
Error: unknown command "service" for "kubectl"
Run 'kubectl --help' for usage.

$ minikube service hello-world --url
Waiting, endpoint for service is not ready yet...
Waiting, endpoint for service is not ready yet...
...
```

- not sure what i am doing wrong...
- BAH!  [hello-world](https://hub.docker.com/r/library/hello-world/) doesn't have a service out
- the pod has to have a port service out!!!
- how about `tomcat:8.0.38-jre8-alpine`

```
kubectl run tomcat-test --image=tomcat:8.0.38-jre8-alpine --port=8080
kubectl expose deployment tomcat-test --type=NodePort
minikube service tomcat-test --url

$ minikube service tomcat-test --url
http://192.168.64.7:31933

# checkout service with browser
$ open $(minikube service tomcat-test --url)

```

#### question: how do you remove a pod?

```
$ k get pods
NAME                              READY     STATUS             RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running            1          1h
hello-world-3201287124-xfczl      0/1       CrashLoopBackOff   6          6m
tomcat-test-1113507641-1u4t4      1/1       Running            0          22m

$ k get deployment
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-minikube   1         1         1            1           1h
hello-world      1         1         1            0           36m
tomcat-test      1         1         1            1           22m
```

i want to remove `hello-world` permanently, but everytime i _delete_ the pod, it comes back up

```
$ k delete pod hello-world-3201287124-xfczl
pod "hello-world-3201287124-xfczl" deleted
✔ ~

$ k get pods
NAME                              READY     STATUS      RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running     1          1h
hello-world-3201287124-c2j42      0/1       Completed   0          4s
tomcat-test-1113507641-1u4t4      1/1       Running     0          24m
```

replica set

```
$ k get rs
NAME                        DESIRED   CURRENT   READY     AGE
hello-minikube-3015430129   1         1         1         1h
hello-world-3201287124      1         1         0         39m
tomcat-test-1113507641      1         1         1         25m
```

got it... delete the deployment

```
$ k get deployment
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-minikube   1         1         1            1           1h
hello-world      1         1         1            0           36m
tomcat-test      1         1         1            1           22m

$ k delete deployment hello-world
deployment "hello-world" deleted

$ k get pods
NAME                              READY     STATUS    RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running   1          1h
tomcat-test-1113507641-1u4t4      1/1       Running   0          26m

```

Sweet!


#### question - how to create two pods with a replication of two?

- [documentation - pods](http://kubernetes.io/docs/user-guide/pods/single-container/#creating-a-pod)

```
kubectl run NAME
    --image=image
    [--port=port]
    [--replicas=replicas]
    [--labels=key=value,key=value,...]
```


```
# delete tomcat-test if a deployment exists
$ k delete deployment tomcat-test

# re-create tomcat-test with 2 replications and a label
$ k run tomcat-test --image=tomcat:8.0.38-jre8-alpine --port=8080 --replicas=2 --labels=app=tomcat,env=dev

$ k get pods
NAME                              READY     STATUS    RESTARTS   AGE
hello-minikube-3015430129-nmlu5   1/1       Running   1          1h
tomcat-test-710919480-u9qlt       1/1       Running   0          14s
tomcat-test-710919480-wmr57       1/1       Running   0          14s

$ kubectl get pods --selector=app=tomcat
NAME                           READY     STATUS    RESTARTS   AGE
tomcat-test-1550501914-45d8p   1/1       Running   0          2m
tomcat-test-1550501914-kriwd   1/1       Running   0          2m
```

delete all deployments

```
$ k delete deployment tomcat-test
$ k delete deployment hello-minikube
```

#### question - how do i create a pod file and push that deployment to my local minikube?

- [ ] create a nginx deployment file (yaml)
	- `nginix:1.10.1-alpine`

- [documentation - multi-container pod](http://kubernetes.io/docs/user-guide/pods/multi-container/)
- [example-nginx](http://containertutorials.com/get_started_kubernetes/k8s_example.html)
- thought: i wonder if there is a command to create a template YAML file?
- read _direct pod creation_ or use _deployment_ (from multi-container doc)
	- both use `create` command

		- create-a-pod directly
			- kind: Pod

		- create-a-pod-through-[deployment](http://kubernetes.io/docs/user-guide/deployments/)
			- kind: Deployment

- Reference: [documentation - multi-container pod](http://kubernetes.io/docs/user-guide/pods/multi-container/)
	- not 100% sure if `deployment` method is production-level, since I notice that it references a newer version of the API.
		- `apiVersion: extensions/v1beta1`

```
Multi-container pods must be created with the create command. Properties are passed to the command as a YAML- or JSON-formatted configuration file.

The create command can be used to create a pod directly, or it can create a pod or pods through a Deployment. It is highly recommended that you use a Deployment to create your pods. It watches for failed pods and will start up new pods as required to maintain the specified number.

If you don’t want a Deployment to monitor your pod (e.g. your pod is writing non-persistent data which won’t survive a restart, or your pod is intended to be very short-lived), you can create a pod directly with the create command.
```

I'm going to ignore _create-a-pod-through-deployment_ for now.

Initiating [pod](https://github.com/gfonk/minikube-docker-lab/blob/master/nginx/nginx-pod.yaml)

```
# kubectl create -f FILE
$ kubectl create -f nginx-pod.yaml

$ k get pods
NAME          READY     STATUS    RESTARTS   AGE
nginx-8evl7   1/1       Running   0          1m
nginx-otra1   1/1       Running   0          1m

# expose the service
$ k expose replicationcontroller nginx --type=NodePort
service "nginx" exposed

# output the URL
$ minikube service nginx --url
http://192.168.64.7:32397

# browse
$ open $(minikube service nginx --url)
```

Cleanup

```
$ k get rc
NAME      DESIRED   CURRENT   READY     AGE
nginx     2         2         2         18m

$ k delete rc nginx
replicationcontroller "nginx" deleted
✔ ~/src/github-gfonk-other/minikube-docker-lab/nginx [master|✚ 1]

$ k get pods
```

- Cool.  works with `kind: ReplicationController`.
- Let's try `kind: Deployment` (i'm curious) with [nginx](https://github.com/gfonk/minikube-docker-lab/blob/master/nginx/nginx-deployment.yaml)

```
$ k create -f nginx-deployment.yaml
deployment "nginx-deployment" created

$ k expose deployment nginx-deployment --type=NodePort
service "nginx-deployment" exposed

# browse
$ open $(minikube service nginx-deployment --url)
```

- Works.
- question: why does kubernetes recommend _Deployment method_ when it's `apiVersion: extensions/v1beta1`?  Documentation seems to be stale for kubernetes.
- More on the [api](https://github.com/kubernetes/kubernetes/blob/master/docs/api.md)

note: delete services

```
$ k delete services  hello-minikube  nginx tomcat-test
service "hello-minikube" deleted
service "nginx" deleted
service "tomcat-test" deleted

$ k get services
NAME               CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes         10.0.0.1     <none>        443/TCP   3h
nginx-deployment   10.0.0.106   <nodes>       80/TCP    17m
```

output yaml of nginx-deployment
	- `k get deployments nginx-deployment --output=yaml`
	- `k get service nginx-deployment --output=yaml`

```
$ k get service nginx-deployment --output=yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: 2016-10-24T23:35:34Z
  labels:
    app: nginx
  name: nginx-deployment
  namespace: default
  resourceVersion: "14155"
  selfLink: /api/v1/namespaces/default/services/nginx-deployment
  uid: 8f490402-9a42-11e6-8c2b-3a9c6a00bbcc
spec:
  clusterIP: 10.0.0.106
  ports:
  - nodePort: 30125
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```
