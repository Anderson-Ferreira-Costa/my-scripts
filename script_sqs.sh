#!/bin/bash
# Configurações
FILA_URL="https://sqs.ca-central-1.amazonaws.com/777760191323/recurso-glosa-integracao-porto-deadletter-production"
ARQUIVO_SAIDA="arquivo.txt"
MAX_NUMERO_MENSAGENS=10
# Verifica se a AWS CLI está instalada
if ! command -v aws &> /dev/null; then
    echo "AWS CLI não está instalada. Instale-a primeiro."
    exit 1
fi
# Coleta mensagens da fila SQS até que não haja mais mensagens
while true; do
    mensagens=$(aws sqs receive-message --queue-url "$FILA_URL" --max-number-of-messages "$MAX_NUMERO_MENSAGENS" --output json)
    # Verifica se há mensagens
    quantidade_mensagens=$(echo "$mensagens" | jq -r '.Messages | length')
    if [[ $quantidade_mensagens -eq 0 ]]; then
        break  # Sai do loop se não houver mais mensagens
    fi
    # Extrai e salva o corpo das mensagens
    echo "$mensagens" | jq -r '.Messages[] | .Body' >> "$ARQUIVO_SAIDA"
    # Exclui as mensagens para que não sejam recebidas novamente
    for i in $(seq 0 $(($quantidade_mensagens - 1))); do
        receipt_handle=$(echo "$mensagens" | jq -r ".Messages[$i] | .ReceiptHandle")
        aws sqs delete-message --queue-url "$FILA_URL" --receipt-handle "$receipt_handle"
    done
done
echo "Todas as mensagens coletadas e salvas em $ARQUIVO_SAIDA."
