import boto3
import time
from botocore.exceptions import ClientError

# Inicializa o recurso DynamoDB com especificação da região
dynamodb = boto3.resource('dynamodb', region_name='sa-east-1')  # Substitua 'us-east-1' pela região correta

# Especifique o nome da tabela
table_name = 'table-dynamodb-nx-roteiro-prd'
table = dynamodb.Table(table_name)

# Função para excluir todos os itens da tabela com paginação e backoff exponencial
def delete_all_items():
    scan_kwargs = {}
    done = False
    start_key = None
    backoff_time = 1

    while not done:
        if start_key:
            scan_kwargs['ExclusiveStartKey'] = start_key

        response = table.scan(**scan_kwargs)
        items = response.get('Items', [])
        start_key = response.get('LastEvaluatedKey', None)
        
        with table.batch_writer() as batch:
            for each in items:
                while True:
                    try:
                        batch.delete_item(
                            Key={
                                'orcamento': each['orcamento'],
                                'horaRecebimento': each['horaRecebimento']
                            }
                        )
                        break
                    except ClientError as e:
                        if e.response['Error']['Code'] == 'ProvisionedThroughputExceededException':
                            print(f"Throughput exceeded, retrying in {backoff_time} seconds...")
                            time.sleep(backoff_time)
                            backoff_time = min(backoff_time * 2, 32)  # Exponencial até um máximo de 32 segundos
                        else:
                            raise

        done = start_key is None

    print(f'Todos os itens foram deletados da tabela {table_name}.')

# Chame a função para deletar os itens
delete_all_items()
