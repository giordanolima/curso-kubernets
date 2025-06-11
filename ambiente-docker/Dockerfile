# Usa a imagem LTS mais recente do Ubuntu
FROM ubuntu:latest

# Define um argumento para a versão do Docker CE a ser instalada
ARG DOCKER_VERSION="5:26.1.3-1~ubuntu.24.04~noble"

# Define o locale para evitar avisos de APT
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Atualiza os pacotes e instala as dependências necessárias para o Docker
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    vim \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Adiciona a chave GPG oficial do Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

# Adiciona o repositório Docker ao sources.list do APT
RUN echo \
    "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza os pacotes novamente e instala o Docker CE, Docker CE CLI e containerd.io
RUN apt-get update && \
    apt-get install -y \
    docker-ce=${DOCKER_VERSION} \
    docker-ce-cli=${DOCKER_VERSION} \
    containerd.io \
    && rm -rf /var/lib/apt/lists/*

# Instalar o Docker
RUN apt-get update && \
    apt-get install -y docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Expõe a porta padrão do Docker daemon
EXPOSE 2375

ENTRYPOINT ["dockerd"]
CMD ["--host=unix:///var/run/docker.sock", "--host=tcp://0.0.0.0:2375"]
