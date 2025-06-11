#!/bin/bash

IMAGE_NAME="curso-kubernets"
TAG="latest"

echo "--- Iniciando a construção da imagem Docker: ${IMAGE_NAME}:${TAG} ---"

docker rmi "${IMAGE_NAME}:${TAG}" 2>/dev/null

# Construa a imagem Docker
docker build -t "${IMAGE_NAME}:${TAG}" .

# Verifica se o build foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "--- Imagem ${IMAGE_NAME}:${TAG} construída com sucesso! ---"
    exit 0
else
    echo "!!! Erro ao construir a imagem ${IMAGE_NAME}:${TAG}. Por favor, verifique o Dockerfile e as mensagens de erro acima. !!!"
    exit 1
fi