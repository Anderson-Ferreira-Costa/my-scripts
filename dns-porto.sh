#!/bin/bash

# Solicitar credenciais da conta
read -p "AWS_ACCESS_KEY_ID da conta onde foi provisionada a Zona de Domínio no Route53: " AWS_ACCESS_KEY_ID
read -p "AWS_SECRET_ACCESS_KEY da conta onde foi provisionada a Zona de Domínio no Route53: " AWS_SECRET_ACCESS_KEY
read -p "AWS_SESSION_TOKEN da conta onde foi provisionada a Zona de Domínio no Route53: " AWS_SESSION_TOKEN

# Exportar as credenciais como variáveis de ambiente
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

# Account ID, Ex: "807445251352"
read -p "Account ID da Conta onde foi provisionada a Zona de Domínio no Route53: " CONTA

# Zona de Domínio"
read -p "Zona de Domínio a ser compartilhada com a Porto (ex: minhazona.dev.awsporto): " ZONA

SHARED_SERVICES_ACCOUNT_ID="785535932771"
VPC_SHARED_REGION="us-east-1"
VPC_SHARED_REGION_SP="sa-east-1"
VPC_SHARED_REGION_CA="ca-central-1"
VPC_SHARED_ID="vpc-07ef42ab0fbd6cc20"
VPC_SHARED_ID_SP="vpc-0391384349c35b114"
VPC_SHARED_ID_CA="vpc-0e6e74202c9e185fd"
ZONEID=$(/usr/local/bin/aws route53 list-hosted-zones --query 'HostedZones[*].[Id,Name]' --output text | tr "\t" ";" | egrep ";${ZONA}.$" | cut -f3 -d "/" | cut -f1 -d ";")

echo "hosted-zone-id=${ZONEID}"

/usr/local/bin/aws  route53 create-vpc-association-authorization --hosted-zone-id ${ZONEID} --vpc VPCRegion=${VPC_SHARED_REGION},VPCId=${VPC_SHARED_ID}
/usr/local/bin/aws  --region sa-east-1 route53 create-vpc-association-authorization --hosted-zone-id ${ZONEID} --vpc VPCRegion=${VPC_SHARED_REGION_SP},VPCId=${VPC_SHARED_ID_SP}
/usr/local/bin/aws  --region ca-central-1 route53 create-vpc-association-authorization --hosted-zone-id ${ZONEID} --vpc VPCRegion=${VPC_SHARED_REGION_CA},VPCId=${VPC_SHARED_ID_CA}
RESULT1=$?

# Solicitar credenciais da conta Shared
read -p "AWS_ACCESS_KEY_ID da conta Shared: " AWS_ACCESS_KEY_ID
read -p "AWS_SECRET_ACCESS_KEY da conta Shared: " AWS_SECRET_ACCESS_KEY
read -p "AWS_SESSION_TOKEN da conta Shared: " AWS_SESSION_TOKEN

# Exportar as credenciais como variáveis de ambiente
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

/usr/local/bin/aws  route53 associate-vpc-with-hosted-zone --hosted-zone-id ${ZONEID} --vpc VPCRegion=${VPC_SHARED_REGION},VPCId=${VPC_SHARED_ID}
/usr/local/bin/aws  --region sa-east-1 route53 associate-vpc-with-hosted-zone --hosted-zone-id ${ZONEID} --vpc VPCRegion=${VPC_SHARED_REGION_SP},VPCId=${VPC_SHARED_ID_SP}
/usr/local/bin/aws  --region ca-central-1 route53 associate-vpc-with-hosted-zone --hosted-zone-id ${ZONEID} --vpc VPCRegion=${VPC_SHARED_REGION_CA},VPCId=${VPC_SHARED_ID_CA}
RESULT2=$?

echo " "

if [ ${RESULT1} -eq 0 ]; then
    if [ ${RESULT2} -eq 0 ]; then
        echo "Aguarde alguns instantes para que você possa validar com os seguintes comandos (através de uma maquina no domínio portoseguro.brasil):";
        echo " "
        echo "Linux: dig $ZONA NS @172.26.30.241";
        echo " "
        echo "Windows: nslookup -type=NS $ZONA 172.26.30.241";
    else
        echo "Domínio ${ZONA} já configurado anteriormente! Valide com os comandos abaixo:"
        echo " "
        echo "Linux: dig $ZONA NS @172.26.30.241";
        echo " "
        echo "Windows: nslookup -type=NS $ZONA 172.26.30.241";
    fi
else
    echo "Falha na configuração. Reveja os valores informados !!!"
fi
