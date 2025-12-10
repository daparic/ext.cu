
TARGET_ARCH=$(shell uname -m)
all: app

helper.o: helper.cu Makefile
	/usr/local/cuda/bin/nvcc \
    -m64 \
    -gencode arch=compute_$(SM),code=sm_$(SM) \
    -o helper.o -c helper.cu

app: app.cpp helper.h helper.o Makefile
	g++ -o app app.cpp helper.o  \
    -I/usr/local/cuda/targets/$(TARGET_ARCH)-linux/include \
    -L/usr/local/cuda/targets/$(TARGET_ARCH)-linux/lib/ \
    -lcudart 

clean:
	@rm -f *.o app

.PHONY: clean
