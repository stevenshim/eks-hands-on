## 1. PV & EBS
Stateful 성향의 서비스는 Disk 기반의 저장소를 필요로 합니다. <br>
경우에 따라 정적인 PV를 생성하는 경우도 있지만, 실제 환경에서는 주로 Dynamic Volume Provisioning 을 사용하게 되리라 예상됩니다. <br> 
이 chapter는 EKS에서 사용하는 PersistentVolume(PV), StorageClass(SC), PersistentVolumeClaim(PVC) 등에 대한 일부 특징을 다룹니다.

### 1-1. StorageClass 기본
StorageClass 는 관리자가 사용자에게 제공할 수 있는 volume들의 class(종류)들을 정의하는 기능입니다.<br>
SC는 현재 아래 2가지 방식으로 제공됩니다.
* in-tree EBS Plugin 
* EBS CSI Driver (Constainer Storage Interface)
결국엔, in-tree 방식은 deprecated 되리라 생각됩니다.

(v1.11 이상) EKS 생성 시, in-tree EBS Plugin과 기본 StorageClass는 생성되어 있습니다.
```yaml
$ k describe sc gp2
Name:            gp2
IsDefaultClass:  Yes
Annotations: storageclass.kubernetes.io/is-default-class=true
Provisioner:           kubernetes.io/aws-ebs
Parameters:            fsType=ext4,type=gp2
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
```

즉, Dynamic Volume Provisioning 은 PVC가 준비된다면 EBS 기반으로 바로 사용 가능합니다.

관련 문서
* [EKS Workshop](https://eksworkshop.com/statefulset/storageclass/)
* [AWS EKS StorageClass](https://docs.aws.amazon.com/en_pv/eks/latest/userguide/storage-classes.html)
* [K8S StorageClass Document](https://kubernetes.io/docs/concepts/storage/storage-classes/)
* [Reclaim Policy](https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/#why-change-reclaim-policy-of-a-persistentvolume)


### 1-2. PVC를 활용해 PV 할당받기
Dynamic Volume Provisioning을 위해 먼저 PVC를 생성합니다. <br>

아래 manifest를 작성 후, mongodb-pvc.yaml로 저장합니다.
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-pvc
spec:
  resources:
    requests:
      storage: 10Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: "gp2"
```
```
$ k apply -f mongo-pvc.yaml
persistentvolumeclaim/mongodb-pvc created
```

이제 Pod를 만들어 배포해보도록 합니다.
```
apiVersion: v1
kind: Pod
metadata:
  name: mongodb
spec:
  containers:
  - image: mongo
    name: mongodb
    volumeMounts:
    - name: mongodb-data
      mountPath: /data/db
    ports:
    - containerPort: 27017
      protocol: TCP
  volumes:
  - name: mongodb-data
    persistentVolumeClaim:
      claimName: mongodb-pvc
```
```
$ k apply -f mongo.yaml
pod/mongodb created

$ k get po
NAME      READY   STATUS    RESTARTS   AGE
mongodb   1/1     Running   0          16s

## Container 내부에 volume 확인
$ k exec mongodb lsblk
NAME          MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
nvme0n1       259:0    0  10G  0 disk
|-nvme0n1p1   259:1    0  10G  0 part /etc/hosts
`-nvme0n1p128 259:2    0   1M  0 part
nvme1n1       259:3    0  10G  0 disk /data/db

$ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS   REASON   AGE
pvc-9b12a300-ee72-11e9-ba13-0241978a6fce   10Gi       RWO            Delete           Bound    krug/mongodb-pvc   gp2                     2m9s
```

EBS 볼륨에는 자동으로 Tag가 달려 관리됩니다.
![](../../images/ebs-pv.png)

### 1-3. 생성된 Pod 삭제하기
위 단계에서 생성한 Pod를 지운다면 EBS볼륨은 어떻게 될까요?
```
$ k delete -f mongo.yaml
pod "mongodb" deleted

$ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM              STORAGECLASS   REASON   AGE
pvc-c404027e-ee76-11e9-b46b-0a642f7dec9c   10Gi       RWO            Delete           Bound      krug/mongodb-pvc   gp2                     6s
```
EBS Volume 상태 - detached 로 유지
![](../../images/ebs-detached.png)


### 1-4. 생성된 PVC 삭제하기
이번엔 이전 단계에서 생성한 PVC도 삭제해봅니다.
```
$ k delete -f mongo-pvc.yaml
persistentvolumeclaim "mongodb-pvc" deleted
```
당연히 PV도 같이 삭제되며, EBS 볼륨도 삭제됩니다.
![](../../images/no-ebs.png)

### 1-5. Reclaim Policy 에 따른 EBS 상태
Reclaim Policy는 특별히 설정하지 않을 경우 기본 `Delete` 로 설정며, 중요한 Data를 가지는 경우 `Retain`으로 생성 가능합니다. <br>

`Delete`<br>
Dynamic Volume Provisioning 생성된 PV의 경우, 생성될 때 연결된 PVC가 있습니다. 이 PVC가 삭제된다면 PV도 같이 삭제되고, EBS볼륨이 사라집니다.

`Retain`<br>
이 옵션으로 생성된 PV의 경우, PVC가 사라져도 PV는 유지되며, EBS도 마찬가지로 유지됩니다.

```
$ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM              STORAGECLASS   REASON   AGE
pvc-599c09a6-ee75-11e9-ba13-0241978a6fce   10Gi       RWO            Retain           Released   krug/mongodb-pvc   custom-gp2              9m4s
```

### 1-6. AWS EBS 기반 PV의 Access Mode
EBS의 경우 availability zones에 종속적이며, 생성된 EBS는 AZ를 건너뛰며 attach가 불가능합니다. <br>
게다가 동시에 N개의 EC2 에 attach도 불가능합니다.<br>
즉, EKS에서 PV를 사용 할 때에도 Access Mode는 ReadWriteOnce로 제한됩니다.

만약 EKS 에서 EFS 기반의 PV를 만들어 Access Mode를 RWX (ReadWriteMany) 로 설정하고 싶으면 아래 문서 참고하세요.

관련 문서
* [Access Modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)
* [k8s-incubator EFS](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs)

### 1-7. 사용중인 EBS를 강제로 Detach 하거나 Delete 한다면?
운영환경에서는 아무도 이런 시도를 하지 않으시겠지만... 해당 volume을 사용하는 pod는 정상적으로 동작하지 않으며, 자동으로 복구되지도 않습니다. 

PV 정리 및 Pod를 재생성 해야 합니다.

### 1-7. EBS Limits
한 대의 Linux EC2에는 EBS가 40개 이상 붙으면 부팅이 안될 수 있다고 하네요.
- [EBS Limits](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/volume_limits.html)

### 1-9. EBS CSI Driver
...
관련 문서
* 공식 k8s 문서: https://kubernetes.io/docs/concepts/storage/volumes/#csi-migration
* CSI Driver 소스코드: https://github.com/kubernetes-sigs/aws-ebs-csi-driver