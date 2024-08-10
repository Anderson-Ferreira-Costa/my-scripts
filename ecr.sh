Remover todas imagens: docker image prune -a

Destino
aws ecr create-repository --region us-east-1 --repository-name saude-sharedlibrary-node-auto

Origem
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 923470527198.dkr.ecr.us-east-1.amazonaws.com

docker pull 923470527198.dkr.ecr.us-east-1.amazonaws.com/sinapse-sharedlibrary-node-auto:dev-latest

docker tag 923470527198.dkr.ecr.us-east-1.amazonaws.com/sinapse-sharedlibrary-node-auto:dev-latest 667054108373.dkr.ecr.us-east-1.amazonaws.com/saude-sharedlibrary-node-auto:dev-latest

Destino
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 667054108373.dkr.ecr.us-east-1.amazonaws.com

docker push 667054108373.dkr.ecr.us-east-1.amazonaws.com/saude-sharedlibrary-node-auto:dev-latest