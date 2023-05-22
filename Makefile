
all: app

helper.o: helper.cu Makefile
	/usr/local/cuda-10.2/bin/nvcc \
    -m64 \
    -gencode arch=compute_53,code=sm_53 \
    -o helper.o -c helper.cu

app: app.cpp helper.h helper.o Makefile
	g++ -o app app.cpp helper.o  \
    -I/usr/local/cuda/targets/aarch64-linux/include \
    -L/usr/local/cuda/targets/aarch64-linux/lib/ \
    -lcudart 

clean:
	@rm -f *.o app

.PHONY: clean
