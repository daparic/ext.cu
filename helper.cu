#include <cuda_runtime.h>
#include <stdio.h>

static __global__ void transpose(float *in, float *out, uint width) {
    uint tx = blockIdx.x * blockDim.x + threadIdx.x;
    uint ty = blockIdx.y * blockDim.y + threadIdx.y;
    out[tx * width + ty] = in[ty * width + tx];
}

cudaError_t do_transpose(dim3 gDim, dim3 bDim, float *Md, float *Bd, uint WIDTH) {
    transpose<<<gDim, bDim>>>(Md, Bd, WIDTH);
    
    /* 1. Launch check */
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        return err;   // ✅ DO NOT continue
    }

    /* 2. Execution check */
    err = cudaDeviceSynchronize();
    if (err != cudaSuccess) {
        printf("Kernel execution failed: %s\n", cudaGetErrorString(err));
        return err;
    }

    return cudaSuccess;
}
