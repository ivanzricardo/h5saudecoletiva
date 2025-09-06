# h5saudecoletiva
#Repositório de dados e códigos para a construção do banco de índice h5 (Google scholar) na área da Saúde Coletiva
Última atualização: 06/09/2025 Contato: ivanzricardo@gmail.com

Rotina para construção e atualização do banco

Passo 1: Gerar uma lista de páginas (url) de busca no google scholar para cada periódico da área de saúde coletiva indicado.
Usar o código em python disponível em https://colab.research.google.com/drive/1xDQcNQvGk0LWT19pMT6s3b36z3Ikuy_t?usp=sharing
Obs: na última atualização, foi considerado o arquivo base do qualis 2017/2020: https://github.com/ivanzricardo/h5saudecoletiva/raw/refs/heads/main/QUALIS_saude_coletiva_2017-2020.xlsx

Passo 2: A partir de um arquivo de texto (.txt) com a lista de todas as urls gerada, acessar e salvar o código fonte da página em html. Obs: isso é necessário por conta do anti-bot do google que não permite a raspagem direta dos dados nas páginas
Usar a ferramenta Download HTML from URLs (https://apify.com/mtrunkat/url-list-download-html)
Salvar os outputs (htmls) em uma pasta local
Obs: na última atualização, foi utilizado arquivo gerado: https://github.com/ivanzricardo/h5saudecoletiva/raw/refs/heads/main/urls_h5.txt

Passo 3: fazer a raspagem do código nos arquivos locais
Usar a linguagem R para este passo (ou python, se preferir): inserir link do código
