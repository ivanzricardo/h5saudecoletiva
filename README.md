# h5SaudeColetiva
#Repositório de dados e códigos para a construção do banco de índice h5 (Google scholar) na área da Saúde Coletiva

#Última atualização: 06/09/2025. #Contato: ivanzricardo@gmail.com

Rotina para construção e atualização do banco

Passo 1: Gerar uma lista de páginas (url) de busca no google scholar para cada periódico da área de saúde coletiva indicado.
Usar o código em python disponível em https://colab.research.google.com/drive/1xDQcNQvGk0LWT19pMT6s3b36z3Ikuy_t?usp=sharing
Obs: na última atualização, foi considerado o arquivo base do qualis 2017/2020: https://github.com/ivanzricardo/h5saudecoletiva/raw/refs/heads/main/QUALIS_saude_coletiva_2017-2020.xlsx

Passo 2: A partir de um arquivo de texto (.txt) com a lista de todas as urls gerada, acessar e salvar o código fonte da página em html. Obs: isso é necessário por conta do anti-bot do google que não permite a raspagem direta dos dados nas páginas
Usar a ferramenta Download HTML from URLs (https://apify.com/mtrunkat/url-list-download-html).
Salvar os outputs (htmls) em uma pasta local
Obs: na última atualização, foi utilizado arquivo gerado: https://github.com/ivanzricardo/h5saudecoletiva/raw/refs/heads/main/urls_h5.txt

Passo 3: fazer a raspagem do código nos arquivos locais
Usar a linguagem R para este passo (ou python, se preferir): https://raw.githubusercontent.com/ivanzricardo/h5saudecoletiva/refs/heads/main/Script_H5saudecoletiva.R

# Atualizações: 
O banco pode ser constantemente atualizado com inclusão de novas revistas:
1) Manualmente (rápido): cada registro pode ser adicionado ao banco final após consulta manual na página da Google schoolar
2) Automatizado: cada revista nova é adicionada ao banco inicial das revistas da area de saude coletiva (QUALIS_saude_coletiva_2017-2020) e o processo completo é repetido

# Última versão:
Banco final disponível atualizado em 06/09/2025 com o status do índice H5 da Google Schoolar cobrindo artigos publicados entre 2020 e 2024 (inclusivos), baseadas em citações de todos os artigos indexados no Google Scholar até julho de 2025 (https://scholar.google.com/intl/en/scholar/metrics.html)

# Como citar
Zimmermann IR. h5SaudeColetiva: Repositório de dados e códigos para a construção do banco de índice h5 (Google Scholar) na área da Saúde Coletiva [Internet]. GitHub; 2025. Disponível em: https://github.com/ivanzricardo/h5saudecoletiva/

