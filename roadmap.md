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

Không bắt đầu bằng Grafana dashboard rực rỡ.

Bắt đầu từ câu hỏi:

> Nếu application hoặc ổ đĩa chết, mình biết bằng cách nào và trong bao lâu?

### Triết lý lựa chọn công nghệ: Tự chủ (Self-Hosted) vs SaaS (Datadog)

* **Quyết định về Datadog:** **Không sử dụng làm stack chính**.
  * *Lý do:* Free tier chỉ lưu trữ metrics 1 ngày (1-day retention), thiếu alerting nâng cao, chi phí bản quyền đắt đỏ, và gửi dữ liệu tài liệu nội bộ lên cloud (vi phạm tính tự chủ dữ liệu).
* **Quyết định về LGTM Stack (Grafana Labs):** Sử dụng chuẩn mở CNCF theo lộ trình tinh gọn (*Lean Observability*), lưu trữ trên Tier 2 (`mini-sata` SSD):
  * **Pha 1 (Cốt lõi - dưới 800MB RAM):** `Prometheus` (Metrics) + `Grafana` (Dashboard) + `Alertmanager` (Cảnh báo qua Telegram/Discord bot).
  * **Pha 2 (Logs):** `Loki` (Gom log từ Caddy và Docker container, retention 7–14 ngày).
  * **Pha 3 (Tracing - Tạm hoãn):** `Tempo` hoãn lại cho tới khi có Kubernetes và nhiều microservices; không triển khai cho kiến trúc monolith/modular hiện tại để tránh lãng phí RAM/CPU.

### Kiến trúc phân tầng quan trắc hiện tại

```text
               applications & host
                        │
         ┌──────────────┼──────────────┐
         │              │              │
      metrics          logs          health
   (9100 / 9633)        │              │
         │              │              ▼
         ▼              ▼            probes
    Prometheus        Loki        (Caddy/HTTP)
         │              │
         ├──────────────┴──────┬───────────────┐
         ▼                     ▼               ▼
      Grafana            Alertmanager     (Tempo - pha sau)
   (Trực quan)        (Telegram/Discord)    (Microservices)
```

### Hiện trạng triển khai

1. **Host Exporters (Đã chạy 24/7 trên `pve-mini`):**
   * `prometheus-node-exporter` (Port `9100`): CPU, RAM, Disk I/O, Network.
   * `prometheus-smartctl-exporter` (Port `9633`): Sức khỏe SMART, nhiệt độ, lỗi bad sector của cả 5 ổ đĩa.
2. **TSDB & Dashboards (Sắp tới):**
   * Đặt Prometheus TSDB & Loki chunks trên **Tier 2 (`mini-sata` SATA SSD 219GB)** để chịu tải ghi liên tục mà không hao mòn NVMe Tier 1.


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

# 19. Phase 15 — WisdomTree production platform & Document Lab

WisdomTree thuộc application + knowledge plane.

```text
WisdomTree & Document Platform
│
├── Next.js application (Web UI / Note & Synthesis)
├── PostgreSQL 16 (Foundation metadata & relational store)
├── Document Processing & Ingestion Worker
│
└── Document Toolchain & Publishing Lab (Companion Services)
    ├── LaTeX Compiler (Tectonic / TeXLive CLI)
    ├── Document Converter (Pandoc, Stirling-PDF)
    └── EPUB & Ebook Server (Calibre-Web / OPDS sync to e-readers)
```

### Mối quan hệ giữa Document Lab và WisdomTree:

1. **Document Ingestion Pipeline:**
   - Các file sách EPUB, bài báo khoa học PDF, tài liệu thô được tiếp nhận và xử lý qua Pandoc/Stirling-PDF.
   - Đầu ra được chuẩn hóa (Markdown/Text) và đẩy thẳng vào kho lưu trữ tài liệu gốc `/data/originals` (trên Tier 3: `cold-archive` MergerFS 1.1TB).
   - Worker của WisdomTree lập chỉ mục, băm nhỏ (chunking) và bảo toàn tính nguồn gốc (provenance).

2. **Publishing & Scientific Writing:**
   - Biên dịch báo cáo nghiên cứu, tài liệu kỹ thuật chất lượng cao bằng LaTeX.
   - Quản lý và đọc sách học tập/nghiên cứu tập trung qua Calibre-Web (hỗ trợ đọc trên trình duyệt hoặc đồng bộ qua Wi-Fi tới máy đọc sách Kindle/Kobo).

3. **Kiến trúc Giao diện & Trải nghiệm (Decoupled Hub & Spoke vs Custom Monolith):**
   - **Quyết định thiết kế:** Không tự code một ứng dụng nguyên khối (Monolith) ôm đồm toàn bộ việc biên dịch LaTeX hay chỉnh sửa PDF (tránh bẫy phát minh lại bánh xe).
   - **Mô hình Portal / Launcher:** Tận dụng UI hoàn thiện của các công cụ mã nguồn mở chuyên biệt (Calibre-Web, Stirling-PDF), kết nối thông qua một **Minimal Portal / Dashboard**:
     - *Phương án A:* Tích hợp menu launcher "Lab Tools" ngay trên Sidebar của WisdomTree (mở tab hoặc iframe chuyển hướng nhanh).
     - *Phương án B:* Dựng một trang launcher tối giản (ví dụ: `tools.gleworks.io.vn`) hiển thị các card dịch vụ.
   - **Bảo toàn ranh giới WisdomTree:** Giữ codebase của WisdomTree thuần khiết, tập trung 100% vào việc tổng hợp tri thức, quản lý provenance và Live SLM RAG.

Deployment:

```text
Git
 ↓
CI
 ↓
container image
 ↓
Node B / Proxmox
 ↓
WisdomTree + Document Services
 ↓
PostgreSQL (Tier 1: NVMe) + Library Storage (Tier 3: MergerFS)
```

Platform phải đảm bảo:

- backup database;
- backup source materials & library;
- persistent storage (MergerFS / NVMe);
- monitoring;
- logs;
- secrets;
- domain/TLS.

---

# 20. Phase 16 — Knowledge / Live Internal RAG (SLM-First)

RAG không phải phase đầu, nhưng khi triển khai, **ưu tiên chiến lược SLM-First (Small Language Models)** thay vì phụ thuộc vào mô hình khổng lồ.

```text
Source (/data/originals trên Tier 3: MergerFS)
  │
  ▼
Extraction (Worker / Pandoc / Stirling-PDF)
  │
  ▼
Chunking (Lưu số trang, vị trí, metadata)
  │
  ▼
Embedding (bge-m3 / nomic-embed-text)
  │
  ▼
Vector Store (PostgreSQL 16 + pgvector trên Tier 1: NVMe local-lvm)
  │
  ▼
Semantic Retrieval (Top 3-5 chunks liên quan nhất)
  │
  ▼
Live SLM Inference (Qwen2.5-1.5B/3B, Llama-3.2-3B qua Ollama trên Node B CPU)
  │
  ▼
Synthesis & Provenance Citation (Trả lời tức thì, dẫn nguồn [1], [2] chính xác)
```

### Chiến lược RAG Phân tầng (Two-Tier Inference):

1. **Tầng 1: Live Interactive SLM (Always-on 24/7 trên Node B):**
   - **Mô hình:** SLM lượng tử hóa `Q4_K_M` (Qwen2.5-1.5B/3B, Llama-3.2-3B, Phi-3.5-mini).
   - **Hạ tầng:** Chạy trực tiếp trên **CPU i5-6500T** (qua Ollama/llama.cpp trong LXC 101), tiêu tốn chỉ **1.5GB – 2.5GB RAM**.
   - **Ưu điểm:** Zero-GPU, phản hồi sub-second (< 1s), online 24/7 để tra cứu nhanh khi đọc sách hoặc ghi chép.
   - **Vector Store:** Tích hợp trực tiếp **`pgvector`** vào PostgreSQL có sẵn của WisdomTree, lưu trên NVMe siêu tốc.

2. **Tầng 2: Deep Synthesis & Multi-Doc Analysis (Burst Compute trên Node A):**
   - Khi cần tổng hợp phân tích sâu hàng chục bài báo khoa học, hoặc sinh code simulation phức tạp:
   - Offload request sang **Node A (RTX 2060 6GB CUDA)** chạy các model lớn hơn (7B–8B, DeepSeek-R1-Distill).
   - WisdomTree vẫn luôn là **control plane duy nhất** quản lý provenance và knowledge graph.

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
[x] Terraform local exercise (Node B pve-mini)
[x] Understand state (recon qua data sources & state inspection)
[ ] Ansible localhost/VM exercise
[ ] Understand inventory/playbook/role
[ ] Understand idempotency
```

**Không có production infrastructure.**

---

## Milestone B — Reproducible Infrastructure

```text
[x] Terraform creates LXC container (app-gateway-01 [100])
[x] Storage tiering integrated (mini-sata SSD, local-lvm NVMe, cold-archive)
[x] Initialization & SSH keys work
[x] SSH ProxyJump via pve-mini works transparently
[ ] Proxmox VM template
[ ] Terraform creates VM
[ ] Terraform destroys VM
[ ] cloud-init works
```

Kết quả:

> Hạ tầng container & VM không còn là thứ tạo bằng click thủ công.

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
[x] Ingress & reverse proxy (Caddy trong LXC 100)
[x] Zero-trust ingress (Cloudflare Tunnel pve-mini-gateway)
[x] Domain & SSL live (gleworks.io.vn, keebs.gleworks.io.vn, wt.gleworks.io.vn)
[x] Docker runtime (WisdomTree runtime trong LXC 101)
[x] Database (PostgreSQL 16 trên Tier 1 NVMe local-lvm)
[ ] basic monitoring
```

Kết quả:

> Application có một nơi chạy reproducible và an toàn từ internet.

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
[x] host metrics exporters active on pve-mini (node-exporter:9100, smartctl-exporter:9633)
[ ] Lean Observability Core: Prometheus TSDB trên Tier 2 mini-sata SSD (< 800MB RAM)
[ ] Dashboards: Grafana (Linux host, LVM-thin storage, Docker, SMART metrics)
[ ] Alerting: Alertmanager với Telegram/Discord bot cảnh báo (Disk > 90%, OOM, Host down)
[ ] Centralized logs: Grafana Loki (tập trung log Caddy access & Docker containers)
[ ] Distributed Tracing: Tempo (hoãn lại đến giai đoạn Kubernetes / Microservices)
```

Kết quả:

> Toàn bộ chỉ số phần cứng, sức khỏe 5 ổ đĩa, và lỗi container được cảnh báo tự động về điện thoại mà không cần SSH đoán lỗi.

---

## Milestone G — Storage

```text
[x] Datastores defined & classified into 5 tiers
[ ] NAS deployed
[ ] datasets defined
[ ] snapshots
[ ] permissions
[ ] backup target (VZDump retention on backup-hdd)
[ ] Kubernetes storage integration
```

Kết quả:

> Compute và storage bắt đầu tách biệt.

---

## Milestone H — Real workloads

```text
[x] Gleworks / keebs (Vite static live on homelab)
[x] Frontend CI quality gates (.github/ci.yml)
[ ] Staging environment (*.staging.gleworks.io.vn)
[x] WisdomTree (Next.js 16 + Postgres 16 trên NVMe + Worker live trên https://wt.gleworks.io.vn)
[ ] Document Lab & Publishing (LaTeX/Tectonic, Pandoc, Stirling-PDF)
[ ] EPUB & Ebook Library (Calibre-Web với OPDS sync sang Kindle/Kobo)
[x] databases (Postgres 16 + pgvector trên Tier 1 NVMe)
[ ] media
```

Kết quả:

> Platform bắt đầu phục vụ workload thật: webapps, ghi chú tri thức, xuất bản và thư viện sách cá nhân.

---

## Milestone I — Engineering & Live RAG (SLM-First)

```text
[ ] pgvector extension tích hợp trong PostgreSQL 16 (Tier 1: NVMe)
[ ] Embedding engine (bge-m3 / nomic-embed qua Ollama/FastEmbed)
[ ] Live SLM inference engine 24/7 (Ollama với Qwen2.5-3B / Llama-3.2 trên Node B CPU)
[ ] Document pipeline integration: Chuyển đổi EPUB/PDF tự động nạp vào WisdomTree (/data/originals)
[ ] WisdomTree source integration & citation provenance (trích dẫn [1], [2] từ chunk gốc)
[ ] Two-tier offload: Điều hướng tác vụ tổng hợp nặng/deep reasoning sang Node A (RTX 2060 GPU)
[ ] engineering compute VM/container (Node A - Ryzen 5600X + RTX 2060)
[ ] scientific toolchain (Python, C++, CUDA)
[ ] NAS engineering datasets (cold-archive MergerFS)
```

Kết quả:

> Platform phục vụ cả software lẫn live research intelligence với khả năng tra cứu tri thức tức thì 24/7.

---

## Milestone J — Earth Observation, SDR & Computational Engineering

```text
[ ] RTL-SDR / Radio telemetry ingestion (Proxmox USB Passthrough)
[ ] Weather satellite reception (NOAA-15/18/19, Meteor-M2 137MHz)
[ ] ADS-B & Radar tracking pipeline (1090MHz)
[ ] Southern Vietnam / Mekong Delta climate & flood simulation dataset (NetCDF, GIS, PostGIS)
[ ] Environmental ML predictive modeling
[ ] Robotics telemetry, sensors & IoT MQTT broker
[ ] Computational Aerodynamics / CFD solvers (OpenFOAM / SU2) on Node A
```

Kết quả:

> Homelab trở thành trạm quan sát trái đất, vô tuyến và phòng thí nghiệm cơ khí/khí động học thực nghiệm.

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
Current State:
   │
   ▼
[x] Node B (pve-mini — 24GB RAM, i5-6500T) Bootstrap & Provisioning Completed:
   ├── Terraform IaC: Cấp phát thành công toàn bộ 6 LXC Containers (Chỉ tốn ~2.3GB / 24GB RAM):
   │   ├── LXC 100 (app-gateway-01 — 192.168.1.63): Caddy + Cloudflare Tunnel (Live 24/7 không mở port)
   │   ├── LXC 101 (research-hub-01 — 192.168.1.252): WisdomTree + SLM RAG + Document Lab
   │   ├── LXC 102 (ci-runner-01 — 192.168.1.50): GitHub Actions Self-Hosted Runner
   │   ├── LXC 103 (monitoring-01 — 192.168.1.20): Lean Observability (Prometheus TSDB + Grafana + Alertmanager)
   │   ├── LXC 104 (media-music-01 — 192.168.1.13): Navidrome Lossless Music Server
   │   └── LXC 105 (home-automation-01 — 192.168.1.49): Home Assistant & Smarthome Hub
   ├── Configuration as Code: Ansible tự động cài đặt Docker 29.9.0 & Baseline OS trên toàn bộ các App Node
   ├── Storage Tiering: Định danh & phân tầng 5 ổ đĩa vật lý (NVMe, SSD, MergerFS 1.1TB, HDD backup)
   ├── Active Monitoring Exporters: node-exporter (9100) & smartctl-exporter (9633) chạy ngầm 24/7
   ├── Tên miền & SSL Live: gleworks.io.vn, keebs.gleworks.io.vn, wt.gleworks.io.vn
   ├── Workloads Production Live:
   │   ├── gleworks-keebs (Vite static live tại https://keebs.gleworks.io.vn)
   │   └── WisdomTree Knowledge Hub (Next.js 16 SSR + Postgres 16 trên NVMe + originals trên MergerFS 1.1TB live tại https://wt.gleworks.io.vn)
   └── DevOps Quality Gates: GitHub Actions CI (.github/ci.yml) tự động test/build
   │
   ▼
Mục tiêu tức thì kế tiếp (Immediate Next Steps):
   ├── 1. Khai báo Terraform & Dựng LXC 103 (monitoring-01): Prometheus TSDB + Grafana + Alertmanager trên Tier 2 SSD
   ├── 2. Triển khai Navidrome trên LXC 104 kết nối kho nhạc lossless MergerFS 1.1TB
   ├── 3. Khởi chạy Calibre-Web & Stirling-PDF trên LXC 101 kết nối kho sách MergerFS
   ├── 4. Cấu hình GitHub Actions Runner trên LXC 102 (tự động hóa CD)
   ├── 5. Cấu hình Home Assistant trên LXC 105 (Zigbee / MQTT)
   └── 6. Kích hoạt Node A (Ryzen 5600X + RTX 2060): Chuẩn bị cho CFD (OpenFOAM), SDR & ML simulation
```

Hệ thống đã hoàn tất tầng ảo hóa hạ tầng (IaC) và chính thức bước vào giai đoạn **triển khai workload ứng dụng & hệ thống quan trắc (Observability)**.
