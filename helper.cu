#include <cuda_runtime.h>

static __global__ void transpose(float *in, float *out, uint width) {
    uint tx = blockIdx.x * blockDim.x + threadIdx.x;
    uint ty = blockIdx.y * blockDim.y + threadIdx.y;
    out[tx * width + ty] = in[ty * width + tx];
}

void do_transpose(dim3 gDim, dim3 bDim, float *Md, float *Bd, uint WIDTH) {
    transpose<<<gDim, bDim>>>(Md, Bd, WIDTH);
}
