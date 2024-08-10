import re
import json

def extract_unique_names_from_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    # Ajuste o padrão regex conforme necessário
    pattern = re.compile(r'module\.ecr\["([^"]+)"\]')
    matches = pattern.findall(content)
    return set(matches)

def add_create_ecr_false(input_json_path, output_json_path, names):
    with open(input_json_path, 'r', encoding='utf-8') as file:
        json_content = json.load(file)
    
    # Adiciona "create_ecr": false aos blocos que correspondem aos nomes
    for name in names:
        if name in json_content.get("aplicacoes", {}):
            json_content["aplicacoes"][name]["create_ecr"] = False
    
    with open(output_json_path, 'w', encoding='utf-8') as file:
        json.dump(json_content, file, ensure_ascii=False, indent=4)

# Caminho para o arquivo com os nomes a serem extraídos
names_file_path = 'ecr.txt'
# Caminho para o arquivo JSON de entrada
input_json_path = 'ecr.json'
# Caminho para o arquivo JSON de saída
output_json_path = 'ecr-new.json'

# Extrai os nomes únicos
names = extract_unique_names_from_file(names_file_path)
# Adiciona "create_ecr": false aos blocos no arquivo JSON
add_create_ecr_false(input_json_path, output_json_path, names)

print(f'"create_ecr": false foi adicionado e o resultado foi salvo em {output_json_path}')
