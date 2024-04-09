local ?= 0
ifeq ($(local), 1)
    img = "mase-ubuntu2204:latest"
else
    img = "deepwok/mase-docker-cuda:latest"
endif

# Build Docker container
build-docker:
	docker pull docker.io/deepwok/mase-docker-cuda:latest;

shell: build-docker
	docker run -it --shm-size 256m \
	--name=ample-docker \
	-w /workspace \
	-v $(shell pwd):/workspace:z \
	-v /mnt/applications/Xilinx:/mnt/applications/Xilinx \
	-v /mnt/applications/mentor:/mnt/applications/mentor \
	-v /home/pg519/shared/board-files:/root/board-files:z \
	-v /home/pg519/shared/compile-simlib:/root/compile-simlib:z \
	-v /home/$(shell whoami)/.gitconfig:/root/.gitconfig \
	-v /home/$(shell whoami)/.ssh:/root/.ssh \
	$(img) /bin/bash