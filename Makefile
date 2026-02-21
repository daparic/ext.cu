
TARGET_ARCH=$(shell uname -m)
all: app

helper.o: helper.cu Makefile
	/usr/bin/nvcc \
    -m64 \
    -gencode arch=compute_$(SM),code=sm_$(SM) \
    -o helper.o -c helper.cu

app: app.cpp helper.h helper.o Makefile
	g++ -o app app.cpp helper.o  \
    -I/usr/lib/cuda/include \
    -L/usr/lib/x86_64-linux-gnu \
    -lcudart

clean:
	@rm -f *.o app

.PHONY: clean
