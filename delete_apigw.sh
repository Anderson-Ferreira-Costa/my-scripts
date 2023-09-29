#!/bin/bash

# Defina a região padrão para a Virgínia do Norte (us-east-1)
export AWS_DEFAULT_REGION=us-east-1

# Listar todos os API Gateways
api_gateway_ids=$(aws apigateway get-rest-apis --query "items[].id" --output text)

# Loop através dos IDs dos API Gateways e remova cada um
for api_id in $api_gateway_ids
do
  echo "Removendo o API Gateway: $api_id"
  
  # Remova os recursos do API Gateway
  aws apigateway delete-rest-api --rest-api-id $api_id
  
  # Opcional: Remova também o cache do API Gateway
  # aws apigateway delete-cache --rest-api-id $api_id
  
  # Opcional: Remova também as chaves de API associadas ao Gateway
  # aws apigateway delete-api-key --api-key <API-KEY-ID>
  
  # Adicione um atraso de 1 segundo entre as solicitações
  sleep 25
done

echo "Remoção de todos os API Gateways na região da Virgínia do Norte (us-east-1) concluída."
