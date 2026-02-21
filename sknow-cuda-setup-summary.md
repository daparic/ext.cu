# CUDA Setup Summary — Ubuntu 24.04.4 (GTX 1050 Ti)

System came with pre-installed NVIDIA drivers (`nvidia-smi` available, driver `535.x`, CUDA-compatible up to 12.2).

---

## Issue 1: Wrong Ubuntu version in CUDA repo

**Symptom:**
```
E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.
```

**Cause:**
Used the CUDA 12.2 download page targeting Ubuntu 22.04 (`ubuntu2204`) while running Ubuntu 24.04.4.

**Steps that caused it (`steps.md`):**
```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda
```

**Recovery:**
```bash
sudo dpkg -r cuda-keyring
sudo rm -f /etc/apt/sources.list.d/cuda*.list
sudo apt-get update
```

---

## Issue 2: `nvidia-kernel-common` conflict when installing `cuda`

**Symptom:**
```
nvidia-kernel-common : Conflicts: nvidia-kernel-common
nvidia-kernel-common-535 : Conflicts: nvidia-kernel-common
```

**Cause:**
The `cuda` meta-package bundles NVIDIA drivers. Since the system already had drivers installed (`nvidia-kernel-common-535`), they conflicted.

**Recovery:**
Install only the toolkit (no drivers) using `cuda-toolkit` instead of `cuda`. See Issue 3 for the final correct approach.

---

## Issue 3: CUDA toolkit 13.1 installed from NVIDIA repo instead of matching Ubuntu's driver

**Symptom:**
```
nvcc: NVIDIA (R) Cuda compiler driver
Cuda compilation tools, release 13.1, V13.1.115
```
Mismatched with the driver's supported CUDA 12.2.

**Cause:**
After adding NVIDIA's `ubuntu2404` repo, `cuda-toolkit` resolved to the latest version (13.1) from NVIDIA's repo rather than the version matching the pre-installed Ubuntu driver (12.2).

**Recovery — undo NVIDIA repo installation:**
```bash
sudo apt-get remove --purge cuda-toolkit
sudo apt-get autoremove --purge
sudo dpkg -r cuda-keyring
sudo rm -f /etc/apt/sources.list.d/cuda*.list
sudo apt-get update
```

**Correct install — use Ubuntu's native package:**
```bash
sudo apt-get install nvidia-cuda-toolkit
```

This installs the CUDA toolkit from Ubuntu's own archive, guaranteed compatible with Ubuntu's packaged NVIDIA drivers. Result: `nvcc` 12.2, matching the driver.

> **Note:** Never mix NVIDIA's repo packages with Ubuntu's driver packages. Either let NVIDIA's repo manage everything (install `cuda`, not just `cuda-toolkit`) or use Ubuntu's packages exclusively (`nvidia-cuda-toolkit`).

---

## Issue 4: Makefile using wrong include/lib paths

**Symptom:**
`g++` could not find CUDA headers or `libcudart` when building the project.

**Cause:**
The Makefile was written for NVIDIA's own repo layout (`/usr/local/cuda/...`), which does not exist when using Ubuntu's `nvidia-cuda-toolkit` package.

**Original (broken) paths:**
```makefile
-I/usr/local/cuda/targets/$(TARGET_ARCH)-linux/include
-L/usr/local/cuda/targets/$(TARGET_ARCH)-linux/lib/
```

**Ubuntu package layout (correct):**
| What          | Path                          |
|---------------|-------------------------------|
| Include       | `/usr/lib/cuda/include`       |
| Library       | `/usr/lib/x86_64-linux-gnu`   |
| `libcudart.so`| `/usr/lib/x86_64-linux-gnu/libcudart.so` |

**Fix in Makefile:**
```makefile
-I/usr/lib/cuda/include
-L/usr/lib/x86_64-linux-gnu
-lcudart
```

---

## Issue 5: Unknown compute capability (`SM` value) for `nvcc`

**Symptom:**
`nvcc` requires `-gencode arch=compute_$(SM),code=sm_$(SM)` but the correct `SM` value was unknown.

**How to find it:**
```bash
nvidia-smi --query-gpu=name,compute_cap --format=csv,noheader
# Output: NVIDIA GeForce GTX 1050 Ti, 6.1
```

Strip the dot → `SM=61`.

**Build command:**
```bash
make SM=61
```

---

## Final Working Setup

| Component        | Value                                      |
|------------------|--------------------------------------------|
| OS               | Ubuntu 24.04.4                             |
| GPU              | NVIDIA GeForce GTX 1050 Ti                 |
| Driver           | 535.x (Ubuntu package)                     |
| CUDA Toolkit     | 12.2 (`nvidia-cuda-toolkit`, Ubuntu package) |
| `nvcc` path      | `/usr/bin/nvcc`                            |
| Include path     | `/usr/lib/cuda/include`                    |
| Lib path         | `/usr/lib/x86_64-linux-gnu`                |
| Compute cap (SM) | 6.1 → `SM=61`                              |
