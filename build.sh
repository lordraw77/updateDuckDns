#!/bin/bash

# Script Bash per build, tag e push di immagine Docker con variabili parametrizzate

# Definizione delle variabili
BASE_IMAGE_NAME="updateduckdns"
IMAGE_MAJOR_VERSION="1.0"
PYTHON_VERSION="3.13.3"
ALPINE_VERSION="3.21"
DOCKER_HUB_USERNAME="lordraw"

# Tag completo che include versioni di Python e Alpine
DETAILED_TAG="${IMAGE_MAJOR_VERSION}v${PYTHON_VERSION}-alpine${ALPINE_VERSION}"

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Visualizza le informazioni di configurazione
echo -e "${CYAN}===== Configurazione del build Docker =====${NC}"
echo -e "${YELLOW}Nome immagine base: ${BASE_IMAGE_NAME}${NC}"
echo -e "${YELLOW}Versione immagine: ${IMAGE_MAJOR_VERSION}${NC}"
echo -e "${YELLOW}Versione Python: ${PYTHON_VERSION}${NC}"
echo -e "${YELLOW}Versione Alpine: ${ALPINE_VERSION}${NC}"
echo -e "${YELLOW}Tag dettagliato: ${DETAILED_TAG}${NC}"
echo -e "${YELLOW}Username Docker Hub: ${DOCKER_HUB_USERNAME}${NC}"
echo -e "${CYAN}=========================================${NC}"

# Costruzione dell'immagine Docker
echo -e "${GREEN}Costruzione dell'immagine Docker...${NC}"
docker build -t "${BASE_IMAGE_NAME}:${IMAGE_MAJOR_VERSION}" .

# Verifica se la build ha avuto successo
if [ $? -ne 0 ]; then
    echo -e "${RED}Errore durante la costruzione dell'immagine Docker!${NC}"
    exit 1
fi

# Creazione dei tag locali
echo -e "${GREEN}Creazione dei tag locali...${NC}"
docker tag "${BASE_IMAGE_NAME}:${IMAGE_MAJOR_VERSION}" "${BASE_IMAGE_NAME}:latest"
docker tag "${BASE_IMAGE_NAME}:${IMAGE_MAJOR_VERSION}" "${BASE_IMAGE_NAME}:${DETAILED_TAG}"

# Creazione dei tag per Docker Hub
echo -e "${GREEN}Creazione dei tag per Docker Hub...${NC}"
docker tag "${BASE_IMAGE_NAME}:${IMAGE_MAJOR_VERSION}" "${DOCKER_HUB_USERNAME}/${BASE_IMAGE_NAME}:${IMAGE_MAJOR_VERSION}"
docker tag "${BASE_IMAGE_NAME}:latest" "${DOCKER_HUB_USERNAME}/${BASE_IMAGE_NAME}:latest"
docker tag "${BASE_IMAGE_NAME}:${DETAILED_TAG}" "${DOCKER_HUB_USERNAME}/${BASE_IMAGE_NAME}:${DETAILED_TAG}"

# Verifica se Docker è installato e in esecuzione
echo -e "${YELLOW}Verificando che Docker sia installato...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker non è installato o non è nel PATH.${NC}"
    exit 1
fi

# Verifica se l'utente è loggato su Docker Hub
echo -e "${YELLOW}Verificando login su Docker Hub...${NC}"
docker pull hello-world &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Non sei loggato su Docker Hub o hai problemi di connessione.${NC}"
    echo -e "${YELLOW}Esecuzione di docker login...${NC}"
    docker login
    if [ $? -ne 0 ]; then
        echo -e "${RED}Login fallito. Impossibile procedere.${NC}"
        exit 1
    fi
fi

# Push delle immagini su Docker Hub
echo -e "${GREEN}Avvio push delle immagini su Docker Hub...${NC}"

echo -e "${YELLOW}Push del tag '${IMAGE_MAJOR_VERSION}'...${NC}"
docker push "${DOCKER_HUB_USERNAME}/${BASE_IMAGE_NAME}:${IMAGE_MAJOR_VERSION}"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Push del tag '${IMAGE_MAJOR_VERSION}' completato con successo.${NC}"
else
    echo -e "${RED}Errore durante il push del tag '${IMAGE_MAJOR_VERSION}'.${NC}"
fi

echo -e "${YELLOW}Push del tag '${DETAILED_TAG}'...${NC}"
docker push "${DOCKER_HUB_USERNAME}/${BASE_IMAGE_NAME}:${DETAILED_TAG}"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Push del tag '${DETAILED_TAG}' completato con successo.${NC}"
else
    echo -e "${RED}Errore durante il push del tag '${DETAILED_TAG}'.${NC}"
fi

echo -e "${YELLOW}Push del tag 'latest'...${NC}"
docker push "${DOCKER_HUB_USERNAME}/${BASE_IMAGE_NAME}:latest"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Push del tag 'latest' completato con successo.${NC}"
else
    echo -e "${RED}Errore durante il push del tag 'latest'.${NC}"
fi

echo -e "${CYAN}Processo completato!${NC}"