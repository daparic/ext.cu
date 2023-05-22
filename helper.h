#include <cuda_runtime.h>

void do_transpose(dim3 gDim, dim3 bDim, float *Md, float *Bd, uint WIDTH);
