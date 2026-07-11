-- 1. O Conceito Fundamental: Vector Embeddings

Para entender a busca vetorial, primeiro precisamos entender o que é um vetor de embedding.

Pense nisso como uma tradução universal. Modelos de Machine Learning, chamados de "Embedding Models", são treinados para converter dados complexos e não estruturados (como texto, imagens, áudio, moléculas químicas) em uma representação puramente numérica: uma longa lista de números de ponto flutuante. Essa lista é o vetor.

A característica mágica desses vetores é que eles capturam o significado semântico do dado original.

Exemplo com Texto: As frases "O rei sentou-se no trono" e "O monarca ocupou a cadeira real" são textualmente diferentes, mas semanticamente quase idênticas. Um bom modelo de embedding geraria vetores muito próximos um do outro no espaço matemático para essas duas frases.
Exemplo com Imagens: Uma foto de um golden retriever e um desenho de um golden retriever teriam vetores muito mais próximos entre si do que de um vetor de uma imagem de um gato.

Essencialmente, um vetor é uma "impressão digital" ou "coordenada GPS" do significado de um dado.

-- 2. O Problema: A Busca por Similaridade

Com o advento da IA Generativa e a explosão de dados não estruturados, um novo tipo de consulta se tornou crucial: a busca por similaridade. As perguntas não são mais baseadas em correspondências exatas (WHERE id = 123), mas em proximidade de significado:

"Quais são os 10 documentos mais relevantes para esta pergunta do usuário?"
"Encontre produtos com descrições similares a este que o cliente está vendo."
"Esta imagem enviada pelo usuário viola nossas políticas de conteúdo?" (Comparando-a com um banco de imagens proibidas).

Realizar essa busca de forma ingênua (brute-force) é computacionalmente desastroso. Comparar um vetor com bilhões de outros, um por um, para encontrar os mais próximos levaria um tempo impraticável.

-- 3. A Solução da Oracle: Componentes Técnicos do AI Vector Search

O Oracle AI Vector Search integra todas as ferramentas necessárias para realizar essa busca de forma eficiente e escalável, diretamente dentro do banco de dados.

a. Tipo de Dado Nativo VECTOR

O Oracle 23ai introduz um tipo de dado de primeira classe chamado VECTOR. Isso é fundamental, pois permite que o banco de dados entenda e otimize o armazenamento e o processamento desses dados.

-- Criando uma tabela com uma coluna de vetor
CREATE TABLE documents (
    id           NUMBER PRIMARY KEY,
    doc_text     CLOB,
    doc_vector   VECTOR(1536, FLOAT32) -- Vetor com 1536 dimensões, formato FLOAT32
);

Dimensões: O número de elementos na lista (ex: 1536 para o modelo text-embedding-ada-002 da OpenAI).
Formato: A precisão dos números (FLOAT32, FLOAT64, etc.).
b. Índices Vetoriais de "Vizinho Mais Próximo Aproximado" (ANN)

Este é o coração da performance. Em vez de uma busca exata, usamos índices ANN (Approximate Nearest Neighbor) que encontram resultados "bons o suficiente" (quase sempre os melhores) de forma extremamente rápida. O Oracle implementa dois tipos principais:

HNSW (Hierarchical Navigable Small World): O mais avançado e performático. Ele cria uma espécie de "mapa de metrô" multi-camadas para os vetores. Em vez de ir de "estação em estação" (vetor a vetor), ele pode pegar "linhas expressas" para pular rapidamente para a região correta do espaço vetorial e então fazer uma busca fina localmente. É ideal para a maioria dos casos de uso de alta performance.
IVF (Inverted File Flat): Um algoritmo mais simples que agrupa vetores em clusters. A busca primeiro identifica os clusters mais promissores e depois busca apenas dentro deles.
-- Criando um índice HNSW na nossa coluna de vetor
CREATE VECTOR INDEX doc_vector_idx ON documents (doc_vector)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE;

DISTANCE COSINE: Especifica a métrica matemática para medir a "proximidade". As mais comuns são:
COSINE (Cosseno): Mede o ângulo entre os vetores. Ótima para dados textuais e semânticos.
EUCLIDEAN (Euclidiana): Mede a distância em linha reta entre os pontos. Boa para dados como features de imagens.
DOT_PRODUCT (Produto Escalar): Relacionada ao Cosseno, também muito usada.
c. Novas Funções e Sintaxe SQL

O Oracle estendeu o SQL para trabalhar nativamente com vetores.

VECTOR_DISTANCE: Calcula a distância entre dois vetores. É a função principal usada no WHERE ou ORDER BY.
VECTOR_EMBEDDING (Opcional): Pode chamar um modelo de embedding (hospedado no OCI, por exemplo) diretamente do SQL para gerar um vetor a partir de um texto ou imagem, simplificando o processo.
Sintaxe ORDER BY VECTOR_DISTANCE(...): Otimizada para usar o índice vetorial e encontrar os "Top-K" resultados mais próximos de forma eficiente.
-- Exemplo de consulta: Encontrar os 5 documentos mais relevantes para uma pergunta
-- 1. Primeiro, geramos o vetor para a pergunta do usuário (fora do SQL ou com VECTOR_EMBEDDING)
--    :user_question_vector -> é uma variável contendo o vetor da pergunta

-- 2. Executamos a busca por similaridade
SELECT
    id,
    doc_text,
    VECTOR_DISTANCE(doc_vector, :user_question_vector, COSINE) AS similarity_score
FROM
    documents
ORDER BY
    similarity_score
FETCH FIRST 5 ROWS ONLY;

-- 4. O Fluxo de Trabalho Completo e Casos de Uso

Geração (Vectorization): Um processo (batch ou em tempo real) lê os dados brutos (textos, imagens), chama um modelo de embedding (ex: via API da OpenAI, Cohere, ou um modelo open-source) e gera os vetores.
Armazenamento: Os vetores são inseridos na tabela Oracle na coluna do tipo VECTOR.
Indexação: O índice vetorial (HNSW) é criado sobre essa coluna.
Busca (Inference): A aplicação recebe uma entrada do usuário (uma pergunta, uma imagem), a converte em um vetor usando o mesmo modelo de embedding, e executa a consulta SQL de busca por similaridade.

Principal Caso de Uso: RAG (Retrieval-Augmented Generation) Este é o padrão que alimenta a maioria dos chatbots "Converse com seus dados".

Retrieval (Recuperação): A pergunta do usuário é usada para fazer uma busca vetorial (AI Vector Search) no banco de dados e encontrar os trechos de texto mais relevantes.
Augmentation (Aumento): Esses trechos recuperados são inseridos no prompt enviado a um Large Language Model (LLM) como o GPT-4.
Generation (Geração): O LLM recebe o prompt aumentado ("Usando APENAS este contexto: [trechos do banco de dados], responda a esta pergunta: [pergunta do usuário]") e gera uma resposta precisa e baseada nos dados, evitando alucinações.
Conclusão: A Vantagem de Ter Tudo no Oracle

Ao integrar o AI Vector Search, o Oracle permite que as empresas construam aplicações de IA sofisticadas sem precisar de um banco de dados vetorial especializado separado. Isso traz enormes vantagens:

Consistência Transacional: Seus dados vetoriais e seus dados de negócio (ex: estoque, clientes) vivem juntos e são consistentes.
Segurança e Governança: Aplica as mesmas políticas robustas de segurança do Oracle aos seus dados de IA.
Simplicidade Operacional: Evita a complexidade e o custo de gerenciar e sincronizar múltiplos sistemas de dados.
Performance com Exadata: E, como vimos, quando executado em Exadata, todo o processo de busca é massivamente acelerado pelo AI Smart Scan, tornando-o viável para aplicações em tempo real e em grande escala.

-- 1. O Problema Tradicional (Sem Exadata)

Imagine que você tem uma biblioteca gigantesca (seu armazenamento de dados) e precisa encontrar todas as frases que contêm a palavra "inovação" em todos os livros de uma estante inteira.

No modelo tradicional de banco de dados, o processo seria:

O bibliotecário (o servidor de banco de dados) vai até a estante (o storage).
Ele pega todos os livros daquela estante, um por um.
Leva essa pilha enorme de livros para a mesa de leitura dele (a memória do servidor de banco de dados).
Na mesa, ele abre cada livro, folheia página por página e procura as frases com a palavra "inovação".
No final, ele te entrega apenas as frases que você pediu.

Percebe a ineficiência? Uma quantidade massiva de dados inúteis (livros e páginas que não continham a palavra) foi transportada do storage para o servidor, consumindo tempo, rede e poder de processamento do servidor.

-- 2. A Solução: Exadata Smart Scan (O Básico)

O Exadata muda completamente essa lógica. Ele é um "sistema projetado" onde o servidor de banco de dados e o armazenamento (chamado de Storage Cells) são inteligentes e conversam entre si de forma otimizada.

Usando a mesma analogia da biblioteca:

Você pede ao bibliotecário (servidor de banco de dados) as frases com a palavra "inovação".
O bibliotecário, em vez de buscar os livros, envia um "assistente inteligente" para cada prateleira (as Storage Cells).
Ele diz aos assistentes: "Procurem em seus livros apenas as frases com a palavra 'inovação' e me tragam somente os resultados."
Cada assistente (a Storage Cell) faz a filtragem ali mesmo, na estante.
Eles entregam ao bibliotecário apenas as frases que você queria.

Isso é o Smart Scan. O processamento da consulta (a filtragem) é "descarregado" (offloaded) para o armazenamento. Os benefícios, conforme destacado em artigos como o da Rackspace, são imensos:

Redução de I/O: A quantidade de dados trafegando na rede entre o storage e o servidor é drasticamente menor.
Menos Carga no Servidor: O servidor de banco de dados não gasta mais CPU para filtrar dados irrelevantes, ficando livre para outras tarefas.
Performance Acelerada: As consultas, especialmente as que leem grandes volumes de dados (como relatórios), ficam muito mais rápidas.

O Smart Scan é inteligente o suficiente para descarregar não apenas filtros simples (WHERE), mas também a projeção de colunas (trazendo só as colunas pedidas no SELECT) e até algumas agregações.

-- 3. A Evolução: AI Smart Scan

Agora, vamos adicionar a camada de Inteligência Artificial, que é o foco do artigo da Oracle, Exadata AI Smart Scan Deep Dive.
O mundo da IA introduziu um novo tipo de dado: vetores. Pense em um vetor como uma "impressão digital" numérica de um dado complexo. Uma imagem, um documento de texto ou um áudio podem ser convertidos em uma longa lista de números (um vetor).
A grande vantagem é que, no mundo da matemática, podemos calcular a "distância" ou "similaridade" entre esses vetores. Vetores de imagens de gatos estarão "próximos" uns dos outros, enquanto estarão "longe" de vetores de imagens de carros.
O novo problema: A consulta agora não é mais "me traga linhas onde a coluna cidade = 'São Paulo'". A consulta agora é "me traga os 10 documentos mais parecidos com este aqui" ou "encontre as 5 imagens mais similares a esta".

Sem o AI Smart Scan, o processo seria o seguinte:

O servidor de banco de dados teria que pedir TODOS os vetores da tabela para o storage.
Traria esses milhões de vetores (que são dados grandes) para sua memória.
Executaria cálculos matemáticos complexos (como similaridade de cosseno) em cada um deles para compará-los com o vetor de referência.
Finalmente, retornaria os 10 mais próximos.

É o mesmo problema da biblioteca, mas elevado a uma nova potência de complexidade e volume de dados.

Como o AI Smart Scan Resolve Isso

O AI Smart Scan estende a inteligência do Smart Scan para o mundo dos vetores.

Usando nossa analogia final:

Você entrega uma "impressão digital" (vetor) ao bibliotecário e pede: "Encontrem os 10 livros com a impressão digital mais parecida com esta".
O bibliotecário envia a sua impressão digital para os assistentes inteligentes em cada prateleira (Storage Cells).
Cada assistente, ali mesmo na estante, compara a sua impressão digital com a de todos os livros da sua seção. Ele usa ferramentas super rápidas (instruções de processador otimizadas, como SIMD) para fazer esses cálculos em paralelo.
Cada assistente cria uma pequena lista dos seus "top 10" locais e a envia para o bibliotecário.
O bibliotecário apenas junta essas pequenas listas e determina os 10 melhores resultados globais para te entregar.

O AI Smart Scan descarrega os cálculos de similaridade de vetores para as Storage Cells. Isso significa que bilhões de cálculos complexos acontecem diretamente no armazenamento, e apenas um minúsculo conjunto de resultados viaja pela rede.

Resumo dos Benefícios do AI Smart Scan
Aceleração Massiva para IA: Torna as buscas por similaridade em grandes volumes de dados (imagens, textos, etc.) ordens de magnitude mais rápidas.
Eficiência Extrema: Evita o movimento de enormes conjuntos de dados vetoriais pela rede.
Escalabilidade: Quanto mais Storage Cells você adiciona ao seu Exadata, mais poder de processamento paralelo você ganha para suas consultas de IA.

Detalhes Técnicos do Smart Scan (A Fundação)

Para que o Smart Scan ocorra, algumas condições técnicas precisam ser atendidas.

Gatilho da Operação: O Smart Scan é ativado principalmente por operações de Direct Path Read. Isso acontece tipicamente durante um Full Table Scan (FTS) ou um Fast Full Index Scan (FFIS). O Otimizador do Oracle decide que ler todos os blocos da tabela é mais eficiente do que usar um índice B-Tree tradicional (por exemplo, quando a seletividade do WHERE é baixa).

O Protocolo iDB: A comunicação entre os Servidores de Banco de Dados e as Storage Cells não usa um protocolo de I/O padrão (como NFS ou iSCSI). Ela utiliza o iDB (Intelligent Database Protocol). A grande diferença é que, em vez de o servidor de banco de dados pedir "me dê o bloco de dados número X", ele envia um pacote iDB que diz "execute esta operação (ex: FTS com este filtro WHERE) neste objeto". A inteligência está em enviar a operação, e não apenas um pedido de leitura.

Processo CELLSRV na Storage Cell: Em cada Storage Server, o processo principal é o CELLSRV. Ele recebe os pacotes iDB, interpreta a operação solicitada e executa o trabalho. As principais operações de offload são:

Filtro de Linhas: Aplica as cláusulas WHERE diretamente nos blocos de dados.
Projeção de Colunas: Descarta as colunas que não foram solicitadas no SELECT, reduzindo drasticamente o volume de dados a ser retornado.
Offload de Funções: Funções de agregação simples (MIN, MAX, COUNT, SUM) e offload de joins (usando Bloom Filters) também podem ser parcialmente executados nas cells.
Comandos e Monitoramento do Smart Scan

Você pode verificar se o Smart Scan está sendo eficaz usando views de performance e analisando planos de execução.

-- 1. Estatísticas do Sistema (V$SYSSTAT): A métrica mais importante é a cell physical IO bytes saved by smart scan. Ela mostra exatamente quantos bytes nunca trafegaram pela rede porque o Smart Scan os filtrou na origem.

-- Comando para verificar a economia gerada pelo Smart Scan
SELECT
    name,
    value,
    ROUND(value / 1024 / 1024 / 1024, 2) AS value_gb
FROM
    v$sysstat
WHERE
    name IN (
        'physical read total bytes',
        'cell physical IO interconnect bytes',
        'cell physical IO bytes saved by smart scan'
    );

physical read total bytes: O que o banco de dados teria lido do disco.
cell physical IO interconnect bytes: O que realmente passou pela rede.
cell physical IO bytes saved by smart scan: A diferença, ou seja, a sua economia.

-- 2. Plano de Execução: Ao analisar um plano de execução, a indicação de que o Smart Scan foi utilizado aparece na seção de predicados com a palavra-chave STORAGE.

-- Exemplo de saída de um EXPLAIN PLAN
----------------------------------------------------------------------------------------------------
| Id  | Operation                 | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |             | 87136 |    10M| 70175   (1)| 00:00:03 |
|*  1 |  TABLE ACCESS STORAGE FULL| SALES       | 87136 |    10M| 70175   (1)| 00:00:03 |
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------
   1 - storage("AMOUNT_SOLD" > 1000)   -->> ISSO INDICA SMART SCAN
       filter("AMOUNT_SOLD" > 1000)


A linha storage("AMOUNT_SOLD" > 1000) confirma que o filtro foi descarregado para as Storage Cells.

Detalhes Técnicos do AI Smart Scan

O AI Smart Scan é uma extensão dessa arquitetura para o Oracle Database 23ai com a feature AI Vector Search.

Pré-requisitos:

Oracle Database 23ai ou superior.
Hardware Exadata compatível.
Uso do tipo de dado VECTOR e de um índice vetorial.

O Índice Vetorial (HNSW): A busca por similaridade em bilhões de vetores seria inviável sem um índice. O Oracle utiliza o algoritmo HNSW (Hierarchical Navigable Small World). Este é um índice do tipo ANN (Approximate Nearest Neighbor). Ele não garante encontrar exatamente os vizinhos mais próximos, mas encontra resultados extremamente próximos com uma performance ordens de magnitude superior a uma busca exata.

A Sintaxe SQL e o Processo de Offload: A consulta utiliza novas funções como VECTOR_DISTANCE.

-- Comando para buscar os 5 produtos mais similares a um vetor de referência
SELECT product_name, VECTOR_DISTANCE(product_vector, :reference_vector, COSINE) as similarity
FROM products
ORDER BY similarity
FETCH FIRST 5 ROWS ONLY;

O fluxo técnico é o seguinte: a. O Otimizador do Oracle vê a função VECTOR_DISTANCE e a cláusula ORDER BY / FETCH FIRST. b. Ele utiliza o índice HNSW para identificar rapidamente um conjunto de ROWIDs candidatos. O índice poda drasticamente o espaço de busca, eliminando a necessidade de comparar com todos os vetores da tabela. c. O servidor de banco de dados envia, via protocolo iDB, este conjunto de ROWIDs candidatos e a operação VECTOR_DISTANCE (com o vetor de referência e a métrica de distância) para as Storage Cells. d. O processo CELLSRV em cada Storage Cell recebe a instrução. Ele lê os blocos de dados correspondentes aos ROWIDs candidatos. e. Aqui está a mágica: O CELLSRV executa o cálculo da distância vetorial (ex: Similaridade de Cosseno, Distância Euclidiana) diretamente nos processadores da Storage Cell. Para acelerar isso massivamente, ele utiliza instruções de CPU de baixo nível como SIMD (Single Instruction, Multiple Data), que realizam a mesma operação matemática em múltiplos dados simultaneamente. f. Cada Storage Cell retorna ao servidor de banco de dados apenas os seus "top 5" resultados locais (vetores e suas distâncias calculadas). g. O servidor de banco de dados apenas precisa agregar os resultados das (poucas) Storage Cells e determinar os 5 melhores globais.

-- O Papel do Exascale na Potencialização

Exascale não é uma feature, mas a evolução da arquitetura de hardware e rede do Exadata, projetada para escalar massivamente. É o que torna o AI Smart Scan viável em grande escala.

Arquitetura Scale-Out e Desacoplada: O Exascale permite escalar servidores de banco de dados e servidores de armazenamento de forma independente. Se sua carga de trabalho de IA é limitada pelo poder de processamento dos cálculos vetoriais (que acontecem no storage), você pode adicionar mais Storage Servers sem precisar adicionar mais servidores de banco de dados. Isso oferece uma escalabilidade muito mais granular e econômica.

Rede RoCE de Altíssima Performance: O Exascale utiliza RoCE (RDMA over Converged Ethernet) como sua rede interna (fabric).

RDMA (Remote Direct Memory Access) é a tecnologia chave aqui. Ela permite que um servidor (ex: o de banco de dados) acesse a memória de outro servidor (ex: o de storage) diretamente, sem envolver o sistema operacional de destino.
Isso resulta em uma latência extremamente baixa e um throughput altíssimo, pois elimina o overhead de processamento de rede do kernel.
O protocolo iDB, que carrega as operações do AI Smart Scan, roda sobre essa rede ultra-rápida, garantindo que a comunicação com dezenas ou centenas de Storage Servers não se torne um gargalo.

Paralelismo Massivo: Uma configuração Exascale pode ter um número muito grande de Storage Servers. Como o AI Smart Scan distribui os cálculos vetoriais entre todos eles, a performance escala linearmente. Se você dobrar o número de Storage Servers, você essencialmente dobra o poder de processamento para suas buscas vetoriais.

Em resumo, o fluxo técnico completo é:

AI Vector Search (SQL) → Otimizador (usa índice HNSW) → iDB (envia operação e ROWIDs) → Exascale RoCE Fabric (transporte) → Múltiplos CELLSRV (executam cálculo vetorial com SIMD) → iDB (retorna top-K) → Servidor DB (agrega e finaliza).

O Exascale fornece a plataforma de hardware massivamente paralela e a rede de baixíssima latência necessárias para que o AI Smart Scan execute cálculos complexos em escala, diretamente onde os dados residem.