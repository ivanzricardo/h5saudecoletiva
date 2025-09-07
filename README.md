# h5SaudeColetiva
## Repositório de dados e códigos para a construção do banco de índice h5 (Google scholar) na área da Saúde Coletiva

#Última atualização: 06/09/2025. #Contato: ivanzricardo@gmail.com

Rotina para construção e atualização do banco

### Passo 1: Gerar uma lista de páginas (url) de busca no Google Scholar para cada periódico da área de saúde coletiva indicado.
Usar o código em python disponível em https://colab.research.google.com/drive/1xDQcNQvGk0LWT19pMT6s3b36z3Ikuy_t?usp=sharing
Obs: na última atualização, foi considerado o arquivo base do qualis 2017-2020 disponível na plataforma Sucupira: https://github.com/ivanzricardo/h5saudecoletiva/raw/refs/heads/main/QUALIS_saude_coletiva_2017-2020.xlsx

IMPORTANTE: No arquivo de trabalho em Excel, foi gerada a coluna "titulo_limpo" que retira os complementos entre parênteses em títulos (ex: ONLINE, PRINT) com uso da função =SEERRO(TEXTOANTES(B2;"(");B2). Isso foi necessário, pois o complemento prejudicava a busca na plataforma Google Scholar.

### Passo 2: A partir de um arquivo de texto (.txt) com a lista de todas as urls geradas, acessar e salvar o código fonte da página em html - isso é necessário por conta do sistema anti-bot do google que não permite a raspagem direta dos dados nas páginas indicadas

Para isso, sugere-se usar a ferramenta "Download HTML from URLs" (https://apify.com/mtrunkat/url-list-download-html) e salvar os outputs (htmls) em uma pasta local.
Obs: na última atualização, foi utilizado o seguinte arquivo de url: https://github.com/ivanzricardo/h5saudecoletiva/raw/refs/heads/main/urls_h5.txt

### Passo 3: fazer a raspagem de dados nos arquivos html locais
Usar a linguagem R para este passo (ou python, se preferir). 
Obs: na última atualização, foi utilizado o seguinte script em R: https://raw.githubusercontent.com/ivanzricardo/h5saudecoletiva/refs/heads/main/Script_H5saudecoletiva.R

# Atualizações: 
O banco pode ser constantemente atualizado com inclusão de novas revistas:
1) Manualmente (rápido): cada registro pode ser adicionado ao banco final após consulta manual na página da Google schoolar
2) Automatizado (lento): cada revista nova é adicionada ao banco inicial das revistas da area de saude coletiva (QUALIS_saude_coletiva_2017-2020) e o processo completo é repetido

# Última versão:
Banco final disponível atualizado em 06/09/2025 com o status do índice H5 da Google Scholar cobrindo artigos publicados entre 2020 e 2024 (inclusivos), baseadas em citações de todos os artigos indexados no Google Scholar até julho de 2025 (https://scholar.google.com/intl/en/scholar/metrics.html)

# Como citar
Zimmermann IR. h5SaudeColetiva: Repositório de dados e códigos para a construção do banco de índice h5 (Google Scholar) na área da Saúde Coletiva [Internet]. GitHub; 2025. Disponível em: https://github.com/ivanzricardo/h5saudecoletiva/

