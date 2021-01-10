#include <iostream>
#include <cuda.h>

#ifdef WITHCUFILES
#include "gpu.hpp"
#endif

int main()
{
    std::cout << "Hello, CUDA v" << CUDA_VERSION/1000 << "." << CUDA_VERSION/10%100 << std::endl;
    #ifdef WITHCUFILES
    printCudaVersion();
    #else
    std::cout << "Support for driver and runtime versions not available in this test." << std::endl;
    #endif

    return 0;
}
