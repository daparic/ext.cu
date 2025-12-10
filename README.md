### NVIDIA CUDA C/C++ Code Organization

[Proper CUDA code organization](https://youtu.be/eMZtFKl6wBg) makes the source code more portable and flexible
by clearly separating the extended C/C++ syntax into a separate compilation
unit. This leaves your application as a pure standard C/C++ project. 

### How to build for RTX 4070, Compute Capability 8.9
```
make SM=89
```

### How to build for Maxwell, Compute Capability 5.3 (ie, Jetson Nano)
```
make SM=53
```
