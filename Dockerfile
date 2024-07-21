FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    xz-utils \
    build-essential

# Install Verible
RUN apt-get update && apt-get upgrade -y \
    && wget https://github.com/chipsalliance/verible/releases/download/v0.0-3724-gdec56671/verible-v0.0-3724-gdec56671-linux-static-x86_64.tar.gz \
    &&   tar -xzf verible-v0.0-3724-gdec56671-linux-static-x86_64.tar.gz \
    && mv verible-v0.0-3724-gdec56671/bin/* /usr/local/bin/ 

CMD ["bash"]


