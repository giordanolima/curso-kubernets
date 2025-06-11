#!/bin/bash

IMAGE_NAME="curso-kubernets"
TAG="latest"
CONTAINER_NAME="curso-kubernets-container"
HOST_DOCKER_PORT="23750"

echo "--- Iniciando o ambiente de curso Docker/Kubernetes ---"
echo "Verificando se a imagem '${IMAGE_NAME}:${TAG}' existe localmente..."
IMAGE_EXISTS=$(docker images -q "${IMAGE_NAME}:${TAG}")

if [ -z "${IMAGE_EXISTS}" ]; then
    echo "Imagem '${IMAGE_NAME}:${TAG}' não encontrada. Chamando o script de build..."
    bash ./build.sh
    if [ $? -ne 0 ]; then
        echo "Erro: A construção da imagem falhou. Saindo."
        exit 1
    fi
else
    echo "Imagem '${IMAGE_NAME}:${TAG}' encontrada. Pulando o build."
fi

echo "Verificando e limpando contêiner existente com o nome '${CONTAINER_NAME}'..."

if docker inspect "${CONTAINER_NAME}" &>/dev/null; then
    echo "Contêiner '${CONTAINER_NAME}' encontrado."
    if docker inspect -f '{{.State.Status}}' "${CONTAINER_NAME}" | grep -q "running"; then
        echo "Parando o contêiner '${CONTAINER_NAME}'..."
        docker stop "${CONTAINER_NAME}"
    fi
    echo "Removendo o contêiner '${CONTAINER_NAME}'..."
    docker rm "${CONTAINER_NAME}"
else
    echo "Contêiner '${CONTAINER_NAME}' não encontrado."
fi

echo "Verificando se a porta ${HOST_DOCKER_PORT} está livre no host..."
if ss -tuln | grep -q ":${HOST_DOCKER_PORT}"; then
    echo "AVISO: A porta ${HOST_DOCKER_PORT} no host está OCUPADA. Isso pode causar o erro 'port is already allocated'."
    echo "Por favor, libere a porta ou altere a variável HOST_DOCKER_PORT no script 'start.sh'."
fi

echo "Subindo o contêiner '${CONTAINER_NAME}'..."
docker run -d \
    --privileged \
    --name "${CONTAINER_NAME}" \
    -p "${HOST_DOCKER_PORT}":2375 \
    "${IMAGE_NAME}:${TAG}"

if [ $? -ne 0 ]; then
    echo "!!! Erro ao subir o contêiner '${CONTAINER_NAME}'. Por favor, verifique os logs acima. !!!"
    exit 1
fi

echo "Contêiner '${CONTAINER_NAME}' iniciado com sucesso."
echo "Aguardando alguns segundos para o daemon Docker interno inicializar..."
sleep 5

echo "Entrando no bash do contêiner '${CONTAINER_NAME}'..."
if docker inspect -f '{{.State.Status}}' "${CONTAINER_NAME}" | grep -q "running"; then
    docker exec -it "${CONTAINER_NAME}" bash
else
    echo "Erro: Contêiner '${CONTAINER_NAME}' não está rodando. Não é possível entrar no bash."
    echo "Para debug, tente: docker logs ${CONTAINER_NAME}"
    exit 1
fi


echo "Sessão do bash encerrada."
echo "Para parar o contêiner, use 'docker stop ${CONTAINER_NAME}'."
echo "Para remover o contêiner, use 'docker rm ${CONTAINER_NAME}'."