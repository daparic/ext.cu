#include <cuda_runtime.h>

cudaError_t do_transpose(dim3 gDim, dim3 bDim, float *Md, float *Bd, uint WIDTH);
