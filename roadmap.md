# Plank Roadmap

> **Mục tiêu:** biến một repository rỗng thành **control repository** cho toàn bộ private platform: Proxmox infrastructure, VM/CT lifecycle, baseline configuration, Kubernetes, observability, storage, webapps, WisdomTree/RAG, engineering compute và media services.
>
> **Nguyên tắc:** học từng lớp theo đúng trách nhiệm. Không dựng Kubernetes, Elastic, Grafana hay NAS trước khi lớp bên dưới đã hiểu và chạy ổn định.

---

## 0. North Star

`plank` không phải là nơi chứa source code của WisdomTree, Gleworks hay các application khác.

`plank` là nơi mô tả và vận hành **platform mà các application đó chạy trên**.

```text
Application repositories
├── WisdomTree
├── Gleworks / Portfolio
├── future webapps
└── engineering applications
          │
          │ build / deploy
          ▼
========================================================
                    PLANK PLATFORM
========================================================
          │
          ├── Kubernetes / runtime
          ├── monitoring / logging
          ├── databases / storage integration
          ├── networking / ingress
          ├── VM / CT
          └── Proxmox
========================================================
          │
          ▼
                    Physical metal
```

Mục tiêu cuối:

```text
Git
 │
 ├── Terraform  ──► tạo infrastructure
 │
 ├── Ansible    ──► cấu hình operating system
 │
 ├── Kubernetes ──► chạy / orchestration workloads
 │
 └── manifests  ──► deploy platform services
                     │
                     ├── WisdomTree
                     ├── Gleworks
                     ├── Prometheus
                     ├── Grafana
                     ├── logging
                     ├── media services
                     └── internal platform services
```

---

# 1. Platform boundaries

Trước khi code, giữ rõ trách nhiệm của từng tool.

## Terraform

Terraform quản lý **resource lifecycle**.

Ví dụ:

```text
Proxmox VM
CPU
RAM
disk
network interface
cloud-init parameters
IP allocation
```

Terraform trả lời:

> "Máy nào cần tồn tại?"

Không dùng Terraform làm package manager hoặc cấu hình chi tiết bên trong Ubuntu.

---

## Ansible

Ansible quản lý **machine configuration**.

Ví dụ:

```text
users
SSH
packages
Docker
NTP
firewall baseline
directories
systemd
Kubernetes prerequisites
GPU driver prerequisites
```

Ansible trả lời:

> "Máy đã tồn tại thì cần được cấu hình như thế nào?"

---

## Kubernetes

Kubernetes quản lý **application/runtime workload**.

Ví dụ:

```text
WisdomTree
Gleworks
Prometheus
Grafana
Ingress
internal API
workers
```

Kubernetes trả lời:

> "Application nào phải chạy, chạy bao nhiêu instance, network và storage của nó ra sao?"

---

## NAS / TrueNAS

TrueNAS thuộc **storage plane**, không phải orchestration plane.

Nó chịu trách nhiệm:

```text
datasets
snapshots
shares
media
engineering data
backup targets
persistent storage
```

Kubernetes có thể **consume storage từ NAS**, nhưng NAS không phải một service bình thường để Kubernetes quản lý như một webapp.

---

# 2. Kiến trúc đích

```text
                         Internet
                            │
                      Router / Firewall
                            │
                      Managed Network
                            │
             ┌──────────────┴──────────────┐
             │                             │
          CORE NODE                    COMPUTE NODE
          Proxmox                       Proxmox
             │                             │
      ┌──────┼────────┐              ┌─────┼─────────┐
      │      │        │              │     │         │
   k8s VM   DB VM   utility VM    compute VM      AI/GPU
      │
      ▼
 Kubernetes cluster
      │
      ├── ingress
      ├── WisdomTree
      ├── Gleworks
      ├── future apps
      ├── Prometheus
      ├── Grafana
      └── logging

                         │
                         ▼
                    NAS / TrueNAS
                         │
             ┌───────────┼───────────┐
             │           │           │
          backup     engineering    media
                         │           │
                         │      music / video
                         │           │
                         └───────────┘
```

Không cần đạt kiến trúc này ngay từ đầu.

Roadmap bên dưới đi từ nhỏ đến lớn.

---

# 3. Repository evolution

## Giai đoạn đầu

```text
plank/
├── README.md
└── roadmap.md
```

## Sau khi bắt đầu IaC

```text
plank/
├── README.md
├── roadmap.md
│
├── docs/
│   ├── architecture.md
│   ├── networking.md
│   ├── storage.md
│   └── decisions/
│
├── terraform/
│   ├── modules/
│   └── environments/
│       └── lab/
│
├── ansible/
│   ├── inventories/
│   │   └── lab/
│   ├── playbooks/
│   └── roles/
│
├── kubernetes/
│   ├── platform/
│   ├── observability/
│   ├── storage/
│   └── apps/
│
├── scripts/
│
└── Makefile
```

Không tạo toàn bộ folder ngay lập tức.

Chỉ tạo folder khi phase tương ứng bắt đầu.

---

# 4. Phase 0 — Local IaC sandbox

## Mục tiêu

Hiểu Terraform và Ansible trước khi đụng vào Proxmox.

Không provisioning thật.

Không Kubernetes.

Không Docker platform.

Không production service.

---

## 4.1 Terraform cơ bản

Học:

- provider
- resource
- variable
- output
- state
- plan
- apply
- destroy
- dependency graph
- idempotency
- lifecycle cơ bản

Bài tập đầu tiên nên cực nhỏ:

```text
terraform init
terraform plan
terraform apply
terraform destroy
```

Có thể dùng resource local đơn giản để hiểu lifecycle trước.

### Exit criteria

Bạn phải giải thích được:

```text
configuration
     │
     ▼
terraform plan
     │
     ▼
desired state
     │
     ▼
terraform apply
     │
     ▼
real infrastructure
     │
     ▼
terraform state
```

Và trả lời được:

> Terraform state dùng để làm gì?

---

## 4.2 Ansible cơ bản

Bắt đầu từ chính máy local hoặc một VM test.

Học:

- inventory
- host
- group
- module
- task
- play
- playbook
- variable
- template
- handler
- role
- idempotency

Ví dụ flow:

```text
inventory
   │
   ▼
playbook
   │
   ├── install package
   ├── create user
   ├── copy config
   └── start service
```

### Exit criteria

Chạy cùng playbook hai lần:

```text
run #1 → changed
run #2 → changed=0
```

Bạn phải hiểu tại sao đó là một đặc tính quan trọng.

---

# 5. Phase 1 — Model platform trước khi provision

## Mục tiêu

Mô tả những gì đang có thay vì lập tức tạo VM.

Tạo:

```text
docs/architecture.md
docs/networking.md
```

Mô tả ít nhất:

```text
physical host
CPU
RAM
storage
network bridge
subnet
management IP
node role
```

Ví dụ logical inventory:

```text
proxmox
├── core01
└── compute01
```

Sau đó guest roles:

```text
platform
├── platform-01
├── platform-02
├── database-01
└── utility-01

compute
└── engineering-01
```

Không cần tạo tất cả VM ngay.

---

# 6. Phase 2 — Proxmox template foundation

Đây là bước đầu tiên thực sự quan trọng trước Terraform automation.

## Mục tiêu

Có một base image chuẩn để mọi VM được tạo giống nhau.

Flow:

```text
Ubuntu/Debian cloud image
          │
          ▼
      Proxmox VM
          │
      clean setup
          │
       cloud-init
          │
          ▼
       TEMPLATE
          │
          ├── VM A
          ├── VM B
          └── VM C
```

Template chỉ nên chứa những thứ rất cơ bản.

Không bake toàn bộ application vào template.

### Template nên cung cấp

- base OS;
- cloud-init;
- qemu guest agent;
- SSH capability;
- minimal baseline.

Sau đó Ansible tiếp quản.

### Exit criteria

Từ template:

```text
clone
 ↓
boot
 ↓
receive IP
 ↓
SSH works
```

mà không cần cài OS thủ công.

---

# 7. Phase 3 — Terraform → Proxmox

Đây là lúc Terraform bắt đầu tạo infrastructure thật.

## Mục tiêu đầu tiên

Terraform tạo **một VM duy nhất**.

Không module hóa quá sớm.

Ví dụ:

```text
terraform apply
      │
      ▼
Proxmox API
      │
      ▼
ubuntu-test-01
      │
      ├── CPU
      ├── RAM
      ├── disk
      ├── NIC
      └── cloud-init
```

### Học

- Proxmox provider;
- authentication;
- provider configuration;
- secrets;
- VM resource;
- template clone;
- variables;
- outputs.

### Không commit

```text
API token
password
private key
terraform.tfstate
*.tfvars có secret
```

### Exit criteria

Bạn có thể:

```text
terraform apply
```

→ VM xuất hiện.

Sau đó:

```text
terraform destroy
```

→ VM biến mất.

Rồi apply lại → VM được tái tạo.

Đây là mốc đầu tiên mà infrastructure bắt đầu trở thành **reproducible**.

---

# 8. Phase 4 — Terraform modules

Chỉ module hóa sau khi đã tạo VM bằng tay qua Terraform vài lần.

Target:

```text
terraform/
├── modules/
│   └── proxmox-vm/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── environments/
    └── lab/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

Sau đó có thể mô tả:

```text
platform-01
platform-02
database-01
engineering-01
```

bằng cùng một reusable VM module.

### Exit criteria

Thêm VM mới không cần copy hàng trăm dòng Terraform.

---

# 9. Phase 5 — Terraform → Ansible handoff

Đây là milestone quan trọng.

Terraform tạo máy.

Ansible cấu hình máy.

```text
Terraform
   │
   ├── create VM
   │
   └── output IP
          │
          ▼
       Ansible
          │
          ├── SSH
          ├── users
          ├── packages
          ├── baseline config
          └── services
```

Không cần automation cực kỳ phức tạp ngay.

Ban đầu inventory có thể được cập nhật thủ công.

Sau đó mới tạo dynamic inventory hoặc generate inventory từ Terraform output.

---

# 10. Phase 6 — Ansible OS baseline

Tạo role đầu tiên:

```text
ansible/roles/common
```

Role này cấu hình tất cả Linux guest.

Ví dụ:

```text
common
├── timezone
├── hostname
├── SSH
├── admin users
├── packages
├── curl
├── git
├── vim
├── qemu guest agent
├── monitoring agent later
└── basic security
```

Sau đó các role riêng:

```text
roles/
├── common/
├── docker/
├── kubernetes/
├── database/
└── engineering/
```

### Exit criteria

Một Ubuntu VM mới có thể đi từ:

```text
fresh cloud image
```

đến:

```text
ready platform machine
```

bằng một playbook.

---

# 11. Phase 7 — First full pipeline

Đây là milestone đầu tiên của `plank`.

Command conceptual:

```text
make infra
```

thực hiện:

```text
Terraform
   ↓
create VM
   ↓
Ansible
   ↓
configure OS
   ↓
ready machine
```

Hoặc ban đầu vẫn chạy riêng:

```bash
terraform apply

ansible-playbook ...
```

Điều quan trọng không phải command đẹp.

Điều quan trọng là hiểu từng layer.

### Definition of Done

Có thể xoá một VM và tái tạo nó mà gần như không cấu hình bằng tay.

---

# 12. Phase 8 — Service runtime trước Kubernetes

Trước khi học Kubernetes, nên chạy một vài service bằng Docker Compose.

Ví dụ:

```text
VM
│
└── Docker
    │
    ├── nginx
    ├── sample backend
    └── PostgreSQL test
```

Mục tiêu là hiểu:

```text
application
container
port
volume
network
environment
healthcheck
```

Nếu chưa hiểu những thứ này, Kubernetes sẽ chỉ che thêm abstraction lên trên.

### Exit criteria

Bạn giải thích được:

```text
Browser
   ↓
host port
   ↓
container network
   ↓
application
   ↓
database
```

---

# 13. Phase 9 — Application deployment baseline

Chọn một application không critical trước.

Ví dụ một hello app hoặc Gleworks staging.

Pipeline ban đầu:

```text
Git push
   │
   ▼
CI
   │
   ├── test
   ├── build image
   └── push image
          │
          ▼
       platform
          │
          ▼
       container
```

Sau khi hiểu flow này mới đưa WisdomTree lên.

---

# 14. Phase 10 — Kubernetes foundation

Kubernetes chỉ bắt đầu ở đây.

Không dựng Kubernetes để "học Kubernetes" trước khi hiểu VM, Linux, container và network.

## Mục tiêu

Một cluster nhỏ.

Concept:

```text
Proxmox
   │
   ├── k8s-node-01
   ├── k8s-node-02
   └── optional node later
           │
           ▼
       Kubernetes
```

Với homelab nhỏ, ưu tiên distribution nhẹ trước; không cần mô phỏng enterprise cluster lớn ngay.

## Học theo thứ tự

```text
Pod
 ↓
Deployment
 ↓
Service
 ↓
Ingress
 ↓
ConfigMap / Secret
 ↓
PersistentVolume
 ↓
Namespace
```

Sau đó mới:

```text
Helm
GitOps
operators
autoscaling
policy
```

### Không làm sớm

- service mesh;
- multi-cluster;
- complex operator stacks;
- HA giả trên 2 physical nodes;
- dozens of namespaces.

---

# 15. Phase 11 — Platform networking

Target flow:

```text
Internet
   │
   ▼
DNS
   │
   ▼
router / firewall
   │
   ▼
reverse proxy / ingress
   │
   ▼
Kubernetes Service
   │
   ▼
application
```

Internal traffic:

```text
App
 │
 ├── Database
 ├── NAS
 ├── WisdomTree services
 └── monitoring
```

Khi tới đây mới thiết kế kỹ VLAN / DMZ / IoT segmentation nếu cần.

---

# 16. Phase 12 — Observability

Không bắt đầu bằng Grafana dashboard.

Bắt đầu từ câu hỏi:

> Nếu application chết, mình biết bằng cách nào?

Stack mục tiêu:

```text
              applications
                   │
        ┌──────────┼──────────┐
        │          │          │
     metrics      logs      health
        │          │          │
        ▼          ▼          ▼
   Prometheus   logging     probes
        │          │
        └────┬─────┘
             ▼
           Grafana
```

## Thứ tự

1. node metrics;
2. application health;
3. Prometheus;
4. Grafana;
5. centralized logs;
6. alerting;
7. Elasticsearch/OpenSearch chỉ khi thật sự cần.

Không triển khai Elastic chỉ vì nó phổ biến.

Nó có chi phí RAM/CPU/storage đáng kể.

---

# 17. Phase 13 — Storage platform

Storage cần được coi là một project riêng.

```text
TrueNAS / NAS
│
├── engineering
│   ├── CFD
│   ├── CAD
│   ├── PCB
│   └── experiments
│
├── knowledge
│   ├── documents
│   └── source material
│
├── media
│   ├── music
│   └── video
│
└── backups
```

## Yêu cầu

- dataset separation;
- permissions;
- snapshots;
- capacity monitoring;
- backup policy;
- network shares;
- Kubernetes persistent storage integration later.

### Quy tắc

```text
NAS ≠ backup
```

Snapshot trên cùng NAS cũng không phải backup hoàn chỉnh.

---

# 18. Phase 14 — Media services

Sau khi NAS ổn định:

```text
NAS/music
    │
    ▼
music server
    │
    ▼
HTTPS GUI
    │
    ▼
friends
```

Video:

```text
NAS/video
   │
   ▼
video media server
   │
   ▼
HTTPS GUI
```

Application quản lý user/session.

Không đưa SMB/NFS trực tiếp ra Internet.

---

# 19. Phase 15 — WisdomTree production platform

WisdomTree thuộc application + knowledge plane.

```text
WisdomTree
│
├── Next.js application
├── PostgreSQL
├── object/file storage integration
└── later pgvector / RAG
```

Deployment:

```text
Git
 ↓
CI
 ↓
container image
 ↓
Kubernetes
 ↓
WisdomTree
 ↓
PostgreSQL + NAS/object storage
```

Platform phải đảm bảo:

- backup database;
- backup source materials;
- persistent storage;
- monitoring;
- logs;
- secrets;
- domain/TLS.

---

# 20. Phase 16 — Knowledge / RAG compute

RAG không phải phase đầu.

Sau khi WisdomTree chạy ổn định:

```text
Source
  │
  ▼
Extraction
  │
  ▼
Chunking
  │
  ▼
Embedding
  │
  ▼
Vector store
  │
  ▼
Retrieval
  │
  ▼
Reranking
  │
  ▼
LLM
  │
  ▼
Synthesis
```

Heavy AI workload có thể chạy trên compute node.

WisdomTree vẫn là control plane của knowledge/provenance.

---

# 21. Phase 17 — Engineering compute

Tạo machine class riêng:

```text
engineering-01
│
├── Ubuntu Server
├── Python
├── NumPy / SciPy
├── SU2
├── OpenFOAM
├── Gmsh
├── MPI later
└── GPU tooling later
```

Engineering compute không nên phụ thuộc Kubernetes ngay từ đầu.

Ban đầu:

```text
SSH
 ↓
run job
 ↓
write result
 ↓
NAS
```

Sau đó mới automation:

```text
job definition
 ↓
compute
 ↓
results
 ↓
WisdomTree
```

---

# 22. Phase 18 — CI/CD platform

Application repo:

```text
WisdomTree repo
Gleworks repo
future app repo
```

Platform repo:

```text
plank
```

Boundary:

```text
APP REPO
"What should this application build?"

PLANK
"Where and how should applications run?"
```

Mature pipeline:

```text
developer
   │
   ▼
git push
   │
   ▼
CI
 ├── lint
 ├── test
 ├── build
 └── container image
       │
       ▼
registry
       │
       ▼
deployment config
       │
       ▼
Kubernetes
```

Later có thể chuyển sang GitOps.

Không cần GitOps ở phase đầu.

---

# 23. Phase 19 — Secrets and identity

Khi platform bắt đầu chứa production workload:

Không để secret trong Git.

Các loại secret:

```text
Proxmox token
SSH key
database password
API key
OIDC secret
TLS material
backup credentials
```

Bắt đầu đơn giản:

- `.gitignore`;
- environment injection;
- Ansible Vault nếu phù hợp.

Sau này mới đánh giá secret manager chuyên dụng.

---

# 24. Phase 20 — Backup and disaster recovery

Backup phải được thiết kế theo **restore**, không phải theo "copy file".

Cần backup:

```text
Terraform configuration
Ansible configuration
Kubernetes manifests
application databases
WisdomTree materials
Git repositories
NAS critical datasets
platform secrets
```

Nhưng Git-tracked IaC đã có một lợi thế:

```text
hardware lost
    │
    ▼
install Proxmox
    │
    ▼
clone plank
    │
    ▼
Terraform
    │
    ▼
Ansible
    │
    ▼
restore data
    │
    ▼
platform rebuilt
```

Đây là một trong những mục tiêu dài hạn quan trọng nhất của `plank`.

---

# 25. Phase 21 — Security hardening

Sau khi platform hoạt động:

- SSH key only;
- least privilege;
- dedicated service accounts;
- firewall policy;
- network segmentation;
- secrets management;
- patch strategy;
- dependency updates;
- audit logs;
- external exposure review;
- IoT isolation.

Security không phải một sản phẩm cài thêm cuối cùng.

Nó là cross-cutting concern.

---

# 26. Phase 22 — Platform maturity

Khi mọi lớp cơ bản đã ổn:

```text
Terraform
    │
    ▼
Infrastructure

Ansible
    │
    ▼
Machine configuration

Kubernetes
    │
    ▼
Workload orchestration

GitOps
    │
    ▼
Desired application state

Prometheus / Grafana / Logs
    │
    ▼
Observability

NAS / Backup
    │
    ▼
Persistent data

WisdomTree / RAG
    │
    ▼
Research knowledge

Engineering Compute
    │
    ▼
Simulation / AI
```

Lúc đó `plank` thực sự trở thành control repo cho platform.

---

# 27. Roadmap theo milestone thực tế

## Milestone A — IaC beginner

```text
[ ] Terraform local exercise
[ ] Understand state
[ ] Ansible localhost/VM exercise
[ ] Understand inventory/playbook/role
[ ] Understand idempotency
```

**Không có production infrastructure.**

---

## Milestone B — Reproducible VM

```text
[ ] Proxmox template
[ ] Terraform creates VM
[ ] Terraform destroys VM
[ ] cloud-init works
[ ] SSH works
```

Kết quả:

> VM không còn là thứ tạo bằng click.

---

## Milestone C — Reproducible server

```text
[ ] Terraform creates VM
[ ] Ansible configures VM
[ ] common role
[ ] Docker role
[ ] second run is idempotent
```

Kết quả:

> Server không còn là thứ cấu hình bằng tay.

---

## Milestone D — First application platform

```text
[ ] Docker runtime
[ ] reverse proxy
[ ] test webapp
[ ] database
[ ] domain/TLS
[ ] basic monitoring
```

Kết quả:

> Application có một nơi chạy reproducible.

---

## Milestone E — Kubernetes

```text
[ ] cluster provisioned as VMs
[ ] cluster configured through Ansible
[ ] ingress
[ ] storage
[ ] app deployment
```

Kết quả:

> Runtime bắt đầu trở thành orchestration platform.

---

## Milestone F — Observability

```text
[ ] host metrics
[ ] Kubernetes metrics
[ ] app metrics
[ ] Grafana
[ ] centralized logs
[ ] alerts
```

Kết quả:

> Không cần SSH vào từng server để đoán lỗi.

---

## Milestone G — Storage

```text
[ ] NAS deployed
[ ] datasets defined
[ ] snapshots
[ ] permissions
[ ] backup target
[ ] Kubernetes storage integration
```

Kết quả:

> Compute và storage bắt đầu tách biệt.

---

## Milestone H — Real workloads

```text
[ ] Gleworks
[ ] portfolio
[ ] WisdomTree
[ ] databases
[ ] media
```

Kết quả:

> Platform bắt đầu phục vụ workload thật.

---

## Milestone I — Engineering & RAG

```text
[ ] engineering compute VM
[ ] scientific toolchain
[ ] NAS engineering datasets
[ ] WisdomTree source integration
[ ] embedding service
[ ] retrieval
[ ] local LLM
```

Kết quả:

> Platform phục vụ cả software lẫn engineering research.

---

# 28. Dependency graph

Không học theo danh sách tool.

Học theo dependency.

```text
Linux / Networking
        │
        ▼
      Proxmox
        │
        ▼
     Templates
        │
        ▼
    Terraform
        │
        ▼
      VM / CT
        │
        ▼
     Ansible
        │
        ▼
   configured OS
        │
        ▼
     Container
        │
        ▼
    Kubernetes
        │
        ▼
 Applications
        │
        ├─────────► Observability
        │
        ├─────────► Storage
        │
        └─────────► CI/CD
```

Nếu lớp trước chưa hiểu, đừng vội nhảy tới lớp sau.

---

# 29. Quy tắc của repo `plank`

## Rule 1 — Infrastructure as Code

Thay đổi infrastructure quan trọng phải có representation trong Git.

---

## Rule 2 — Manual first once, automate second

Một việc mới có thể làm thủ công một lần để hiểu.

Nếu phải làm lần thứ hai hoặc thứ ba:

> bắt đầu xem nó có nên được automation hay không.

---

## Rule 3 — Simple before scalable

```text
1 VM
before
10 VM

Docker Compose
before
Kubernetes

one node monitoring
before
full observability stack

local Terraform state
before
remote state infrastructure
```

---

## Rule 4 — One owner per responsibility

```text
Terraform → resource lifecycle
Ansible   → OS configuration
K8s       → workload lifecycle
NAS       → persistent bulk storage
Git       → desired configuration history
```

Không để nhiều tool cùng tranh quyền quản lý một resource.

---

## Rule 5 — Production services and compute experiments are separate

```text
Portfolio / WisdomTree / Git
             │
         CORE services

CFD / LLM / GPU jobs
             │
       COMPUTE services
```

Một simulation không nên làm portfolio hoặc database chết.

---

## Rule 6 — Data must survive compute

VM có thể bị destroy.

Container có thể bị recreate.

Node có thể được reinstall.

Critical data phải vẫn tồn tại.

---

## Rule 7 — Rebuild is the final test

Đích đến không phải:

> "server này chạy được 500 ngày."

Mà là:

> "nếu server mất, mình có thể dựng lại bằng repo + backup."

---

# 30. Những thứ CHƯA cần làm

Ở giai đoạn local IaC hiện tại, không cần:

```text
Kubernetes
Prometheus
Grafana
Elasticsearch
TrueNAS automation
GitOps
Vault
service mesh
distributed storage
HA databases
multi-cluster
complex VLAN design
```

Hiện tại chỉ cần tập trung:

```text
Terraform fundamentals
        +
Ansible fundamentals
        +
Proxmox template concept
        +
Terraform → VM
        +
Ansible → configured VM
```

Đó là foundation của toàn bộ phần còn lại.

---

# 31. Bước thực hành đầu tiên cho repo hiện tại

Repo blank nên bắt đầu:

```text
plank/
├── README.md
├── roadmap.md
│
├── terraform/
│   └── local/
│
└── ansible/
    ├── inventory.ini
    └── playbook.yml
```

Không thêm gì khác.

## Terraform

Mục tiêu:

```text
init → plan → apply → state → destroy
```

## Ansible

Mục tiêu:

```text
inventory → ping → playbook → second run idempotent
```

Khi hai phần này hiểu rõ mới tạo:

```text
terraform/proxmox/
```

và bắt đầu làm việc với VM thật.

---

# 32. Mental model cuối cùng

Hãy hình dung toàn bộ platform như xây một tòa nhà.

```text
Physical metal
      │
      ▼
Proxmox
      │
      ▼
Terraform
      │
      ▼
VM / CT
      │
      ▼
Ansible
      │
      ▼
Configured Linux
      │
      ▼
Containers
      │
      ▼
Kubernetes
      │
      ▼
Platform services
      │
      ├── networking
      ├── monitoring
      ├── logging
      ├── storage
      └── databases
             │
             ▼
         Applications
             │
        ┌────┼─────┐
        │    │     │
   WisdomTree Gleworks Media
        │
        ▼
 Engineering / RAG / Research
```

`plank` là bản thiết kế và bộ công cụ giúp tái tạo toàn bộ tòa nhà đó.

---

# 33. Trạng thái hiện tại

```text
Current
   │
   ▼
Blank repository
   │
   ▼
Learn Terraform + Ansible locally
   │
   ▼
Provision first disposable Proxmox VM
```

Đó là nơi roadmap này bắt đầu.

Không cần giải quyết Kubernetes, NAS, RAG hay observability ngay lúc này.

Chúng đã có vị trí trong blueprint; ta sẽ tiến tới từng lớp khi dependency bên dưới đã đủ vững.
