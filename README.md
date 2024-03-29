
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

![forthebadge](https://img.shields.io/badge/GEMM-Building-orange)
![forthebadge](https://forthebadge.com/images/badges/built-with-science.svg)
<!-- badges: end -->

# Recuperação de Genomas apartir de metagenomas- Binning! <img src="imgs/1.png" align="right" width = "120px"/>

**Developer: MsC. Kelly Hidalgo**

Pipeline para reconstrução de genomas a partir de metagenomas, usando
várias ferramentas de *binning* e *DAS tools* para integrar os
resultados dos algoritmos de binning para calcular um conjunto otimizado
e não redundante de MAGs (*Metagenome Assembled Genomes*) de uma única
montagem.

------------------------------------------------------------------------

## Introdução

### Sequenciamento massivo de metagenomas

O sequenciamento massivo ou em larga escala de metagenomas, compreende a
extração do DNA total de uma amostra de qualquer ambiente ou tipo de
amostra (i.e. solo, agua, feces, esponjas marinas, tecidos vegetais,
etc) e o sequenciamento por uma técnica chamada *shotgun*. Onde o DNA
total é fragmentado em muitos pedacinhos, os quais são sequenciados
aleatoriamente, obtendo assim as chamadas *reads*, que são sequências
pequenas.

<img src="imgs/seq1.png" align="center" width = "100%"/>

O *binning* é uma técnica bioinformática para reconstruir genomas a
partir de metagenomas. O processamento inclui as seguintes fases: **1)
Sequenciamento de metagenomas**, do qual vai se obter reads; **2)
Controle de qualidade das reads**, usando ferramentas como *Trimmomatic*
são filtradas as reads de baixa qualidade; **3) Montagem das reads**,
dos quais vão se obter contigs ou scafolds; **4) Mapeamento das reads**,
isto com o objetivo de saber a abundância e o origem de cada read
(informação necessária para a seguinte etapa); **5)** ***Binning***,
usando diferentes ferramentas/algoritmos (i.e. *Metabat2, MaxBin,
CONCOCT, BinSanity*) que clusterizam os contigs/scalfolds baseado em
diferentes características similares tais como: níveis de cobertura de
cada contig/scalfold, genes marcadores de cópia única, perfil de
frequências de tetranucleotídeos, formando os genomas reconstruidos
também conhecidos como *MAGs* ou *Bins*; **6) Controle de qualidade**,
compreende o uso de ferramentas bioinformáticas (i.e. *CheckM, DAStool*)
para á analise da qualidade de cada um dos bins gerados, em ítems como
completude e contaminação; **7) Anotação taxonômica** e **8) Anotação
funcional**

A continuação uma visão geral do processo de **Binning**

<img src="imgs/binning.png" align="center" width = "100%"/>

> ## **O que vai encontrar aqui:**
>
> ### \* Controle de qualidade de sequenciamento shotgun
>
> ### \* Montagem de metagenomas
>
> ### \* Mapeamento de reads
>
> ### \* Reconstrução de genomas
>
> ### \* Anotação taxonômica e funcional de genomas

------------------------------------------------------------------------

# Ferramentas bioinformáticas

**Antes de começar:** Use o tutorial de
[Unix](https://github.com/khidalgo85/Unix) para aprender comandos
básicos em bash que serão muito úteis para este tutorial.

## Intalação Anaconda

É recomendável instalar Anaconda, pois é a forma mais fácil para
instalar as ferramentas bioinformáticas necessárias pro desenvolvimento
deste pipeline. Anaconda é uma distribuição livre e aberta das
linguagens *Python* e *R*, utilizada na ciência de dados e
bioinformática. As diferente versões dos programas se administram
mediante um sinstema de gestão chamado *conda*, o qual faz bastante
simples instalar, rodar e atualizar programas.
[Aqui](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
se encontram as instruções para a instalação de Anaconda.

Depois de instalado, *Anaconda* e o gestor *Conda*, podram ser criados
*ambientes virtuais* par a instalação das diferentes ferramentas
bioinformática que serão usadas.

> 🇪🇸 Es recomendable instalar Anaconda, pues es la forma más fácil para
> instalar las herramientas bioinformáticas necesarias para el
> desarrollo de este pipeline. Anaconda es una distribución libre y
> abierta de los lenguajes *Python* y *R*, utilizada en ciencia de datos
> y bioinformática. Las diferentes versiones de los programas se
> administran mediante un sistema de gestión llamado *conda*, el cual
> hace bastante sencillo instalar, correr y actualizar programas.
> [Aqui](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
> se encuentran las instrucciones para la instalación de Anaconda.
>
> Después de instalado *Anaconda* y su gestor *Conda*, podran ser
> creados *ambientes virtuales* para la instalación de las diferentes
> herramientas bioinformáticas que serán usadas.

------------------------------------------------------------------------

# I. Binning

## 0. Organizando os dados

## 0.1. Sequências

Em este tutorial será usado um dataset exemplo com quatro amostras. A
continuação descarregue o dataset:

    # Crie um diretório para este tutorail
    mkdir binning 
    cd binning/

Agora dentro de binning crie outro diretório chamado `00.RawData`, onde
vai descarregar o dataset de exemplo para este tutorial

    mkdir 00.RawData

Para descarregar o dataset…

    curl -L https://figshare.com/ndownloader/articles/19015058/versions/1 -o 00.RawData/dataset.zip
    unzip 00.RawData/dataset.zip
    rm 00.RawData/dataset.zip

Com `ls`você pode ver o conteúdo descarregado.

    ls 00.RawData

Por último “listou” (`ls`) o conteúdo da pasta `00.RawData`, vai
observar que têm 4 amostras paired-end (R1 e R2)

    Sample1_1.fq.gz Sample1_2.fq.gz Sample2_1.fq.gz Sample2_2.fq.gz Sample3_1.fq.gz Sample3_2.fq.gz Sample4_1.fq.gz Sample4_2.fq.gz Sample5_1.fq.gz Sample5_2.fq.gz Sample6_1.fq.gz Sample6_2.fq.gz

É fortemente recomendado rodar os comandos desde o diretório base, que
neste caso é: `binning/`

> ## **Nota importante: A maioria dos comandos que encontrará a continuação, terão um parâmetro para definir o número de núcleos/threads/cpus (`-t/--threads/`) que serão usados para o processamento de cada comando. Coloque o número de núcleos baseado na sua máquina o servidor que esteja usando para rodar as análises. Procure não usar todos os núcleos disponíveis.**

## 1. Controle de qualidade

## 1.1. Avaliação da qualidade

🇧🇷 Para a avaliação da qualidade será usado o programa
[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) que
é uma ferramenta que permite observar graficamente a qualidade das
sequencias de Illumina.

> 🇪🇸 Para la evaluación de la calidad será usado el programa
> [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
> que es una herramienta que permite observar graficamente la calidad de
> las secuencias de Illumina.

### 1.1.1. Instalação

Las instruções para a instalação usando conda se encontram
[aqui](https://anaconda.org/bioconda/fastqc). No entanto neste tutorial
também serão apresentados.

Como já foi explicado anteriormente, com conda é possível criar
ambientes virtuais para instalar as ferramentas bioinformáticas. O
primeiro ambiente que será criado se chamará **QualityControl**, onde se
instalaram os programas relacionados com esse processo.

> 🇪🇸 [FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
> es una herramienta para evaluar graficamente la calidad de las
> secuencias de Illumina.
>
> Las instrucciones para instalación usando conda se encuentran
> [aqui](https://anaconda.org/bioconda/fastqc). Sin embargo aqui en este
> tutorial también serán presentadas
>
> Como ya fue explicado anteriorimente, con conda es posible crear
> ambientes virutuales para instalar las herramientas bioinformáticas.
> El primer ambiente que será creado se llamará **QualityControl**,
> donde se instalaran los programas relacionados con este proceso.

    conda create -n QualityControl

🇧🇷 Durante o processo, o sistema perguntará se deseja proceder com a
creação do ambiente, com as opções y/n (sim ou não). Escreva `y` e
depois disso o ambiente virutal estará criado.

Para instalar as ferramentas dentro do ambiente anteriormente criado, é
necessário ativá-lo.

> 🇪🇸 Durante el proceso, el sistema preguntará sí desea proceder con la
> creación del ambiente, con las opciones y/n (si o no). Escriba `y` y
> después de eso el ambiente virtual estará creado.
>
> Para instalar las herramientas dentro del ambiente anteriormente
> creado, es necesario activarlo

    conda activate QualityControl

🇧🇷 O ambiente estará ativo quando o nome se encontre ao começo da linha
do comando, asssim: `(QualityControl) user@server:~/$`. Posteriormente
se procede à instalação do programa:

> 🇪🇸 El ambiente estará activo cuando el nombre de éste se encuentra en
> el comienzo de la linea de comando, así:
> `(QualityControl) user@server:~/$`.
>
> Posteriormente se procede a la instalación del programa:

    conda install -c bioconda fastqc

### 1.1.2. Uso

🇧🇷 A primeira etapa do processo é a avaliação da qualidade das
sequências cortas (Illumina paired end) usando *FastQC*, com o objetivo
de determianr se é necessário trimar ou filtrar as sequências da baixa
qualidade para nos próximos pasos.

Esta etapa é para identificar principalmente as sequências *outlier* com
baixa qualidade (*Q* &lt; 20)

Ative o ambiente `QualityControl`:

> 🇪🇸 La primera etapa del proceso es la evaluación de la calidad de las
> secuencias cortas (Illumina paired end) usando *FastQC*, con el
> objetivo de determinar sí es necesario trimar o filtrar las secuencias
> de baja calidad en los próximos pasos.
>
> Ésta etapa es para identificar principalmente las secuencias *outlier*
> con baja calidad (*Q* &lt; 20).
>
> Active el ambiente `QualityControl`:

    conda activate QualityControl

    ## Onde vc está?
    pwd

🇧🇷 Deve estar em `~/binning/`.. Se esse não é o resultado del comando
`pwd`, use o comando `cd` para chegar no diretório desejado.

> 🇪🇸 Debe estar em `~/binning/`. Si ese no es el resultado del comando
> `pwd`, use el comando `cd` para llegar en el directorio base.

Execute **FastQC**:

    ## Crie um directório para salvar o output do FastQC
    mkdir 01.FastqcReports
    ## Run usando 10 threads
    fastqc -t 10 00.RawData/* -o 01.FastqcReports/

**Sintaxe** `fastqc [opções] input -o output`

🇧🇷 O comando `fastqc` tem várias opções ou parâmetros, entre eles,
escolher o número de núcleos da máquina para rodar a análise, para este
exemplo `-t 10`. O input é o diretório que contem as sequências
`00.RawData/*`, o `*` indica ao sistema que pode analisar todos os
arquivos que estão dentro desse diretório. O output, indicado pelo
parâmtero `-o`, é o diretório onde se deseja que sejam guardados os
resultados da análise. A continuação se encontram uma explicação
detalhada de cada output gerado.

> 🇪🇸 El comando `fastqc` tiene varias opciones o parametros, entre
> ellas, escoger el número de núcleos de la máquina para correr el
> análisis, para este caso `-t 10`. El input es el directorio que
> contiene las secuencias `00.RawData/*`, el `*` indica al sistema que
> puede analizar todos los archivos que están dentro de ese directorio.
> El output, indicado por el parametro `-o`, es el directorio donde se
> desea que sean guardados los resultados del análisis. A continuación
> se encuentra una explicación detallada de cada output generado.

**Outputs**

🇧🇷

-   Reportes html `.html`: Aqui é possível ver toda informação de
    qualidade graficamente.

-   Zip files `.zip`: Aqui se encontram cada um dos gráficos de maneira
    separada. **IGNORE**

Descarregue os arquivos `html` e explore no seu *web browser*.

Observe as estatísticas básicas que se encontram na primeira tabela.
Alí, você pode saber quantas sequências tem, o tamanho e o %GC. O
gráfico mais importante para saber a quealidade das leituras, é o
primeiro, *Per base sequence quality*. Este gráfico é um boxplot com a
distribuição dos valores de qualidade *Phred Score* (eje y) em cada um
dos nucleotídeos das leituras (eje x). Se consideram sequências de
excelente qualidade quando o *Phred Score &gt; 30*. É norla que o pair 2
apresente uma qualidade um pouco inferior ao pair 1.

> 🇪🇸 Observe las estadísticas básicas que se encuentran en la primera
> tabla. Allí, ud puede saber cuantas secuencias tiene, el tamaño y el
> %GC. El gráfico más importante para saber la calidad de las lecturas
> es el primero, *Per base sequence quality*. Este gráfico es un boxblot
> con la distribución de los valores de calidad *Phred Score* (eje y) en
> cada uno de los nucleótidos de las lecturas (eje x). Se consideran
> secuencias de excelente calidad cuando el *Phred Score &gt; 30*. Es
> normal que el pair 2 presente una calidad un poco inferior al pair 1.

### 1.2. Trimagem

> 🇪🇸 1.2 Depuración

🇧🇷 [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) é um
programa pra filtrar (remover) leituras ou *reads* curtas de baixa
qualidade.

Trimmomatic tem vários parâmetros que podem ser considerados para
filtrar leituras com baixa qualidade. No presente tutorial usaremos
alguns deles. Se quiser saber que otros parâmetros e como funciona cada
um deles, consulte o
[manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf).

> 🇪🇸 [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) es un
> programa para filtrar (remover) lecturas o *reads* cortas de baja
> calidad.
>
> Trimmomatic tiene vários parametros que pueden ser considerados para
> filtrar lecturas con baja calidad. Aqui usaremos algunos. Si quiere
> saber que otros parametros y como funciona cada uno de ellos, consulte
> el
> [manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf).

### 1.2.1. Instalação

🇧🇷 Como se trata de uma ferramenta que participa dentro do processo de
control de qualidade, será instalada dentro do ambiente virtual
**QualityControl**.

> Como se trata de una herramienta que participa dentro del proceso de
> control de calidad, será instalada dentro del ambiente virtual
> **QualityControl**

    # Si no está activado el ambiente
    conda activate QualityControl

    # Instale Trimmomatic
    conda install -c bioconda trimmomatic

### 1.2.2. Uso

🇧🇷 Segundo foi avaliado no controle de qualidade, pode ser necessário
filtrar algumas leituras com qualidade baixa.

O programa Trimmomatic tem vários parâmetros que podem ser considerados
para filtrar reads com baixa qualidade. Aqui usaremos alguns. Se quer
saber que outros parâmetros e como funciona cada um deles, consulte o
[manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf).

Para os dados aqui analizados se usara a seguinte linha de comando:

> 🇪🇸 Según fue evaluado en el control de calidad, puede ser necesario
> filtrar algunas lecturas con calidad baja.
>
> El programa Trimmomatic tiene vários parametros que pueden ser
> considerados para filtrar lecturas con baja calidad. Aqui usaremos
> algunos. Si quiere saber que otros parametros y como funciona cada uno
> de ellos, consulte el
> [manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf).
>
> Para los datos aqui analizados se usará la siguiente linea de comando:

    # Activa o ambiente QualityControl
    conda activate QualityControl

    # Crie uma pasta para salvar as reads limpas
    mkdir 02.CleanData

    # Crie uma pasta para salvar as reads não pareadas
    mkdir unpaired

    # Corra Trimmomatic
    trimmomatic PE -threads 10 00.RawData/Sample1_1.fastq.gz 00.RawData/Sample1_2.fastq.gz 02.CleanData/Sample1_1_paired.fastq.gz unpaired/Sample1_1_unpaired.fastq.gz 02.CleanData/Sample1_2_paired.fastq.gz unpaired/Sample1_2_unpaired.fastq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:150

🇧🇷 Com o comando anterior você tem que rodar a linha de comando para
cada amostra. Se quiser rodar todas as amostras de maneira automâtica é
possível usar um *loop* `for` para executar esta tarefa.

> 🇪🇸 Con el comnado anterior ud tiene que correr esa línea de comando
> para cada muestra. Si quiere correr todas las muestras de manera
> automática es posible usar un *loop* `for` para ejecutrar esta tarea.

    # loop
    for i in 00.RawData/*1.fq.gz 
    do
    BASE=$(basename $i 1.fq.gz)
    trimmomatic PE -threads 10 $i  00.RawData/${BASE}2.fq.gz 02.CleanData/${BASE}1_paired.fq.gz unpaired/${BASE}1_unpaired.fq.gz 02.CleanData/${BASE}2_paired.fq.gz unpaired/${BASE}2_unpaired.fq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:100
    done

**Sintaxe**
`trimmomatic PE -threads input_forward input_reverse output_forward_paired output_forward_unpaired output_reverse_paired output_reverse_unpaired [opções]`

🇧🇷 O comando anterior tem muitas partes. Primeiro, o nome do comando é
`trimmomatic`, a continuação a opção `PE` indica para o programa que as
sequências que irão ser analisadas são de tipo *paired end*. Depois se
encontram os inputs, forward (pair1) e reverse (pair2). Depois estão os
outputs, sendo o primeiro, as sequências forward pareadas (limpas) e não
pareadas (“descartadas”) e depois igual para as sequências reverse. Por
último se encontram os parâmetros de filtragem. Para este caso usamos os
parâmetros `SLIDINGWINDOW`, `LEADING` e `TRAILING`. O primeiro de eles,
gera uma janela deslizante, que em este caso vai de 4 em 4 bases,
cálcula a média do *Phred Score* e se estiver por baixo de 15 essas
bases serão cortadas. `LEADING` corta bases do começo da leitura que
estejam por debaixo do *threshold* de qualidade, igualmente faz o
`TRAILING` mas no final das leituras. `MINLEN` elimina todas as reads
com tamanho menor ao informado. Trimmomatic tem muitos mais parâmetros
para customizar, veja no
[manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf).

Durante o processo de Trimmomatic, o programa vai imprimendo na tela a
porcentagem de sequências que sobreviveram na trimmagem. No caso do
dataset exemplo, em todas as amostras sobreviveram mais do 90% das
reads. No entanto é necessário avaliar a qualidade das sequências limpas
usando novamente FastQC.

> 🇪🇸 El comando anterior tiene muchas partes. Primero, el nombre del
> comando es `trimmomatic`, a continuación la opción `PE` indica para el
> programa que las secuencias que irán a ser analizadas son de tipo
> *paired end*. Después se encuentran los inputs, forward (pair1) y
> reverse (pair2). Después son los outputs, siendo primero las
> secuencias forward pareadas (limpias) y no pareadas (“descartadas”) y
> después las secuencias reverse. Por último se encuentran los
> parametros de filtrado. Para este caso usamos los parametros
> `SLIDINGWINDOW`, `LEADING` y `TRAILING`. El primero de ellos, genera
> una ventana deslizante, que en este caso va de 4 en 4 bases, cálcula
> el promedio del *Phred Score* y si está por debajo de 15 esas bases
> son cortadas. `LEADING` corta bases del comienzo de la lectura si
> están por debajo de *threshold* de calidad, lo mismo hace `TRAILING`
> pero al final de las lecturas. `MINLEN` elimina todas las lecturas con
> tamaño menor al informado. Trimmomatic tiene muchos más parámetros
> customizables, revise en el
> [manual](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf).
>
> Durante el proceso de Trimmomatic, eñ programa va ir imprimiendo en la
> pantalla el porcentaje de secuencias que sobrevivieron a la
> depuración. En el caso del dataset ejemplo, en todas las muestras
> sobrevivieron mas del 90% de las reads. Sin embargo, es necesario
> evaluar la calidad de las secuencias limpias usando nuevamente FastQC.

    fastqc -t 10 02.CleanData/* -o 01.FastqcReports/

Descarregue os arquivos `.html` das sequências pareadas
(i.e. `01.FastqcReports/Sample1_1_paired_fastqc.html` y
`01.FastqcReports/Sample1_2_paired_fastqc.html`).

A qualidade das amostras melhoraram sustancialmente, por tanto estão
prontas para serem usadas nas próximas etapas.

Faça uma tabela com o número de sequências antes e depois da trimagem
para calcular a porcentagem de *reads* que sobreveviveram ao processo.

> 🇪🇸 Haga una tabla con el número de secuencias antes y después de la
> depuración para calcular el porcentaje de *reads* que sobrevivieron al
> proceso.

### 1.3 Cobertura dos Metagenoma

🇧🇷 Além de limpar e trimar as sequências com baixa qualidade, é
necessário calcular a cobertura dos metagenomas.Este programa usa a
redundância de reads nos metagenomas para estimar a cobertura média e
prediz a quantidade de sequências que são requeridas para atingir o
*“nearly complete coverage”*, definida como  ≥ 95% ou  ≥ 99% de
cobertura média. A ferramenta [**NonPareil
v3.3.3**](https://nonpareil.readthedocs.io/en/latest/) será usada nesta
etapa.

> 🇪🇸 Además de limpiar y *trimar* las secuencias con baja calidad, es
> necesario calcular la cobertura de los metagenomas. Este programa usa
> la redundancia de las *reads* en los metagenomas para estimar la
> cobertura promedio y predice la cantidade de secuencias que son
> requeridas para conseguir el *“nearly complete coverage”*, definida
> como  ≥ 95% o  ≥ 99% de la cobertura promedio. La herramienta
> [**NonPareil v3.3.3**](https://nonpareil.readthedocs.io/en/latest/)
> será usada en esta etapa.

### 1.3.1. Instalação

🇧🇷 [NonPareil v3.3.3](https://nonpareil.readthedocs.io/en/latest/) é uma
ferramenta que será usada para o cálculo da cobertura dos metagenomas.
Devido a incompatibilidades com a versão do Python usado para escrever
esta ferramenta, ela será instalada em um ambiente diferente ao de
controle de qualidade, chamado **NonPareil**.

> 🇪🇸 [NonPareil](https://nonpareil.readthedocs.io/en/latest/) es una
> herramienta que será usada para el cálculo de la cobertura de los
> metagenomas. Debido a incompatibilidades con la versión de Python
> usado para escribir esta herramienta, será instalada en un ambiente
> diferente al de control de calidad, llamado **NonPareil**.

    # Crie o ambiente
    conda create -n NonPareil

    # Instale NonPareil
    conda install -c bioconda nonpareil

### 1.3.2. Uso

Como *input* para esta análise só é necessário um pair de cada amostra,
e deve estar sem compressão.

    # Crie o diretório pra o output
    mkdir 03.NonPareil

    # entre no directorio
    cd 03.NonPareil

    # Copie os pair 1 da pasta 02.CleanData

    cp ../02.CleanData/*_1* ./

    # Descomprimir 
    gunzip -d *

🇧🇷 Agora está tudo pronto para rodar a análise, mas antes disso tome-se
o tempo para entender o comando que vai usar. Para conhecer que é cada
um dos argumentos, explore o menú de ajuda da ferramenta.

> 🇪🇸 Ahora está todo listo para correr el análisis, pero antes de eso
> tómese el tiempo para entender el comando que va a usar. Para conocer
> que es cada uno de los argumentos, explore el menú de ayuda de la
> herramienta.

    # Ative o ambiente NonPareil
    conda activate NonPareil

    # Explore o menú da ferramenta
    nonpareil --help

    # Comando do NonPareil para cada amostra
     nonpareil -s sample1.fq -T kmer -f fastq -b sample1 -t 10 &

No caso, se tiver várias amostras pode usar o seguinte loop para
facilitar o processo.

    for i in ./*.fq
    do
    BASE=$(basename $i .fq)
    nonpareil -s $i -T kmer -f fastq -b $i -t 10
    done

**Sintaxe**

-   `-s`: caminho para o *input*
-   `-T`: algorítmo a ser usado. `kmer` é recomendado para arquivos
    `.fastq` e `alignment` é recomendado para arquivos `.fasta`.
-   `-f`: indique aqui o formato do input (p.e. `fastq` ou `fasta`)
-   `-b`: prefixo para os *outputs*
-   `-t`: número de threads

🇧🇷 Ao terminar esse processo, o programa terá criado varios
[*outputs*](https://nonpareil.readthedocs.io/en/latest/redundancy.html#output)
por cada amostra. Descarregue os arquivos `.npo`. Os quais são tabelas
delimitadas por tabulações com seis colunas. A primeira coluna indica o
esforço de sequenciamento (em número de reads), as demais colunas têm
informação sobre a distribuição da redundância a determinado esforço de
sequenciamento. Usando os arquivos `.npo` e o R, pode gráficar as curvas
de saturação. A continuação se encontra o script. Além dos arquivos
`.npo` é necessário criar um arquivo chamado `samples.txt`, o qual deve
ter três colunas (separadas por tabulações), a primeira terá o nome de
cada arquivo `.npo`, a segunda o nome da amostra, e a terceira a cor em
formato JSON que vai ser usada para a curva. A continuação se encontram
uma série de comandos no bash para gerar o arquivo, no entanto este
arquivo pode ser construido em um bloco de notas, ou incluso no excel.

> 🇪🇸 Al terminar este proceso, el programa habrá creado varios
> [*outputs*](https://nonpareil.readthedocs.io/en/latest/redundancy.html#output)
> por cada muestra. Descargue los archivos `.npo`. Los cuales son tablas
> delimitadas por tabulaciones con seis columnas. La primera columna
> indica el esfuerzo de secuenciación (en número de *reads*), las demás
> columnas tienen información sobre la distribución de la redundancia a
> determinao esfuerzo de secuenciación. Usando los archivos `.npo` e R,
> puede gráficar las curvas de saturación. A continuación se encuentra
> el script.
>
> Además de los archivos `.npo` es necesario crear un archivo llamado
> `samples.txt`, el cual debe tener tres columnas (separadas por
> tabulaciones), la primera tendrá el nombre de cada archivo `.npo`, la
> segunda el nombre de la muestra, y la tercera el color en formato JSON
> que va a ser usado para la curva. A continuación se encontran una
> serie de comandos en bash para generar el archivo, sin embargo, este
> archivo puede ser construido en un bloc de notas, o incluso en excel.

    # Cria um arquivo com os nomes dos arquivos
    ls *.npo > files.txt

    # Cria um arquivo com os nomes das amostras

    ls *.npo | sed 's/_1_paired.fq.npo//g' > prefix.txt

Agora precisa criar uma lista de cores para diferenciar suas amostras no
gráfico. Use o site [IWantHue](http://medialab.github.io/iwanthue/) para
criar uma paleta com o número de cores igual ao númerop de amostras.
Copie os códigos **HEX json** das cores e coloque dentro de um arquivo
(elimine as vírgulas):

> 🇪🇸 Ahora necesita crear una lista de colores para diferencias sus
> muestras en el gráfico. Use el sitio de internet
> [IWantHue](http://medialab.github.io/iwanthue/) para crear una paleta
> con el número de colores igual al número de muestras. Copie los
> códigos **HEX json** de los colores e coloque dentro de un archivo
> (elimine las comas):

    # Crie o arquivo
    nano colors.txt

    # Copie e cole os códigos
    "#c151b6"
    "#5eb04d"
    "#7d65ce"
    "#b5b246"

Cree o arquivo final com os títulos de las columnas e una los três
arquivos gerados anteriormente:

    echo -e 'File\tName\tCol' > samples.txt

    # Unindo os arquivos dentro de samples.txt
    paste -d'\t' files.txt prefix.txt colors.txt >> samples.txt

Use `less` para explorar o arquivo, ele deve se ver assim:

    File    Name    Col
    Sample1.npo   Sample1   "#c151b6"
    Sample2.npo   Sample2   "#5eb04d"
    Sample3.npo   Sample3   "#7d65ce"
    Sample4.npo   Sample4   "#b5b246"
    Sample5.npo   Sample5   "#c75a87"
    Sample6.npo   Sample6   "#648ace"

Descarregue os arquivos `.npo` e o arquivo `samples.txt`. Usando o
seguinte script do R, grafique as curvas de saturação. **Nota:** todos
os arquivos descarregados devem estar dentro de uma pasta só, p.e.
`03.NonPareil`.

Descarregue o script
[Nonpareil](https://github.com/khidalgo85/Binning/blob/master/nonpareil.R)

``` r
install.packages("Nonpareil") #para instalar o pacote
library(Nonpareil) # ativa o pacote
setwd("~/03.NonPareil") # determina seu diretório de trabalho (coloque o seu, onde colocou os arquivos .npo e o arquivo samples.txt)

samples <- read.table('samples.txt', sep='\t', header=TRUE, as.is=TRUE); #lê o arquivo samples.txt com a informação das amostras

attach(samples);
nps <- Nonpareil.set(File, col=Col, labels=Name, 
                     plot.opts=list(plot.observed=FALSE, 
                                    ylim = c(0, 1.05),
                                    legend.opts = FALSE)) #grafica as curvas

Nonpareil.legend(nps, x.intersp=0.5, y.intersp=0.7, pt.cex=0.5, cex=0.5) #coloca e personaliza a legenda
  
detach(samples);
summary(nps) #mostra o resumo em forma de tabela
```

Vai obter um gráfico com as curvas de saturação de cada amostra, como
este:

<img src="imgs/nonpareil.png" align='center' width="80%">

🇧🇷 As linhas tracejadas <font color='red'> vermelha </font> e
<font color='gray'> cinza </font> representam os *threshold* de 95% e
99% da cobertura média, respeitivamente. O circulo em cada curva
representa a cobertura atual das amostras, o ideal é que esteja por cima
do primeiro *threshold*. As curvas também apresentam a estimação de
quanto esforço de sequenciamento é necessário (zetas no eixo x). Devido
a que se trata de um dataset exemplo que foi obtido apartir de um
subsample aleatorio de um conjunto de dados, a maioria das amostras não
conseguem uma boa cobertura. As curvas reais para as amostras originais
se apresentam a continuação:

> 🇪🇸 Las líneas punteadas <font color='red'> roja </font> y
> <font color='gray'> gris </font> representam los *threshold* de 95% y
> 99% de cobertura promedio, respectivamente. El círculo en cada curva
> representa la cobertura actual de las muestras, lo ideal es que estén
> por encima del primer *threshold*. Las curvas también presentan la
> estimación de cuanto esfuerzo de secuenciación es necesario (flechas
> en el eje x). Debido a que se trata de un dataset ejemplo que fue
> obtenido a partir de un subsample aleatorio de un conjunto de datos,
> la mayoria de las muestras no consiguen una buena cobertura. Las
> curvas reales para las muestras originais se presentan a continuación:

<img src="imgs/realnonpareil.png" align='center' width="80%">

### 1.4. Análise de Distâncias MinHash

🇧🇷 Após obter as sequências limpas, de boa qualidade, e determinar a
cobertura dos metagenomas, é possível fazer a montagem. No entanto, pode
ser incluído um passo extra antes da montagem e é verificar a
similaridade dos datasets para determinar se pode ser usada a abordagem
de *co-assembly*, onde são misturadas as *reads* de vários metagenomas
para gerar os contigs. O programa [**Mash
v2.3**](https://mash.readthedocs.io/en/latest/) usa uma técnica chamada
redução de dimensionalidad *MinHash* que avalia as distâncias um a um
entre os datasets.

> 🇪🇸 Después de obtener las secuencias limpias, de buena calidad, y
> determinar la cobertura de los metagenomas, es posible hacer el
> montaje. Sin embargo, puede ser incluído un paso extra antes del
> montaje y es verificar la similaridade de los datasets para determinar
> si puede ser usado el abordaje de *co-assembly*, donde son mezcladas
> las *reads* de varios metagenomas para generar los contigs. El
> programa [**Mash v2.3**](https://mash.readthedocs.io/en/latest/) usa
> una técnica llamada reducción de dimensionalidad *MinHash* que evalua
> las distancias un a un entre los datasets.

### 1.4.1. Instalação

🇧🇷 [Mash v2.3](https://mash.readthedocs.io/en/latest/) é uma ferramenta
que usa a técnica de redução da dimensionalidade *MinHash* para calcular
as distâncias um a um entre os datasets, assim, é possível determinar se
os metagenomas são similares ou não para serem montados usando
*co-assembly*.

🇧🇷 Por ser considerada uma ferramenta que participa no processo de
assembly, será instalada dentro de um ambiente virtual chamado
**Assembly**.

> 🇪🇸 [Mash](https://mash.readthedocs.io/en/latest/) es una herramienta
> que usa la técnica de reducción de dimensionalidad *MinHash* para
> calcular las distancias un a un entre los datasets, así, es posible
> determinar si los metagenomas son similares o no para ser ensamblados
> usando *co-assembly*.
>
> 🇪🇸 Por ser considera una herramienta que participa en el proceso de
> ensamble, será instalada dentro de un ambiente virtual llamado
> **Assebly**.

    # Crie o ambiente virtual
    conda create -n Assembly

    # Instale Mash
    conda install -c bioconda mash

### 1.4.2. Uso

    ## Crie uma pasta para o output
    mkdir 04.MinHash

🇧🇷 O primeiro paso é concatenar os reads 1 e 2, e armazenar eles na nova
pasta criada `04.MinHash/`.

**Nota:** Se você trimou suas sequências, deve usar os arquivos gerados
pelo **Trimmomatic** na pasta `02.CleanData`, se pelo contrário suas
sequências estavam de boa qualidade e não foi necessário trimar, use os
arquivos originais, que estão dentro da pasta `00.RawData/`.

> 🇪🇸
>
> **Nota:** Si usted filtró sus secuencias, debe usar los archivos
> generados por **Trimmomatic** en el directorio `02.CleanData`, si por
> el contrario sus secuencias estaban de buena calidade y no fue
> necesario filtrar, use los archivos originales, que están dentro de la
> carpeta `00.RawData`.

    for i in 02.CleanData/*_1_paired.fq.gz
    do
    BASE=$(basename $i _1_paired.fq.gz)
    cat $i 02.CleanData/${BASE}_2_paired.fastq.gz > 04.MinHash/${BASE}.fq
    done

🇧🇷 Depois será criado um *sketch* para combinar todas as amostras.
Usando `mash info` pode verificar o conteúdo e, em seguida, estimar as
distâncias par a par:

> 🇪🇸
>
> Después será creado un *sketch* para combinar todas las muestras.
> Usando `mash info` puede verificar el contenido y, en seguida, estimar
> las distancias par a par:

    mash sketch -o 04.MinHash/reference 04.MinHash/sample1.fq 04.MinHash/sample2.fq 04.MinHash/sample3.fq 04.MinHash/sample4.fq 04.MinHash/sample5.fq 04.MinHash/sample6.fq

    #verifiyng
    mash info 04.MinHash/reference.msh

**Sintaxe**

`mash sketch -o reference [inputs]`

`mash info reference.msh`

-   `sketch`: Comando para criar um *sketch*, combinando todas as
    amostras, recomendado quando têm mais de três amostras.
-   `-o`: caminho pro *output*, criará um *sketch* `.msh`.
-   `inputs`: liste os inputs (sequencias concatenadas dos pair1 e
    pair2)
-   `info`: pode verificar o conteúdo do `sketch`
-   `reference.msh`: *sketch* criado

Por último, calcule as distâncias entre cada par de metagenomas usando
`mash dist` e salve o resultado no arquivo `distancesOutput.tsv`.

    mash dist 04.MinHash/reference.msh 04.MinHash/reference.msh -p 6 -t > 04.MinHash/distancesOutputFinal.tsv

**Sintaxe** `mash dist [reference] [query] [options]`

-   `dist`: comando para calcular as distâncias entre cada par de
    mategenomas, baseado na distância *MinHash*.
-   `reference`: aqui pode colocar o *sketch* criado, ou arquivos `.fq`,
    `fasta`.
-   `query`: ídem
-   `-p`: número de threads
-   `-t`: indica o tipo de formato de matriz

Descarregue o output (`04.MinHash/distancesOutputFinal.tsv`) e use o
seguinte script do R para plotar um heatmap com as distâncias.

Descarregue o script para graficar o heatmap das distancias
[MinHash](https://github.com/khidalgo85/Binning/blob/master/minhash.R)

``` r
setwd("~/04.MinHash/")

# install.packages('dplyr')
library(dplyr)
# install.packages('stringr')
library(stringr)
# install.packages('tidyverse')
library(tidyverse)

data <- read.table("distancesOutputFinal.tsv", comment.char = '', 
                    header = TRUE ) %>% 
  rename(X = X.query) 
  

data$X <- str_remove_all(data$X, "04.MinHash/")
data$X <- str_remove_all(data$X, ".fq")

names <- c("X", data[,1])

colnames(data) <- names

data <- column_to_rownames(data, var="X")

library(pheatmap)


pheatmap(data)
```

Vai obter um heatmap com clusterização:

<img src="imgs/minhash.png" align='center' width="80%">

Como pode ser observado, se formaram vários clusters, por exemplo
Sample5, Sample4 e Sample1, Sample3 e 2, e Sample6 formou um cluster
aparte. Assim, poderiam ser feitos dois co-assemblies e um assembly
individual. No entanto para facilitar o processo no tutorial, será feito
um co-assembly só, com todas as amostras.

## 2. Montagem dos Metagenomas

🇧🇷 A montagem dos metagenomas é a etapa mais importante do processo,
porque os demais passos para adelante dependen de uma boa montagem. No
caso dos metagenomas, se trata de um proceso que não é para nada
trivial, requer um grande esforço computacional. Por este motivo, serão
testados vários parâmetros, para comparar cada montagem e decidir qual é
o melhor para ás análises *downstream*. Neste processo será usado o
montador [Spades v3.15.3](https://github.com/ablab/spades).

> 🇪🇸 El montaje de los metagenomas es la etapa más importante del
> proceso, porque los demás pasos para adelante dependen de un buen
> ensamble. En el caso de los metagenomas, se trata de un proceso que no
> es para nada trivial, requiere un gran esfuerzo computacional. Por
> este motivo serán testados varios parámetros, para comparar cada
> ensamble y decidir cual es el mejor para los análisis *downstream*. En
> este proceso será usado el montado [Spades
> v3.15.3](https://github.com/ablab/spades).

### 2.1. Instalação

🇧🇷 [Spades v3.15.3](https://github.com/ablab/spades) é um dos montadores
de genomas e metagenomas, mais conhecido e com melhores resultados, pode
ser usado tanto para leituras curtas como longas. Leia atentamente o
[manual](http://cab.spbu.ru/files/release3.15.2/manual.html), já que
este programa tem muitas opções diferentes. Spades usa o algorítmo do
*Grafo de Bruijn* para a montagem das secuências.

Siga as seguintes instruções para a instalação do **Spades** dentro do
ambiente virtual *Assembly*.

> 🇪🇸 [Spades v3.15.3](https://github.com/ablab/spades) es uno de los
> ensambladores de genomas y metagenomas, más conocido y con mejores
> resultados, puede ser usado tanto para lecturas cortas como largas.
> Lea atentamente el
> [manual](http://cab.spbu.ru/files/release3.15.2/manual.html), ya que
> este programa tiene muchas opciones diferentes. Spades usa el
> algorítmo del *Grafo de Bruijn* para el montaje de las secuencias.
>
> Siga las siguientes instrucciones para la instalación de **Spades**
> dentro del ambiente virtual *Assembly*.

    # Active el ambiente virtual
    conda activate Assembly

    # Instale Spades
    conda install -c bioconda spades

### 2.2. Uso

🇧🇷 Agora é momento de fazer as montagens. Use o resultado da análisis de
distâncias *MinHash* para decidir como serão feitos as montagens.
Amostras muito próximas pode fazer *co-assembly*, para amostras
distantes é recomendado montar individualmente. Opcionalmente podem ser
usadas as sequências no pareadas (sequências “descartadas” pelo
Trimmomatic). O montador usado neste método será
[Spades](https://github.com/ablab/spades).

A continuação se encontram os comandos se sua **montagem for
individual** (não é o caso das amostras do tutorial, veja mais para
frente):

> 🇪🇸 Ahora es el momento de hacer los ensamblajes. Use el resultado del
> análisis de distancias *MinHash* para decidir como serán hechos los
> montajes. Muestras muy próxima puede hacer *co-assembly*, para
> muestras distantes es recomendado montar individualmente.
> Opcionalmente pueden ser las secuencias no pareadas (secuencias
> “descartadas” por Trimmomatic). El montador usado en este método será
> [Spades](https://github.com/ablab/spades).

> A continuación se encuentran los comandos si su **ensamble fuera
> individual** (no es el caso de las muestras de este tutorial, vea más
> adelante)

1.  Criar um diretório para todas as montagens

<!-- -->

    mkdir 05.Assembly

2.  Se você quiser usar as *reads* no pareadas (saída do
    **Trimmomatic**), deve primeiro concatenarlas em um arquivo só

<!-- -->

    cat unpaired/Sample1_1_unpaired.fq.gz unpaired/Sample1_2_unpaired.fq.gz > unpaired/Sample1_12_unpaired.fq.gz

3.  Montagem com MetaSpades

<!-- -->

    metaspades.py -o 05.Assembly/Sample1/ -1 02.CleanData/Sample1_1_paired.fq.gz -2 02.CleanData/Sample1_2_paired.fq.gz -s unpaired/Sample1_12_unpaired.fq.gz -t 10 -m 100 -k 21,29,39,59,79,99,119

**Sintaxe**

-   `metaspades.py`: t para montar metagenomas
-   `-o`: caminho para diretório de saída
-   `-1`: caminho para diretório do pair1
-   `-2`: caminho para diretório do pair2
-   `-s`: caminho para diretório das *reads* no pareadas
-   `-t`: número de threads
-   `-m`: Memória em gigas (máximo)
-   `-k`: lista de *k-mers*

🇧🇷 No caso particular das amostras deste tutorial, serão montadas em um
co-assembly só. Por tanto siga as seguintes instruções:

Se sua montagem for no modo *co-assembly* deve fazer uma etapa anterior,
onde vai concatenar todos os pair1 das amostras que serão montadas e
todos os pair2 das mesmas.

> 🇪🇸 En el caso particular, las muestras de este tutorial, serán
> montadas en un solo co-assembly. Por lo tanto siga las siguientes
> instrucciones: Si su ensamblaje es en el modo *co-assembly* debe hacer
> una etapa anterior, donde va a concatenar todos los pair1 de las
> muestras que serán montadas y todos los pair2 de las mismas.

1.  Concatene os pair 1

<!-- -->

    cat 02.CleanData/Sample1_1.fq.gz 02.CleanData/Sample2_1.fq.gz 02.CleanData/Sample3_1.fq.gz 02.CleanData/Sample4_1.fq.gz 02.CleanData/Sample5_1.fq.gz 02.CleanData/Sample6_1.fq.gz > 02.CleanData/Sample_all_1.fq.gz

2.  Concatene os pair 2

<!-- -->

    cat 02.CleanData/Sample1_2.fq.gz 02.CleanData/Sample2_2.fq.gz 02.CleanData/Sample3_2.fq.gz 02.CleanData/Sample4_2.fq.gz 02.CleanData/Sample5_2.fq.gz 02.CleanData/Sample6_2.fq.gz > 02.CleanData/Sample_all_2.fq.gz

3.  Se você quiser usar as *reads* no pareadas (saída do
    **Trimmomatic**), deve primeiro concatenarlas em um arquivo só

<!-- -->

    cat unpaired/Sample1_1_unpaired.fq.gz unpaired/Sample1_2_unpaired.fq.gz unpaired/Sample2_1_unpaired.fq.gz unpaired/Sample2_2_unpaired.fq.gz unpaired/Sample3_1_unpaired.fq.gz unpaired/Sample3_2_unpaired.fq.gz unpaired/Sample4_1_unpaired.fq.gz unpaired/Sample4_2_unpaired.fq.gz unpaired/Sample5_1_unpaired.fq.gz unpaired/Sample5_2_unpaired.fq.gz unpaired/Sample6_1_unpaired.fq.gz unpaired/Sample6_2_unpaired.fq.gz > unpaired/Sample_all_unpaired.fq.gz

4.  Montagem com MetaSpades

<!-- -->

    metaspades.py -o 05.Assembly/ -1 02.CleanData/Sample_all_1.fq.gz -2 02.CleanData/Sample_all_2.fq.gz-s unpaired/Sample_all_unpaired.fq.gz -t 10 -m 100 -k 21,29,39,59,79,99,119

**Outputs**

Para conhecer os demais parâmetros do comando que não foram modificados
(usados por *default*), consulte o
[manual](http://cab.spbu.ru/files/release3.15.2/manual.html).

-   `corrected/`: contém as reads corregidas por **BayesHammer** em
    `.fastq.gz`

-   `scaffolds.fasta`: contém os scaffolds obtidos

-   `contigs.fasta`: contém os contigis obtidos

-   `assembly_graph_with_scaffolds.gfa`: contém o grafo da montagem en
    formato GFA 1.0.

-   `assembly_graph.fastg`: contém o grafo da montagem em formato FASTG

## 3. Controle de Qualidade das montagens

🇧🇷 Para avaliar a qualidade das montagens será usada a ferramenta
[**Quast v5.0.2**](http://quast.sourceforge.net/docs/manual.html)
(*QUality ASsesment Tool*), especificamente o *script* `metaquast.py`,
com o qual é possível determinar as principais estatísticas da montagem
(i.e. N50, número de contigs, tamanho total da montagem, tamanho dos
contigs, etc). **Metaquast** gera uma série de arquivos e reportes onde
é possível observar essas estatísticas básicas da montagem. É uma
ferramente muito útil para comparar montagens e escolher a melhor pro
mesmo conjunto de dados.

> 🇪🇸 Para evaluar la calidad de los montajes será usada la herramienta
> [**Quast v5.0.2**](http://quast.sourceforge.net/docs/manual.html)
> (*QUality ASsesment Tool*), especificamente el *script*
> `metaquast.py`, con el cual es posible determinar las principales
> estadísticas del montaje (i.e. N50, número de contigs, tamaño total
> del montaje, tamaño de los contigs, etc). **Metaquast** genera una
> serie de archivos y reportes donde es posible observar esas
> estadísticas básicas del montaje. Es una herramienta muy útil para
> comparar monatajes y escoger el mejor del mismo conjunto de datos.

### 3.1. Instalação

Crie um novo ambiente virtual, chamado bioinfo, onde se instalará
**Quast**.

    # Crie o ambiente
    conda create -n bioinfo

    # Ative o ambiente bioinfo
    conda activate bioinfo

    # Instale Quast
    conda install -c bioconda quast

### 3.2. Uso

🇧🇷 Se você tiver várias montagens e quer comparar todas é necessário
trocar os nomes dos assemblies, já que eles tem todos o mesmo nome,
`contigs.fasta` ou `scaffolds.fasta`. Use o comando `mv` para trocar os
nomes. Siga o seguinte exemplo:

> 🇪🇸 Si usted tiene varios ensambles e quiere compararlos es necesario
> cambiar los nombres de los montajes, ya que todos tienen el mismo
> nombre, `contigs.fasta` ou `scaffolds.fasta`. Use el comando `mv` para
> cambiar los nombres. Siga el siguiente ejemplo:

Por exemplo:

    mv 05.Assembly/sample1/scaffolds.fasta 05.Assembly/sample1/sample1.fasta

    mv 05.Assembly/sample45/scaffolds.fasta 05.Assembly/sample45/sample45.fasta

Para as amostras deste tutorial não é necessário trocar os nomes porque
só é uma montagem:

    # Crie um diretório pro output
    mkdir 06.AssemblyQuality

    # Rode Quast
    metaquast.py 05.Assembly/scaffolds.fasta -o 06.AssemblyQuality/ --threads 10

**Sintaxis**
`metaquast.py path/to/assembly/contigs.fasta -o path/to/output/`

-   Pode colocar vários inputs (montagens) separados por espaço.

**Interpretação dos resultados**

🇧🇷 A ideia de usar **Metaquast**, a parte de avaliar as estatísticas
básicas das montagens, é comparar varias montagens para escolher a
melhor. Por exemplo: entre menor seja o número de contigs é melhor,
porque significa que a montagem está menos fragmentada. E isso será
refletido no tamanho dos contigs que serão maiores. O valor de N50, é
melhor entre maior seja. Além, também é ideal um menor número de gaps e
Ns. No entanto, estas estatísticas funcionam melhor para genomas que
para metagenomas, por se tratar de um conjunto de microrganismos.

> 🇪🇸 La idea de usar **Metaquast**, aparte de evaluar las estidísticas
> básicas de los montajes, es comparar varios montajes para escoger el
> mejor. Por ejemplo: entre menor sea el número de contigs es mejor,
> porque significa que el montaje está menos fragementado. Y eso se
> reflejará en el tamaño de los contigs que serán más grandes. El valor
> de N50, es mejor entre mayor sea. Así mismo, es ideal menor número de
> gaps y Ns. Sin embargo, éstas estadísticas funcionan mejor para
> genomas que para metagenomas, por tratarse de un grupo de
> microorganismos.

**Outputs**

Explore o diretório do output usando o comando `ls`.

-   `06.AssemblyQuality/report.html`: Este relatório pode ser aberto em
    um *web browser* e contem as informações mais relevantes. Como
    número de contigs, tamanho del maior contig, tamanho total da
    montagem, N50, etc.

> 🇪🇸 `06.AssemblyQuality/report.html`: reporte puede ser abierto en un
> *web browser* y contiene las informaciones más relevantes. Como número
> de contigs, tamaño del mayor contig, tamaño total del montaje, N50,
> etc.

-   `06.AssemblyQuality/report.tex`, `06.AssemblyQuality/report.txt`,
    `06.AssemblyQuality/report.tsv`, `06.AssemblyQuality/report.pdf`: é
    o mesmo relatório porém em diferentes formatos.

-   `06.AssemblyQuality/transposed_report.tsv`,
    `06.AssemblyQuality/transposed_report.tex`,
    `06.AssemblyQuality/transposed_report.tex`: Também é o relatório
    porém em formato tabular.

-   `06.AssemblyQuality/icarus_viewers/contig_size_viewer.html`:
    Visualizador das contigs

-   `06.AssemblyQuality/basis_stats/`: Dentro desta pasta se encontram
    vários gráficos em formato `.pdf`.

## 4. Mapping

Agora é necessário fazer o mapeamento das reads originais dentro do
co-assembly para obter informações de cobertura (número de vezes que um
fragmento é sequênciado) para cada contig em cada amostra. O programa
[Bowtie2](https://github.com/BenLangmead/bowtie2) é o elegido para esta
tarefa.

> 🇪🇸 Ahora es necesario hacer el mapeamiento de las reds dentro del
> co-assembly para obtener las informaciones de cobertura (número de
> veces que un fragmento es secuenciado) para cada contig en cada
> muestra. El programa [Bowtie2](https://github.com/BenLangmead/bowtie2)
> es el elegido para esta tarea.

### 4.1. Instalação

#### 4.1.1. Bowtie2

Crie um novo ambiente virtual, chamado mapping, onde se instalará
**Bowtie2**.

    # Crie o ambiente
    conda create -n mapping

    # Ative o ambiente mapping
    conda activate mapping

    # Instale Bowtie2
    conda install -c bioconda bowtie2

#### 4.1.2. Samtools

Para a manipulaçao dos arquivos usaremos
[Samtools](https://github.com/samtools/samtools).

    # Crie o ambiente
    conda create -n mapping

    # Ative o ambiente samtools
    conda activate samtools

    # Instale Samtools
    conda install -c bioconda samtools=1.9

### 4.2. Uso

Após instaldo, crie uma pasta para armazenar a saída do mapeamento

    mkdir 07.Mapping

O primeiro passo do mapeamento é criar um índice de nosso co-assembly

    # Ative o ambiente mapping
    conda activate mapping

     bowtie2-build 05.Assembly/scaffolds.fasta 07.Mapping/final_assembly_DB

Agora vamos a mapear as reads das amostras individuais no co-assembly. O
processo pode ser feito amostra por amostra, ou podemos usar um loop
para fazer todas as amostras ao mesmo tempo. **Cuidado:** Fique atento a
nome de suas amostras, e se for necessário modifique o comando, para que
se ajuste as suas amostras. &gt; 🇪🇸 Ahora vamos a mapear las reads de
las muestras individuales en el co-assembly. El proceso puede ser hecho
muestra por muestra, o puede ser usado un loop para hacer todas las
muestras al mismo tiempo. **Cuidado:** Esté atento al nombre de sus
muestras, y si es necesario modifique el comando, para que se ajuste a
sus muestras.

    for i in 02.CleanData/*_1_paired.fq.gz
    do
    BASE=$(basename $i _1_paired.fq.gz)
    bowtie2 -q -1 $i -2 02.CleanData/${BASE}2_paired.fq.gz -x 07.Mapping/final_assembly_DB -p 10 -S 07.Mapping/${BASE}.sam
    done

A linha de comando para cada amostra é:

    bowtie2 -q -1 02.CleanData/Sample1_1.fq.gz -2 02.CleanData/Sample1_2.fq.gz -x 07.Mapping/final_assembly_DB -p 10 -S 07.Mapping/Sample1.sam

Agora é necessário converter os arquivos `.sam` para `.bam`. Também será
feito o comando usando um loop

    # Ative o ambiente Samtools
    conda activate samtools

    cd 07.Mapping/
    for f in *.sam; do filename="${f%%.*}"; samtools view -@ 10 $f -b > ${filename}.bam; done

O comando individual é:

    samtools view -b -o 06.Mapping/sample1.bam 06.Mapping/sample1.sam

Após transformar em arquivo `.bam`, devem ser ordenados.

    for f in *.bam; do filename="${f%%.*}"; samtools sort -@ 10 $f > ${filename}.sorted.bam; done

    ls ## conferir que estejam os arquivos

E por úlitmo os arquivos vão ser indexados

    # loop
    for f in *.sorted.bam; do filename="${f%%.*}"; samtools index -@ 10 $f > ${filename}.index.bam; done

    # Comando individual
    samtools index -@ 10 sample1.sorted.bam sample1.index.bam

    ## para voltar na pasta raiz binning/
    cd ..

## 6. Binning

Para a reconstrução dos genomas, serão usadas várias ferramentas para
ter um número maior de MAGs recuperados.

> 🇪🇸 Para la reconstrucción de los genomas, serán usadas varias
> herramientas para ter un número mayor de MAGs recuperados.

### 6.1. MetaBat2

#### 6.1.1 Instalação

Para a instalação de algumas ferramentas de binning, será criado um
ambiente chamado **Binning**.

    # Cria o ambiente
    conda create -n Binning

    # Ativa o ambiente Binning
    conda activate Binning

    # Instala Metabat2
    conda install -c bioconda metabat2

#### 6.1.2. Uso

Crie uma pasta para armazenar a saída do processamento em *MetaBat2*

    mkdir 08.MetaBat2

Usando os arquivos ordenados `.sorted.bam` vai gerar um arquivo `.txt`
com a informação da cobertura, necessária para a recuperação dos
genomas. Como sempre lembrando que precisa ativar o ambiente onde se
encontra instalado o *MetaBat2*

> 🇪🇸 Usando los archivos ordenados `.sorted.bam` va a ser generado un
> archivo `.txt` con la información de cobertura necesaria para la
> recuperación de los genomas. Como siempre, recuerde que necesita
> activar el ambiente donde se encuentra instalado el *Metabat2*

    jgi_summarize_bam_contig_depths --outputDepth 08.MetaBat2/Depth.txt 07.Mapping/*sorted.bam

O *MetaBat2* tem vários parâmetros para customizar, o tamanho minimo de
contig é o mais comum de ser modificado. Neste pipeline você vai
encontrar três rodadas com *MetaBat2* com diferentes tamanhos minimos de
contigs.

> 🇪🇸 *Metabat2* tiene varios parámetros para personalizar, el tamaño
> mínimo de contig es el más común de ser modificado. En este pipeline
> ud va a encontrar tres corridas con *Metabat2* con diferentes tamaños
> mínimos de contigs.

**First Trial**

Crie um diretório dentro da pasta `08.MetaBat2` chamado `01.FirstTrial`

    mkdir 08.MetaBat2/01.FirstTrial

Para este primeiro trial o tamanho minimo de contig será de 1500

     metabat2 -i 05.Assembly/scaffolds.fasta -a 08.MetaBat2/Depth.txt -m 1500 -t 10 -o 08.MetaBat2/01.FirstTrial/metabat2_first_

Para o segundo trial o tamanho minimo de contig será de 2500, que é o
default da ferramenta, por isso não precisa colocar o flag `-m`.

    mkdir 08.MetaBat2/02.SecondTrial

    metabat2 -i 05.Assembly/scaffolds.fasta -a 08.MetaBat2/Depth.txt -t 10 -o 08.MetaBat2/02.SecondTrial/metabat2_second_

Por último, para terceira rodada, serão modificados mais parâmetros.
Para conhecer todos os paråmetros que podem ser customizados, digite o
comando `metabat2 --help`. Com o flag `-m` ou `--minContig`, como já foi
usado nas rodadas anteriores é possível modificar o tamanho mínimo dos
contigs, para este caso será usado 3000. Com o flag `--maxEdges`,
pode-se modificar o máximo número de *edges* (arestas) por nó. Entre
maior seja o número, o algoritmo é mais sensitivo. O default é 200, vai
ser usado 500. O flag `--minS` modifica o socre mínimo de cada *edge*,
entre maior seja é mais específico. O default é 60, vai ser usado 80.
Então o comando é o seguinte:

> 🇪🇸 Por último, para la tercera corrida, serán modificados más
> parámetros. Para conocer todos los parámetros que puedes ser
> personalizados, digite el comando `metabat2 --help`. Con el flag `-m`
> ou `--minContig`, como ya fue usado en las corridas anteriores, es
> posible modificar el tamaño mínimo de los contigs, para este caso será
> usado 3000. Con el flag `--maxEdges`, puede ser modificado el número
> máximo de *edges* (arestas) por nodo. Entre mayor sea el número, el
> algoritmo es más sensitivo. El default es 200, va a ser usado 500 para
> esta corrida. El flag `--minS` modficia el score mínimo de cada
> *edge*, entre mayor sea es más específico. El default es 60, va ser
> usado 80. Entonces el comando a usar es el siguiente:

    mkdir 08.MetaBat2/03.ThirdTrial

    metabat2 -i 05.Assembly/scaffolds.fasta -a 08.MetaBat2/Depth.txt -t 10 --minContig 3000 --minCV 1.0 --minCVSum 1.0 --minS 80 --maxEdges 500 -o 08.MetaBat2/03.ThirdTrial/metabat2_third_

#### 6.2. CONCOCT

A seguinte ferramenta de reconstrução de genomas é
[CONCOCT](https://github.com/BinPro/CONCOCT).A qual será instalada
usando o Conda.

#### 6.2.1. Instalação

Esta ferramenta presenta alguns conflitos com outras ferramentas de
binning, principalmente na versão de Python que usa. Por este motivo
será criado um ambiente só para esta ferramenta.

> 🇪🇸 Esta herramienta presenta algunos conflictos con otras herramientas
> de binning, principalmente en la version de Python que usa. Por este
> motivo será creado un ambiente para esta herramienta

    # Crie o ambiente
    conda create -n Concoct

    # Ative o ambiente
    conda activate Concoct

    # Instale o CONCOCT
    conda install -c bioconda concoct

#### 6.2.2. Uso

Crie uma pasta para armazenar os arquivos de saída do *CONCOCT*

    mkdir 09.CONCOCT

Primeiramente vão ser cortados os contigs em partes menores

    cut_up_fasta.py 05.Assembly/scaffolds.fasta -c 10000 -o 0 --merge_last -b 09.CONCOCT/contigs_10K.bed > 09.CONCOCT/contigs_10K.fa

Agora será gerada uma tabela com a informação da cobertura por amostra e
subcontig, usando os arquivos `.sorted.bam`.

    concoct_coverage_table.py 09.CONCOCT/contigs_10K.bed 07.Mapping/*.sorted.bam > 09.CONCOCT/coverage_table.tsv

Rode o CONCOCT

    concoct --composition_file 09.CONCOCT/contigs_10K.fa --coverage_file 09.CONCOCT/coverage_table.tsv --length_threshold 1500 --threads 6 -b 09.CONCOCT/

Agora mesclar o agrupamento contig no agrupamento dos contigs originais

    merge_cutup_clustering.py 08.CONCOCT/clustering_gt1500.csv > 08.CONCOCT/clustering_merged.csv

Extrair os bins como arquivos individuais FASTA

    mkdir 09.CONCOCT/bins

    extract_fasta_bins.py 05.Assembly/scaffolds.fasta 09.CONCOCT/clustering_merged.csv --output_path 09.CONCOCT/bins

### 6.3. MaxBin2

A terceira ferramenta é chamada
[MaxBin2](https://denbi-metagenomics-workshop.readthedocs.io/en/latest/binning/maxbin.html).

#### 6.3.1. Instalação

O **MaxBin** será instalado no ambiente **Binning**.

    # Ative o ambiente Binning
    conda ativate Binning

    # Instale o MaxBin
    conda install -c bioconda maxbin2

Adicionalmente será necessário instalar também a ferramenta
[BBMAP](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbmap-guide/)
no mesmo ambiente.

    # Instale o BBMAP
    conda install -c bioconda bbmap

#### 6.3.2. Uso

Primeiro crie a pasta para saída do *MaxBin2*

    mkdir 10.MaxBin2

Para obter a informação da cobertura são usados os arquivos `.sam`. Para
facilitar, primeiro entre na pasta anteriormente criada

> 🇪🇸 Para obtener la información de cobertua son usados los archivos
> `.sam`. Para facilitar, primero entre en la carpeta anteiormente
> creada.

    cd 10.MaxBin2/

Copie os arquivos gerados no mapeamento (`.sam`) que se encontram na
pasta `07.Mapping/` para a pasta atual (`10.MaxBin/`).

    cp ../07.Mapping/*.sam ./

Gere os arquivos de cobertura usando o script `pile.up` da ferramenta
**BBMAP**

    for f in *.sam; do pileup.sh in=$f out=${f%}.txt; done

    cd .. ## sair da pasta para ficar na pasta base 10.MaxBin2/

Depois gere um arquivo com os nomes e caminhos dos arquivos de cobertura
gerados acima

    ls 10.MaxBin2/*sam.txt > 10.MaxBin2/abundance.list

A continuação o comando para gerar os bins com *MaxBin*

    ## Crie um diretório para colocar os bins
    mkdir 10.MaxBin2/bins

    # Rode o MaxBin
    run_MaxBin.pl -contig 05.Assembly/scaffolds.fasta -abund_list 10.MaxBin2/abundance.list -max_iteration 20 -min_contig_length 1500 -thread 10 -out 10.MaxBin2/bins/maxbin

*MaxBin2* gera os bins com extensão `.fasta`, mas para facilitar as
análises downstream e padronizar a mesma extensão dos bins gerados por
todas as ferramentas, é melhor converter eles para `.fa`.

Para isto vamos a usar um loop for, para realizar o procedimento com
todos bins de uma vez só.

> 🇪🇸 *MaxBin2* genera los bins con extensión `.fasta`, pero para
> facilitar los análisis downstram e estandarizar la misma extensión
> para los bins generados por todas las herramientas, es mejor convertir
> todos para `.fa`.

    cd 10.MaxBin2/bins

    for file in *.fasta
    do mv "$file" "$(basename "$file" .fasta).fa"
    done

    ls ## para conferir que agora todos os bins terminam em .fa

    cd ../../ # para voltar à pasta base

### 6.4. BinSanity

A quarta ferramenta se chama
[BinSanity](https://github.com/edgraham/BinSanity). Esta ferramenta será
instalada em um ambiente chamado **Binsanity**

#### 6.4.1. Instalação

Primeiro crie o ambiente, e depois instale **Binsanity**

    # Crie o ambiente
    conda create -n Binsanity

    # Ative o ambiente
    conda activate Binsanity

    # Instale Binsanity
    conda install -c bioconda binsanity

#### 6.4.2 Uso

Como sempre crie uma pasta para a saída do processamento nesta
ferramenta.

    mkdir 11.BinSanity

Gere a informação da cobertura das amostras

    Binsanity-profile -i 05.Assembly/scaffolds.fasta -s 07.Mapping/ -T 10 -c 11.BinSanity/coverage_profile.txt -o 11.BinSanity/

No seguinte comando serão gerados os bins

    Binsanity-lc -f . -l 05.Assembly/scaffolds.fasta -x 1500 --checkm_threads 1 --Prefix binsanity_ -c 11.BinSanity/coverage_profile.txt.cov.x100.lognorm

*BinSanity* criou uma pasta com onde estão todos os resultados da
corrida `BINSANITY-RESULTS/` e os bins se encontram em
`BINSANITY-RESULTS/binsanity_-KMEAN-BINS/`

Ao igual que com *MaxBin* tem que converter os bins para `.fa`, com a
diferença que o *BinSanity* gera os MAGs com extensão `.fna`.

    cd BINSANITY-RESULTS/binsanity_-KMEAN-BINS/

    for file in *.fna
    do mv "$file" "$(basename "$file" .fna).fa"
    done

    ls ## para conferir que agora todos os bins terminam em .fa

    cd ../../ # Para voltar à pasta base

## 8. Desreplicação com DAS TOOL

o [DasTools](https://github.com/cmks/DAS_Tool) é uma ferramenta que
integra os resultados de diferentes ferramentas de reconstrução de
genomas apartir de metagenomas, para determinar o conjunto otimizado de
MAGs, não redundantes de uma única montagem.

> 🇪🇸 [DasTools](https://github.com/cmks/DAS_Tool) es una herramienta que
> integra los resultados de diferentes herramientas de reconstrucción de
> genomas a partir de metagenomas, para determinar el conjunto
> optimizado de MAGs, no redundantes de un único ensamble

### 8.1 Instalação

Crie um ambiente chamado **Dastool** para instalar a ferramenta

    # Crie o ambiente
    conda create -n Dastool

    # Ative o ambiente
    conda activate Dastool

    # Adicione os channels
    conda config --add channels defaults
    conda config --add channels bioconda
    conda config --add channels conda-forge

    # Instale Das Tool
    conda install -c bioconda das_tool

### 8.2 Uso

Crie uma pasta para o output de Das Tool

    mkdir 12.DasTool

O primeiro paso é gerar uma tabela `.tsv`, com os contigs IDs e os bin
IDs.

Nem todas as ferramentas de binning fornecem resultados em formato de
tabela `.tsv`, com o contigs IDs e os bin IDs. Para formatar isto o DAS
Tool tem um script adicional `scaffolds2bin` que converte um conjunto de
bins no formato `.fasta` em um arquivo tabular para ser usado como input
do DAS Tool. Salve as tabelas na pasta criada para DAS Tool.

    cd 08.MetaBat2/01.FirstTrial/ #entrar na pasta da primeira rodada com o MetaBat2

    Fasta_to_Scaffolds2Bin.sh -e fa > ../../12.DasTool/metabat2_firsttrial.tsv #Script pra criar a tabela

    cd ../02.SecondTrial/ 

    Fasta_to_Scaffolds2Bin.sh -e fa > ../../12.DasTool/metabat2_secondtrial.tsv

    cd ../03.ThirdTrial/

    Fasta_to_Scaffolds2Bin.sh -e fa > ../../12.DasTool/metabat2_thirdtrial.tsv

    cd ../../09.CONCOCT/bins/

    Fasta_to_Scaffolds2Bin.sh -e fa > ../../12.DasTool/concoct.tsv

    cd ../../10.MaxBin2/bins/

    Fasta_to_Scaffolds2Bin.sh -e fa > ../12.DasTool/maxbin.tsv

    cd ../BINSANITY-RESULTS/binsanity_-final_bins/

    Fasta_to_Scaffolds2Bin.sh -e fa > ../../12.DasTool/binsanity.tsv

Após criadas as tabelas dos bins de cada ferramenta usada, é rodado o
DAS Tool

    cd ../../12.DasTool/

    DAS_Tool -i binsanity.tsv,concoct.tsv,maxbin.tsv,metabat2_firsttrial.tsv,metabat2_secondtrial.tsv,metabat2_thirdtrial.tsv -l binsanity,concoct,maxbin,metabat2ft,metabat2st,metabat3tt -c ../05.Assembly/final.contigs.fa -t 10 -o ./ --score_threshold 0.0 --write_bins 1 --search_engine diamond

Após terminar a corrida do *DAS Tool*, de uma olhada no arquivo
`_DASTool_summary.txt`, o qual é uma tabela com muitas informações dos
bins que passaram o filtro do *DAS Tool* (p.e. “size”, “contigs”, “N50”,
“binScore”, “SCG\_completeness”, “SCG\_redundancy”)

<div class="figure" style="text-align: center">

<img src="imgs/tabela.png" alt="Tabela DASTools" width="100%" height="100%" />
<p class="caption">
Tabela DASTools
</p>

</div>

Adicionalmente, o **DAS Tool** separa os bins que passaram o *threshold*
na pasta `12.DasTool/_DASTool_bins/`.

## 8. Qualidade dos MAGs

#### 8.1. Renomeando os MAGs

Crie uma pasta para colocar todos os bins dereplicados pelo DAS Tool

    mkdir 13.MAGS
               

Use o comando `mv` para colocar os bins dereplicados na pasta `13.MAGS`.
Use o comando `ls` para confirmar que tudo deu certo.

> 🇪🇸 Use el comando `mv` para colocar los bins desreplicados na pasta
> `13.MAGS`. Use o comando `ls` para confirmar que todo funcionó.

    mv _DASTool_bins/* ../13.MAGS/

    ls

Agora que todos os bins estão numa pasta única, e para facilitar as
análises seguintes, renomee os bins usando o script
[numerate.sh](https://github.com/khidalgo85/Binning/blob/master/numerate.sh).
Este script irá renomear, usando um nome base para todos, seguido de
números consecutivos.

> 🇪🇸 Ahora que todos los bins están en la misma carpeta, y para
> facilitar los análisis siguientes, renombré los bins usando el script
> [numerate.sh](https://github.com/khidalgo85/Binning/blob/master/numerate.sh).
> Este script renombrará, usando un nombre base para todos, seguido de
> números consecutivos.

    ./numerate.sh -d 13.MAGS -b 1 -p MAG -s .fa -o numerically -r

**SINTAXE**

    ./numerate.sh -d <pasta/com/arquivos/para/renomear> -b <número inicial> -p sufijo -s .extensão -o numerically

-   `-d`: Pasta com os arquivos que quer renomear
-   `-b`: número para iniciar a sequência
-   `-p`: sufijo, palavra inicial
-   `-s`: prefijo/extensão
-   `-o`: ordem (númerica)

**Nota:** Caso ao tentar rodar acuse um erro de permissão, digite o
seguinte comando `chmod 777 numerate.sh` e tente novamente.

Ao final do processo, dentro da pasta `13.MAGS`, terá todos os bins,
nomeados como MAG1, MAG2, MAG3… MAGn.

> 🇪🇸 **Nota:** Si al intentar rodar, sale un error de permisos, dígite
> el siguiente comando `chmod 777 numerate.sh` e intente nuevamente.
>
> Al final del proceso, dentro de la carpeta `13.MAGS`, tendrá todos los
> bins nombrados como MAG1, MAG2, MAG3… MAGn.

#### 8.1. CheckM

#### 8.1.1. Instalação

A qualidade dos MAGs é avaliada usando uma ferramenta chamada
[CheckM](https://github.com/Ecogenomics/CheckM/wiki). Basicamente a
avaliação consiste em comparar os MAGs com uma base de dados de genes de
cópia única para assim saber que tão completo e contaminado está cada um
dos genomas recuperados.

Esta ferramenta pode ser instalada dentro do ambiente **QualityControl**

> 🇪🇸 La calidad de los MAGs es evaluada usando una herramienta llamada
> [CheckM](https://github.com/Ecogenomics/CheckM/wiki). Basicamente la
> evaluación consiste en comparar los MAGs con una base de datos de
> genes de copia única, para así saber que tan completo y contaminado
> está cada uno de los genomas recuperados.
>
> Esta herramienta puede ser instalada dentro del ambiente
> **QualityControl**

    # Ative o ambiente QualityControl
    conda activate QualityControl

    # Instale CheckM
    conda install -c bioconda checkm-genome

#### 8.1.2. Uso

Serão analisados os genomas desreplicados e renomeados (`13.MAGS`)

Agora crie uma pasta para armazenar a saída do *CheckM*:

    mkdir 14.CheckM

Para rodar o *CheckM* é preciso criar um diretório para os arquivos
temporais que serão criados enquanto a corrida.

    mkdir tmp

Lembre **SEMPRE** que **TODA** ferramenta tem um menú de ajuda (`-h` ou
`--help`).

Para rodar a análise de qualidade pelo *CheckM* use o seguinte comando:

    checkm lineage_wf 13.MAGS/ 14.CheckM/ -t 10 -x fa --tmpdir tmp --tab > 14.CheckM/output.txt

A continuação um gráfico mostrando a disperssão dos MAGs segundo a
qualidade (baseado no
[MiMAG](https://www.nature.com/articles/nbt.3893)), sendo possível
observar quantos MAGs são de baixa (*Low-Quality*: *Completeness &lt; 50
& Contamination &gt; 10*), média (*Medium-Quality*: *Completeness &gt;
50 & Contamination &lt; 10*) e alta (*High-Quality*: *Completeness &gt;
90 & Contamination &lt; 5*). Para a construção desse gráfico, use este
[script](https://github.com/khidalgo85/Binning/blob/master/Checkm.R) de
R.

> 🇪🇸 A continuación un gráfico mostrando la dispersión de los MAGs segun
> su calidad (baseado en
> [MiMAG](https://www.nature.com/articles/nbt.3893)), siendo posible
> observar cuantos MAGs son de baja (*Low-Quality*: *Completeness &lt;
> 50 & Contamination &gt; 10*), media (*Medium-Quality*: *Completeness
> &gt; 50 & Contamination &lt; 10*) y alta (*High-Quality*:
> *Completeness &gt; 90 & Contamination &lt; 5*). Para la construcción
> de este gráfico, use este
> [script](https://github.com/khidalgo85/Binning/blob/master/Checkm.R)
> de R.

``` r
### Gráfico de dispersão dos bins baseado na completude e contaminação

# Lendo os dados 

tab <- read.delim("output.txt", skip = 33)

library(dplyr)

## Formatando a tabela
tab1 <- as_tibble(tab) %>% 
  na.omit() %>% 
  select(1,12,13) %>% 
  mutate(Quality = case_when(Contamination < 5 & Completeness > 90 ~ "High-Quality",
                             Contamination < 10 & Completeness >= 50 ~ "Medium-Quality",
                             Completeness < 50 ~ "Low-Quality",
                             Contamination > 10 ~ "Low-Quality"))

## Contando os MAGs por qualidade

tab1 %>% 
  group_by(Quality) %>% 
  summarise(
    n=n()
  )
#> # A tibble: 3 × 2
#>   Quality            n
#>   <chr>          <int>
#> 1 High-Quality       1
#> 2 Low-Quality        9
#> 3 Medium-Quality     7


library(ggplot2)

tab1 %>% 
ggplot(aes(x=Completeness, y=Contamination, shape=Quality)) + 
  geom_point(size =1.3) +
  ggtitle("MAGs Dispersion by CheckM") +
  theme(plot.title = element_text(face = "bold", colour = "Dark blue")) +
  theme(axis.title = element_text(face = "bold", colour = "Black")) +
  scale_shape_manual(values = c(17, 8, 1)) +
  ylim(50,0) + xlim(0,100) +
  annotate("text", x = 45, y = 50, label = "High-Quality draft 1 (Comp > 90 & Cont < 5)", size = 2.5, colour= "Dark green") +
  annotate("text", x = 45, y = 45, label = "Medium-Quality draft 7 (Comp > 50 & Cont < 10)", size = 2.5, colour= "Orange") +
  annotate("text", x = 45, y = 40, label = "Low-Quality draft 9 (Comp < 50 & Cont > 10)", size = 2.5, colour= "Red" ) + 
  geom_vline(xintercept=90, linetype="dashed", colour="Dark green") + geom_hline(yintercept=5, linetype="dashed", colour="Dark green") +
  geom_vline(xintercept=50, linetype="dashed", colour="orange") + geom_hline(yintercept=10, linetype="dashed", colour="Orange")
```

<img src="imgs/unnamed-chunk-4-1.png" width="100%" />

Observe que foi possível recuperar um genoma de alta qualidade, 7 de
média qualidade e 8 de baixa qualidade.

## 9. Anotação Taxonômica

Existem diversas ferramentas para anotação taxonômica, no entanto a mais
utilizada em estudos com MAGs é
[GTDB-tk](https://ecogenomics.github.io/GTDBTk/index.html). O qual é um
software criado para asignação taxonômica de genomas de bactérias e
arqueias baseado no **Genome Database Taxonomy - GTDB**. Dentro desta
base de dados existe uma grande quantidade de MAGs obtidos de amostras
ambientais e genomas de microrganismos isolados.

> 🇪🇸 Existen diversas herramientas para anotación taxonómica, sin
> embargo la más utilizada en estudios con MAGs es
> [GTDB-tk](https://ecogenomics.github.io/GTDBTk/index.html). El cual es
> un software creado para asignación taxonómica de genomas de bacterias
> y arqueas con base en **Genome Database Taxonomy - GTDB**. Dentro de
> esta base de datos existe una gran cantidad de MAGs obtenidos de
> muestras ambientales e genomas de micoorganismos aislados.

### 9.1. Instalação

A instalação de **GTDB-Tk** pode ser feita através de conda ao igual que
a maioria das ferramentas.

Crie um ambiente para a instalação deste programa

> 🇪🇸 La instalacion de **GTDB-Tk** puede ser realizada a travéz de conda
> al igual que la mayoria de herramientas.
>
> Crie un ambiente para la instalación de este programa

    # Crie um ambiente e instale GTDB-Tk
    conda create -n gtdbtk -c conda-forge -c bioconda gtdbtk

Perceba que, na mesma linha de comando você criou um ambiente chamado
gtdbtk e instalou a ferramenta.

Uma vez instalado o programa, é necessário descarregar a base de dados.

Primeramente ative o ambiente com `conda activate gtdbtk`

A base de dados pode ser descarregada e configurada automáticamente
usando o script `download-db.sh`. Esse script irá descarregar,
descompactar e configurar a DB.

Esse processo pode ser feito manualmente também:

> 🇪🇸 Perciba que, en la misma linea de comando usted creó un ambiente
> llamado gtdbtk e instaló la herramienta.
>
> Una vez instalado el programa, es necesario descargar la base de
> datos.
>
> La base de datos puede ser descargada y configurada automáticamente
> usando el script `download-db.sh`. Este script irá descargar,
> descompactar y configurar la DB?
>
> Este proceso también puede ser hecho manualmente:

    # Crie um diretório para fazer download da DB
    mkdir dbs
    cd dbs/
    mkdir gtdb
    cd gtdb/

    # Download
    wget https://data.gtdb.ecogenomic.org/releases/latest/auxillary_files/gtdbtk_data.tar.gz

    # Descompactando
    tar xvzf gtdbtk_data.tar.gz

    # Configurando o PATH
    export GTDBTK_DATA_PATH="/caminho/a/dbs/gtdb/release202"

Para confirmar que tudo foi corretamente instalado e configurado rode o
comando: `gtdbtk check_install`

### 9.2. Uso

Uando R e o arquivo de saída do CheckM `output.txt` crie uma lista dos
MAGs com média e alta qualidade. A continuação encontra o
[Script](https://github.com/khidalgo85/Binning/blob/master/filtering_mags.R)
do R:

> 🇪🇸 Usando R y el archivo de salida de CheckM `output.txt` cree una
> lista de los MAGs con media e alta calidad. A continuación encontra el
> [Script](https://github.com/khidalgo85/Binning/blob/master/filtering_mags.R)
> de R:

``` r
# Lendo os dados 

tab <- read.delim("output.txt", skip = 33)

library(dplyr)

## Formatando a tabela
tab1 <- as_tibble(tab) %>% 
  na.omit() %>% 
  select(1,12,13) %>% 
  mutate(Quality = case_when(Contamination < 5 & Completeness > 90 ~ "High-Quality",
                             Contamination < 10 & Completeness >= 50 ~ "Medium-Quality",
                             Completeness < 50 ~ "Low-Quality",
                             Contamination > 10 ~ "Low-Quality"))

## Contando os MAGs por qualidade

tab1 %>% 
  group_by(Quality) %>% 
  summarise(
    n=n()
  )
#> # A tibble: 3 × 2
#>   Quality            n
#>   <chr>          <int>
#> 1 High-Quality       1
#> 2 Low-Quality        9
#> 3 Medium-Quality     7

### Criando tabela só com os MAGs de alta e média qualidade
mags.filtered <- tab1 %>% 
  group_by(Quality) %>% 
  filter(Quality == "High-Quality" | Quality == "Medium-Quality") %>% 
  ungroup() %>% 
  select(Bin.Id) %>% 
  as.data.frame()

fa <- c(rep(".fa", nrow(mags.filtered))) ## add .fa a cada nome do MAG


mags <- mags.filtered[,1] %>% 
  paste0(., fa) %>% 
  write(., file="filt.mags.txt") # salva o arquivo com a lista dos Mags que passaram o filtro


mags.filtered
#>   Bin.Id
#> 1  MAG10
#> 2  MAG11
#> 3  MAG12
#> 4   MAG2
#> 5   MAG3
#> 6   MAG6
#> 7   MAG7
#> 8   MAG8
```

Faça upload do arquivo criado com o script do R `filt.mags.txt` no
servidor dentro da pasta base. Este arquivo será usado para separar os
MAGs de alta e média qualidade dos de baixa que não serão usados nas
seguintes análises.

> 🇪🇸 Haga el upload del archivo creado com el script de R
> `filt.mags.txt` al servidor dentro de la pasta base. Este archivo será
> usado para separa los MAGs de alta y media calidad de los de baja
> calidad que no serán usados en los siguentes análisis.

    # Entre na pasta dos MAGs
    cd 13.MAGS

    # Crie um diretório para colocar os MAGs com alta e média qualidade
    mkdir HQ_MQ_MAGs

    # Crie um diretório para colocar os MAGs com baixa qualidade
    mkdir LQ_MAGs

Uma vez criados os diretórios para separar os MAGs pela qualidade, será
usado o arquivo com a lista de MAGs que passaram o filtro:

> 🇪🇸 Una vez creados los directorios para separar los MAGs por la
> calidad, será usado un archivo con la lista de MAGs que pasaron el
> filtro:

    cat ../filt.mags.txt | xargs mv -t HQ_MQ_MAGs/

    ls HQ_MQ_MAGs

Com o comando anterior, os MAGs que estiverem na lista do arquivo
`filt.mags.txt` serão trocados de pasta para o diretório `HQ_MQ_MAGs/`.
Se preferir, para organizar melhor, passe o restante dos MAGs dentro da
pasta `13.MAGS/` (MAGs com baixa qualidade) para o diretório `LQ_MAGs/`.

> 🇪🇸 Con el comando anterior, los MAGs que estén en la lista del archivo
> `filt.mags.txt` serán cambiados de carpeta para el directorio
> `HQ_MQ_MAGs/`. Si prifiere, para organizar mejor, pase el restante de
> MAGs dentro de la carpeta `13.MAGS` (MAGs con baja calidad) para el
> directorio `LQ_MAGs/`.

    mv *.fa LQ_MAGs/

Pronto, agora pode proceder à anotação taxonômica dos MAGs de alta e
média qualidade usando o programa **GTDB-tk**.

    cd ..

    mkdir 15.TaxonomicAnnotation

    gtdbtk classify_wf --genome_dir 13.MAGS/HQ_MQ_MAGs/ --out_dir 15.TaxonomicAnnotation/ -x fa --min_perc_aa 10 --cpus 15 --scratch_dir slower

**SINTAXE**

    gtdbtk classify_wf --genome_dir diretorio/com/os/Mags/ --out_dir output/ -x <fa fasta fna> --cpus <número de núcleos>

-   `classify_wf`: este script consiste em três fases (que também podem
    ser feitas por separado); `identify`, `align` e `classify`.
    `identify` gerá uma predição de genes usando **Prodigal** e usa
    **HMMER** para identificar 120 genes marcadores de bactéria e
    archaea usados para inferência flogenética. São feitos alinhamentos
    múltiplos no alinhamento dos marcadores nos modelos HMM. `align`
    concatena os marcadores de genes alinhados e filtra o alinhamento
    multiplo a aproximadamente 5,000 amino ácidos. `classify`, usa
    **pplacer** usando *maximun-likelihood* para colocar cada genoma
    numa árvore de referência de GTDB-Tk, o qual classifica cada genoma
    baseado no seu lugar na árvore de referência, a sua divergência
    evolucionaria relativa, e/ou o ANI (*average nucleotide identity*)
    contra genomas de referência.

> 🇪🇸 \* `classify_wf`: este script consiste en tres fases (que también
> pueden ser realizadas por separado); `identify`, `align` e `classify`.
> `identify` genera una predicción de genes usando **Prodigal** y usa
> **HMMER** para identificar 120 genes marcadores de bacteria e arquea
> usados para inferencia flogenética. Son realizados alineamintos
> múltiples en el alineamiento de los marcadores en los modelos HMM.
> `align` concatena los marcadores de genes alineados y filtra el
> alineamiento multiple a aproximadamente 5,000 amino ácidos.
> `classify`, usa **pplacer** usando *maximun-likelihood* para colocar
> cada genoma en un árbol de referencia de GTDB-Tk, oel cual clasifica
> cada genoma con base al lugar en el árbol de referencia, a su
> divergencia evolucionaria relativa, y/o el ANI (*average nucleotide
> identity*) contra genomas de referencia.

-   `--genome_dir`: Diretório com os genomas

-   `out_dir`: Diretório para o output. Nele serão criadas
    automáticamente pastas para cada uma das fases do processo.

-   `-x`: formato (p.e. `.fa`, `.fasta`, `.fna`)

-   `--cpus`: número de núcleos ou threads.

### 9.3. Output

Após a corrida de **GTDB-Tk** serão gerados uma série de arquivos e
pastas com resultados de cada fase do processo. Esta ferramenta separa
os resultados dos MAGs que foram anotados como bactérias e como
Arqueias. Isto devido a que usa dois bases de dados separadas para cada
dominio. Assím, os arquivos com os resultados finais são
`gtdbtk_bac120.summary.tsv` e `gtdbtk_ar122.summary.tsv`. Estes arquivos
são tabelas com as seguintes colunas:

> 🇪🇸 Depois del proceso de **GTDB-Tk** serán generados una serie de
> archivos y directorios con resultados de cada fase del proceso. Esta
> herramienta separa los resultados de los MAGs que fueron anotados como
> bacterias y arqueas. Este es debido a que usa dos bases de datos
> separadas para cada dominio. Así, los archivos con los resultados
> finales son: `gtdbtk_bac120.summary.tsv` y `gtdbtk_ar122.summary.tsv`.
> Estos archivos son tablas con las siguientes columnas:

-   user\_genome: Nome do MAG
-   Classification: Taxonomia inferida por GTDB-Tk.
-   fastani\_reference: Indica o número de acesso do genoma de
    referência ao qual o MAG foi assignado baseado no ANI (*Average
    Nucleotide Identity*)
-   fastani\_reference\_radius: Informação númerica do ANI
-   fastani\_taxonomy: Indica a taxonomia do GTDB para o genoma de
    referência
-   fastani\_ani: Indica o valor de ANI entre o MAG e o genoma de
    referência
-   fastani\_af: infica o valor de AF entre o MAG e o genoma de
    referência
-   closest\_placement\_reference: Indica o número de acesso ao genoma
    de referência quando o MAG e colocado em um branch terminal
-   closest\_placemente\_taxonomy: Indica a taxonomia do GTDB para o
    genoma de referência de cima
-   closest\_placement\_ani: Indica o valor de ANI entre o MAG e o
    genoma de referência de cima.
-   closest\_placement\_af: Indica o valor de AF entre o MAG e o genoma
    de referência de cima
-   pplacer\_taxonomy: Indica a taxonomia do pplacer para o MAG
-   classification\_method: Indica o método usado para a classificação
    do MAG.
-   note: provee informação adicional da clasificação do MAG. Este campo
    é prenchido quando a determinação da espécie é feita e indica se a
    colocação de MAG dentro de uma árvore de referência e o parente mais
    próximo baseado no ANI/AF são iguais (congruent) ou diferentes
    (incongruent).
-   other\_relate\_references: lista de 100 genomas de referência
    próximos baseadso no ANI.
-   mas\_percent: Indica a porcentagem do MSA

**TABELA**

Usando um [Script de
R](https://github.com/khidalgo85/Binning/blob/master/taxonomy.R),
contrua uma tabela única com as informações das taxonomias e da
qualidade dos MAGs:

``` r
## Construindo tabela com taxonomia e qualidade dos mags

## install.packages('dplyr')
library(dplyr)

## install.packages('tidyr')
library(tidyr)


## Lendo a tabela saída do CheckM com a qualidade dos MAGs
quality <- read.delim("output.txt", skip = 33) %>% 
  select(Bin.Id, Completeness, Contamination) %>% 
  na.omit() %>% 
  as_tibble() %>% 
  rename(Genome = Bin.Id)

## Lendo a tabela de anotação taxonômica de bactérias
bact.taxa <- read.delim("gtdbtk.bac120.summary.tsv",
                        sep = '\t') %>% 
  select(user_genome, classification, classification_method, note) %>% 
  rename(Bin.Id = user_genome) %>% 
  as_tibble() %>% 
  separate(col = classification, into = c("Kingdom", "Phylum", "Class", "Order",
                                          "Family", "Genus", "Species"), sep = ';')



## Lendo a tabela de anotação taxonômica de Arqueas
arc.taxa <- read.delim("gtdbtk.ar122.summary.tsv",
                       sep = '\t') %>% 
  select(user_genome, classification, classification_method, note) %>% 
  rename(Bin.Id = user_genome) %>% 
  as_tibble() %>% 
  separate(col = classification, into = c("Kingdom", "Phylum", "Class", "Order",
                                          "Family", "Genus", "Species"), sep = ';')


## Unindo as tabelas de taxonomia
taxa <- rbind(bact.taxa,  arc.taxa) %>%
  rename(Genome = Bin.Id) 

### Limpando a taxonomia
temp <- select(taxa, 2:8)

# Eliminando caracteres indesejados na taxonomia 
temp$Kingdom<-gsub("d__","",as.character(temp$Kingdom))
temp$Phylum<-gsub("p__","",as.character(temp$Phylum))
temp$Class<-gsub("c__","",as.character(temp$Class))
temp$Order<-gsub("o__","",as.character(temp$Order))
temp$Family<-gsub("f__","",as.character(temp$Family))
temp$Genus<-gsub("g__","",as.character(temp$Genus))
temp$Species<-gsub("s__","",as.character(temp$Species))


### Completando os campos sem taxonomia com o último nível assignado
temp[is.na(temp)] <- ""

for (i in 1:nrow(temp)){
  if (temp[i,2] == ""){
    Kingdom <- paste("Kingdom_", temp[i,1], sep = "")
    temp[i, 2:7] <- Kingdom
  } else if (temp[i,3] == ""){
    phylum <- paste("Phylum_", temp[i,2], sep = "")
    temp[i, 3:7] <- phylum
  } else if (temp[i,4] == ""){
    Class <- paste("Class_", temp[i,3], sep = "")
    temp[i, 4:7] <- Class
  } else if (temp[i,5] == ""){
    Order <- paste("Order_", temp[i,4], sep = "")
    temp[i, 5:7] <- Order
  } else if (temp[i,6] == ""){
    Family <- paste("Family_", temp[i,5], sep = "")
    temp[i, 6:7] <- Family
  } else if (temp[i,7] == ""){
    temp$Species[i] <- paste("Genus",temp$Genus[i], sep = "_")
  }
}

taxa$Kingdom <- temp$Kingdom
taxa$Phylum <- temp$Phylum
taxa$Class <- temp$Class
taxa$Order <- temp$Order
taxa$Family <- temp$Family
taxa$Genus <- temp$Genus
taxa$Species <- temp$Species



## Unindo a taxonomia com a qualidade
taxa <- merge(quality, taxa, by = "Genome") 



# Classificando os MAGs pela qualidade
taxa2 <- taxa %>% 
  mutate(Quality = if_else(Completeness > 90 & Contamination < 5, "HighQuality",
                           "MediumQuality"))
```

<table class="table table" style="margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Genome
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Completeness
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Contamination
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Kingdom
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Phylum
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Class
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Order
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Family
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Genus
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Species
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
classification\_method
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
note
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Quality
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG10
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
62.50
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.38
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Desulfobacterota\_F
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Desulfuromonadia
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Geobacterales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Geobacteraceae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Geobacter\_D
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_Geobacter\_D
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG11
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
51.04
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
1.39
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Kapabacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Kapabacteriales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA2268
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Family\_UBA2268
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Family\_UBA2268
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification fully defined by topology
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
MAG12
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
94.30
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
0.00
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Ignavibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
SJA-28
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
B-1AR
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Ch128a
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Genus\_Ch128a
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
HighQuality
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG2
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
100.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
8.33
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Ignavibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Ignavibacteriales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Melioribacteraceae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
XYB12-FULL-38-5
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_XYB12-FULL-38-5
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic novelty determined using RED
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG3
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
74.10
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
1.14
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidia
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
BBW3
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA8529
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_UBA8529
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG6
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
52.08
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Patescibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Paceibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA9983\_A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA9973
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA9973
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_UBA9973
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG7
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
75.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
9.90
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Archaea
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Thermoproteota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrososphaeria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrososphaerales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrosopumilaceae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrosotenuis
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrosotenuis cloacae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
topological placement and ANI have congruent species assignments
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG8
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
83.91
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
8.71
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Firmicutes\_B
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Thermincolia
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Thermincolales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA2595
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
GW-Firmicutes-8
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_GW-Firmicutes-8
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
</tr>
</tbody>
</table>

## 10. Abundância relativa dos MAGs nas amostras

Usando o programa [**CoverM**](https://github.com/wwood/CoverM) é
possível calcular a abundância relativa de cada MAG em cada uma das
amostras. Para isto é necessário usar os arquivos `.sorted.bam` para
mapear os genomas dentro das reads das amostras.

> 🇪🇸 Usando el programa [**CoverM**](https://github.com/wwood/CoverM) es
> posible calcular la abundancia relativa de cada MAG en cada una de las
> muestras. Para esto es necesario usar los archivos `.sorted.bam` para
> mapear los genomas dentro de los reads de las muestras

### 10.1. Instalação

Crie um novo ambiente para esta ferramenta, chamado **coverm**

    # Crie o ambiente
    conda create -n coverm

    # Ative o ambiente
    conda activate coverm

    # Instale Coverm
    conda install -c bioconda coverm

### 10.2 Uso

**CorverM** usará a informação do mapeamento, para calcular a
porcentagem relativa de cada MAG em cada uma das amostras que os
originaram.

    mkdir 16.Coverage

    coverm genome --bam-files 06.Mapping/Sample1.sorted.bam 06.Mapping/Sample2.sorted.bam 06.Mapping/Sample3.sorted.bam 06.Mapping/Sample4.sorted.bam 06.Mapping/Sample5.sorted.bam 06.Mapping/Sample6.sorted.bam -d 13.MAGs/HQ_MQ_MAGs -x fa --min-read-percent-identity 0.95 --methods relative_abundance --output-file 16.Coverage/output_coverm.tsv

**SINTAXE**

    coverm mode <mapping_input> -d genomes_directory/ -x extension <.fa .fna .fasta> --min-read-percent-identity x.xx --methods method --output-file output.tsv -t 6

-   `mode`: `genome` ou `contig.` Tipo de dados nos que o programa vai
    calcular a cobertura

-   `mapping_input`:

    -   `-1` (arquivos forward fasta/q para mapeamento), `-2` (arquivos
        reverse fasta/q para mapeamento)
    -   `-c` um o mais pares de forward e reverse fasta/q para
        mapeamento em ordem
    -   `--single` fasta/q no pareados (single-end)
    -   `--bam-files` archivos bam ordenados (sorted)

-   `-d` diretório com os genomas

-   `-x` extensão dos arquivos dos genomas

-   `--min-read-percent-identity` Exclui sequências com porcetagem de
    identidade menor ao inserido.

-   `--methods` Método para calcular a cobertura (i.e
    `relative_abundance`, `mean`, `trimmed_mean`, `coverage_histogram`,
    `covered_bases`, `varieance`, etc)

-   `--output-file` tabela com resultados.

-   `-t` número de threads

**Nota:** Este programa tem **MUITOS** parâmetros para customizar, por
favor para mais informação visite a documentação pro modo
[`genome`](wwood.github.io/CoverM/coverm-genome.html) ou pro modo
[`contig`](wwood.github.io/CoverM/coverm-contig.html).

Agora adicione a nova informação de abundância relativa de cada MAG na
tabela com a qualidade e a taxonomia e gráfique. (Encontre o Script do R
[aqui](https://github.com/khidalgo85/Binning/blob/master/coverage.R))

``` r
library(tidyr)
library(ggplot2)

## Lendo a tabela de cobertura

cov <- read.delim("output_coverm.tsv") %>% 
  rename(Sample1 = Sample1_.sorted.Relative.Abundance....,
         Sample2 = Sample2_.sorted.Relative.Abundance....,
         Sample3 = Sample3_.sorted.Relative.Abundance....,
         Sample4 = Sample4_.sorted.Relative.Abundance....,
         Sample5 = Sample5_.sorted.Relative.Abundance....,
         Sample6 = Sample6_.sorted.Relative.Abundance....
  ) %>% 
  filter(Genome != "unmapped") %>% 
  mutate_if(is.numeric, round, digits = 2)


## Unindo com a tabela de taxonomia e qualidade

final.table <- merge(taxa2, cov, by = "Genome")

## Transpondo

df <- final.table %>%
  gather(Sample, RelativeAbundance, Sample1:Sample6) %>% 
  as_tibble()


mypalette <- c("#a65538","#7282e2","#6fbe48","#ad5ed3","#bbb237",
               "#6256ba","#e29a39","#6086c3")


### Phylum
p <- df %>% 
  ggplot(aes(y=Sample, x=RelativeAbundance, fill=Family)) + 
  geom_bar(stat='identity') + scale_fill_manual(values=c(mypalette)) +
  scale_y_discrete(labels=c("Sample1", "Sample2", "Sample3", "Sample4", 
                            "Sample5", "Sample6")) +
  theme(axis.text.x = element_text(size = 14)) +
  theme(axis.text.y = element_text(size = 14)) +
theme(legend.position = "bottom") +
  theme(axis.text.x = element_text(size = 14)) +
  theme(axis.text.y = element_text(size = 14)) +
  theme(legend.text = element_text(size = 12))

p
#> Warning: Removed 16 rows containing missing values (position_stack).
```

<img src="imgs/unnamed-chunk-8-1.png" width="100%" />

<table class="table table" style="margin-left: auto; margin-right: auto; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Genome
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Completeness
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Contamination
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Kingdom
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Phylum
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Class
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Order
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Family
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Genus
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Species
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
classification\_method
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
note
</th>
<th style="text-align:left;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Quality
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Sample1
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Sample2
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Sample3
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Sample4
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Sample5
</th>
<th style="text-align:right;color: black !important;background-color: rgb(172, 178, 152) !important;font-size: 15px;">
Sample6
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG10
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
62.50
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.38
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Desulfobacterota\_F
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Desulfuromonadia
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Geobacterales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Geobacteraceae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Geobacter\_D
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_Geobacter\_D
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
13.86
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG11
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
51.04
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
1.39
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Kapabacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Kapabacteriales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA2268
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Family\_UBA2268
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Family\_UBA2268
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification fully defined by topology
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
6.48
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
MAG12
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
94.30
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
0.00
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Ignavibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
SJA-28
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
B-1AR
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Ch128a
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
Genus\_Ch128a
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: green !important;">
HighQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
0.99
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
9.45
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: green !important;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG2
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
100.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
8.33
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Ignavibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Ignavibacteriales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Melioribacteraceae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
XYB12-FULL-38-5
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_XYB12-FULL-38-5
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic novelty determined using RED
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
76.66
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
18.85
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
9.60
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG3
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
74.10
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
1.14
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidia
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteroidales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
BBW3
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA8529
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_UBA8529
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
8.42
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG6
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
52.08
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Patescibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Paceibacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA9983\_A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA9973
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA9973
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_UBA9973
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
6.70
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG7
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
75.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
9.90
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Archaea
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Thermoproteota
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrososphaeria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrososphaerales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrosopumilaceae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrosotenuis
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Nitrosotenuis cloacae
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
topological placement and ANI have congruent species assignments
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
4.56
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
</tr>
<tr>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MAG8
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
83.91
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
8.71
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Bacteria
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Firmicutes\_B
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Thermincolia
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Thermincolales
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
UBA2595
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
GW-Firmicutes-8
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
Genus\_GW-Firmicutes-8
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
taxonomic classification defined by topology and ANI
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
N/A
</td>
<td style="text-align:left;font-weight: bold;color: white !important;background-color: orange !important;">
MediumQuality
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
2.73
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
14.69
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
0.00
</td>
<td style="text-align:right;font-weight: bold;color: white !important;background-color: orange !important;">
NaN
</td>
</tr>
</tbody>
</table>

As colunas com *NaN* significa que nenhuma read dessas amostras foram
mapeadas. Isso pode ser porque as amostras do dataset de exemplo são
pequenas subsamples. Nenhum MAG foi gerado a partir dessas duas amostras
(Sample4 e Sample6).

> 🇪🇸 Las columnas con *NaN* significa que ningún read de esas muestras
> fueron mapeadas. Esto puede ser porque las muestras del dataset de
> ejemplo son pequeños subsampels. Ningún MAG fue generado a partir de
> esas dos muestras (Sample4 y Sample6).

## 11. Anotação Funcional

Além da anotação taxonômica pode ser feita uma anotação funcional para
conhecer o potencial metabólico de cada um dos MAGs obtidos. Esta fase
está divida em dois grandes processos: i) predição dos genes, ii)
alinhamento dos genes preditos contra as diferentes bases de dados.

> 🇪🇸 Además de la anotación taxonómica puede ser hecha una anotación
> funcional para conocer el potencial metabólico de cada uno de los MAGs
> obtenidos. Esta fase está dividida en dos grandes procesos: i)
> predicción de genes, ii) alineamiento de los genes predichos contra
> las diferentes bases de datos.

### 11.1. Predição de genes

O objetivo desta etapa é procurar os mascos abertos de leitura ou ORF
(*Open Reading Frames*) dentro dos MAGs. Ou seja, predizer onde inicam e
terminam os genes. Basicamente o programa procura por codons de inicio,
principalmente **ATG**, porém também são codons de iniciação **GTG** e
**TTG**. Depois, o programa procura os codons de parada, como **TAA,
TAG** e **TGA**.

> 🇪🇸 El objetivo de esta etapa es buscar los marcos abiertos de lectura
> o ORF (en inglés) dentro de los MAGs. O sea, predecir donde incian y
> terminan los genes. Basicamente el programa busca por códones de
> inicio, principalmente **ATG**, sin embargo también son códones de
> inico **GTG** e **TTG**. Después, busca los códones de parada, como
> **TAA**, **TAG** y **TGA**.

O programa a usar para a predição das ORFs em procarioros é [Prodigal
(*Prokaryotic Dynamic Programming Gene Fiding
Algorithm*)](https://github.com/hyattpd/Prodigal).

#### 11.1.1 Instalação

Crie um novo ambiente para instalação das ferramentas relacionadas com à
anotação de genes, chamado **Annotation**

    # Crie o ambiente
    conda create -n Annotation

    # Ative o ambiente
    conda activate Annotation

    # Instale Prodigal
    conda install -c bioconda prodigal

#### 11.1.2. Uso

Crie uma pasta chamada `17.GenePrediction` para colocar a saída do
**Prodigal**.

`mkdir 17.GenePrediction`

A continuação encontrara o comando **individual** (Um MAG por vez)

    prodigal -i 13.MAGS/HQ_MQ_MAGs/MAG1.fa -f gff -o 17.GenePrediction/MAG1.gff -a 17.GenePrediction/MAG1.faa -d 17.GenePrediction/MAG1.fa -p single

Se quiser pode rodar a análises para vários MAGs ao mesmo tempo, usando
o seguinte loop:

    for i in 13.MAGS/HQ_MQ_MAGs/*.fa
    do
    BASE=$(basename $i .fa)
    prodigal -i $i -f gff -o 17.GenePrediction/${BASE}.gff -a 17.GenePrediction/${BASE}.faa -d 17.GenePrediction/${BASE}.fa -p single
    done

**SINTAXE**

    prodigal -i genome.fasta -f <gbk, gff, sqn, sco> -o coordfile -a proteins.faa -d nucleotides.fa

-   `-i`: caminho para o genoma em formato `.fasta`, `.fa` ou `.fna`
-   `-f`: formato de saída para o arquivo de coordenadas, default
    `.gbk`(*Genbank-like format*), `.gff` (`Gene Feature Format`),
    `.sqn` (*Sequin feature format*), ou `.sco` (*Simple Coordinate
    Output*)
-   `-o`: arquivo output com as coordenadas das ORFs
-   `-a`: sequências das ORFs em proteína
-   `-d`: sequências das ORFs em nucleotídeos

**Formato `.gff` (Gene Feature Format)**

🇧🇷 Este formato guarda as informações dos genes preditos pelo Prodigal.
Explore-o (`less GenesCoordenates.gff`).

Cada sequência comença com um *header* com as informações da sequência
analizada, seguido de uma tabela separada por tabulações com informações
dos genes encontrados em dita sequência.

O *header* contém os seguentes campos:

> 🇪🇸 Este formato guarda las informaciones de los genes predichos por
> Prodigal. Explorelo (`less GenesCoordenates.gff`).
>
> Cada secuencia comienza con un *header* con las informaciones de la
> secuencia analizada, seguido de una tabla separada por tabulaciones
> con informaciones de los genes encontrados en dicha secuencia.
>
> El *header* contiene los siguientes campos:

-   **seqnum**: O número da sequência, começando pelo número 1.
-   **seqlen**: tamanho em bases da sequência
-   **seqhdr**: título completo da sequência extraído do arquivo
    `.fasta`.
-   **version**: versão do Prodigal usado
-   **run\_type**: modo de corrida, p.e. m*metagenomic*
-   **model**: informação sob o arquivo de treinamento usado para a
    predição.
-   **gc\_cont**: % de GC na sequência
-   **transl\_table**: Tabela do código genético usada para analizar a
    sequência. Para bactérias e archaeas é usada a [tabela
    11](https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi#SG11).
-   **uses\_sd**: 1 se o Prodigal usa o
    *[RBS](https://parts.igem.org/Ribosome_Binding_Sites) finder*, ou 0
    se usa outros *motifs*.

Después do *header* se encuentra una tabla con las informaciones de los
genes encontrados:

-   **seqname**: nome da sequência, neste caso nome do scaffold/contig.

-   **source**: nome do programa que gerou a predição

-   **feature**: tipo de *feature*, p.e. CDS (*Coding DNA Sequence*)

-   **start**: primeira posição da *feature*

-   **end**: útlima posição da *feature*

-   **score**: Valor numerico que geralmente indica a confiança do
    programa na predição da ORF.

-   **strand**: fita do DNA que foi encontrado a *feature*. A fita
    *forward* é definida como ‘+’, e a *reverse* como ‘-’.

-   **frame**: 0 indica que a primeira base da *feature* é a primeira
    base do códon de inicio, 1, que a segunda base da *feature* é a
    primeira base do códon de inicio.

-   **atribute**: información adicional sobre la *feature*, parada por
    ponto e vìrgula “;”.

    -   **ID**: identificador único de cada gene, consistindo em um
        número ordinal ID da sequência e um número ordinal ID do número
        do gene separados por "\_“. Por exemplo”1\_688" siginifa que é o
        gene número 688 da sequência 1.
    -   **partial**: indica se o gene está completo ou não. “0” indica
        que no gene foi encontrado o códon de inicio ou de parada, “01”
        indica que no gene só foi encontrado o cóndon de inicio, “11”
        indica que não foram encontrados nenhum dos dois códons e “00”
        indica que foram encontrados ambos códons.
    -   **start\_type**: sequência do códon de inicio.
    -   **stop\_type**: sequências do códon de parada
    -   **rbs\_motif**: *RBS motif* encontrado pelo Prodigal
    -   **rbs\_spacer**: número de bases entre o códon de inicio e o
        *motif* observado.
    -   **gc\_cont**: Conetúdo de GC no gene
    -   **conf**: nota de confiança pra o gene, representa a
        probabilidade que esse gene seja real.
    -   **score**: *score* total pro gene
    -   **cscore**: fração hexamero do *score*, o quanto este gene se
        parece com uma proteína verdadeira.
    -   **sscore**: *score* para o sitio de inicio da tradução do gene.
        é a soma dos três seguintes *scores*.
    -   **rscore**: *score* pro *RBS motif*
    -   **uscores**: *score* pra sequência em torno do códon de início.
    -   **tscore**: *score* para o tipo de códon de inicio
    -   **mscore**: *score* pros sinais restantes (tipo de códon de
        parada e informações da fita principal / reversa).

Uma vez terminado o processo, pode explorar os diferentes arquivos de
saída para conhecer a fondo a estrutura de cada um deles e as
informações que cada um tem.

### 11.2. Anotação Funcional

A anotação dos genes é feita alinhando as ORFs preditas contra bases de
dados. No caso da anotação funcional, será usado o alinhador
[**Diamond**](https://github.com/bbuchfink/diamond) e as bases de dados
serão [**EggNOG**](http://eggnog5.embl.de/#/app/home) e
[**KEGG**](https://www.kegg.jp/kegg/).

> 🇪🇸La anotación de los genes es realizada alineando las ORFs predichas
> contra bases de dados. En el caso de la anotación funcional será usado
> el programa para alineamiento
> [**Diamond**](https://github.com/bbuchfink/diamond) y las bases de
> datos [**EggNOG**](http://eggnog5.embl.de/#/app/home) y
> [**KEGG**](https://www.kegg.jp/kegg/).

#### 11.2.1 Diamond

##### 11.2.1.1 Obtenção das Bases de Dados

Para a obtenção das bases de dados, pode ir nos sites e descarregar
diretamente. No entanto, tenha em conta que a base de dados **KEGG** é
paga. Se você descarregar direto da fonte, deverá formatar as DBs para o
seu uso com Diamond (anotação funcional). Isto é feito com o comando
`makedb --in reference.fasta -d reference`.

Para facilitar, no seguinte link, você encontrará as bases de dados
**KEGG**, **EggNOG**, previamente formatadas para o uso em Diamond.

Use o programa `gdown` para descarregar as dbs que se encontram em um
GoogleDrive. Se não tiver o `gdown` instalado, siga o seguintes passos:

> 🇪🇸 Para la obtención de las bases de datos, puede ir directamente en
> las páginas web de cada una. Sin embargo, tenga en cuenta que la base
> de datos **KEGG** es paga. Si ud decide descargar directamente de la
> fuente, deberá hacer una formatación de las DBs para el uso con
> Diamond (anotación funcional). Este processo es realizado usando el
> comando `makedb --in reference.fasta -d reference`.
>
> Para facilitar, en el siguiente link, encontrará las bases de
> datos**KEGG**, **EggNOG**, previamente formatadas para su uso en
> Diamond e **Kraken2**.

-   [**Dbs**](https://drive.google.com/drive/folders/1GLP6vA4Gs0cce-nnBXCmZSgmONWybOSF?usp=sharing)

<!-- -->

    ## Se não tiver instalado pip
    sudo apt update
    sudo apt install python3-pip
    pip3 --verision

    ## Instale gdown
    pip install gdown

🇧🇷 Crie uma pasta, chamada `dbs/`, e use o programa `gdown` para
descarregar as dbs.

    # Crie o diretório
    mkdir dbs/

    # Descarregue as DBs

    ## KEGG
    gdown --id 1ZxjJdwh1izP32X5CH-B8SN0DK2WAAAvr

    ##EggNOG
    gdown --id 1x2Kp4PTX8GFFhkJm6EVDQLfi-xRSQ735

Serão descarregados os seguintes arquivos:

-   `eggnog.dmnd`: Base de dados EggNOG formatada para Diammond
-   `keggdb.dmnd`: Base de dados KEGG formatada para Diammond

#### 11.2.1.2 Instalação Diammond

O [**Diamond**](https://github.com/bbuchfink/diamond) será usado para a
anotação funcional. Instale através do conda, no ambiente `Annotation`

    # Active o ambiente
    conda activate Annotation

    # Instalaçao
    conda install -c bioconda diamond=2.0.9

### 11.2.2 Uso

🇧🇷 Uma vez instaladas todas as ferramentas e descarregadas as bases de
dados, pode proceder à anotação. Neste caso será feita primeiro à
funcional, usando Diammond e as bases de dados **KEGG** e **EggNOG**. A
continuação se encontra o comando ndividual (*uma montagem e uma base de
dados por vez*)

> 🇪🇸 Una vez instaladas todas las herramientas y descargadas las bases
> de datos, puede proceder a la anotación. En este caso será hecha
> primero la anotación funcional, usando Diammond e las bases de datos
> **KEGG** e **EggNOG**

    ## Crie uma pasta pra saída
    mkdir 18.FunctionalAnnotation

    ## Diammond
    diamond blastx --more-sensitive --threads 6 -k 1 -f 6 qseqid qlen sseqid sallseqid slen qstart qend sstart send evalue bitscore score length pident qcovhsp --id 60 --query-cover 60 -d dbs/keggdb.dmnd --query 17.GenePrediction/GenesNucl.fa -o 18.FunctionalAnnotation/GenesNucl_kegg.txt --tmpdir /dev/shm

**SINTAXE**

    diamond blastx --more-sensitive --threads -k -f --id --query-cover -d dbs/db.dmnd --query orfs_nucleotides.fa -o annotation.txt --tmpdir /dev/shm

-   `blastx`: Alinha sequências de DNA contra uma base de dados de
    proteínas
-   `--more-sensitive`: este modo permite hits com &gt;40% de
    identidade. Existem outros modos
    `--fast --min-sensitive --very-sensitive --ultra-sensitive`. Clique
    [aqui](https://github.com/bbuchfink/diamond/wiki/3.-Command-line-options)
    para mais detalhes
-   `--threads`: número de núcleos
-   `-k/--max-target-seqs`: Número máximo de sequências *target* por
    *query* para reportar alinheamentos.
-   `-f/--outfmt`: Formato de saída. São aceptos os seguintes valores:
    -   `0` Formato BLAST *pairwise*
    -   `5` fomato BLAST XML
    -   `6` Formato do BLAST tabular (default), pode customizar as
        colunas com uma lista separada por espaços, das seguintes
        opções:
        -   `qseqid` id da sequência *query*
        -   `qlen` tamanho da sequência *query*
        -   `sseqid` id da sequência da base de dados
        -   `sallseqid` todas os id das sequências das bases de dados
        -   `slen` tamanho da sequência da base de dados
        -   `qstart` inicio do alinhamento no *query*
        -   `qend` fim do alinhamento no *query*
        -   `sstart` inicio do alinhamento na sequência da base de dados
        -   `send` fim do alinhamento na sequência da base de dados
        -   `evalue`
        -   `bitscore`
        -   `score`
        -   `length` tamanho do alinhamento
        -   `pident` porcentagem de matches identicos

Com o comando anterior foi feita a anotação do co-assembly de todas as
amostras `scaffolds.fasta` com a base de dados `kegg.dmnd` e os dados
foram guardados no arquivo `kegg_annotation.txt`.

> 🇪🇸 Con el comando anterior fue realizada la anotación del co-assembly
> de todas las muestras `scaffolds.fasta` con la base de datos
> `kegg.dmnd` y los datos fueron guardadas en el archivo
> `GenesNucl_kegg.txt`.

Se tiver mais de uma montagem e quiser rodar todas e as duas bases de
dados ao mesmo tempo, pode usar o seguinte loop `for`:

> 🇪🇸 Si tiene más de un ensamble y quiere correr todos e las dos bases
> de datos al mismo tiempo, puede usar el siguiente loop `for`:

    for i in 17.GenePrediction/*.fa
    do
    BASE=$(basename $i .fa)
      for j in dbs/*.dmnd
      do
      db=$(basename $j .dmnd)
    diamond blastx --more-sensitive --threads 6 -k 1 -f 6 qseqid qlen sseqid sallseqid slen qstart qend sstart send evalue bitscore score length pident qcovhsp --id 60 --query-cover 60 -d $j --query $i -o 18.FunctionalAnnotation/${BASE}_${db}.txt --tmpdir /dev/shm
    done
    done

Com o comando anterior, é feita a anotação em todas as ORFs preditas na
pasta `17.GenePrediction/` com todas as bases de dados para diammond
dentro da pasta `dbs/`. Veja que no loop foram declaradas duas
variavéis, `i` que corresponde a cada um dos arquivos das ORFs
(nucleotídeos) preditas com Prodigal e a variável `j` que corresponde a
cada um dos arquivos terminados em `.dmnd` dentro da pasta `dbs/`, ou
seja as bases de dados `kegg.dmnd` e `eggnog.dmnd`. Os arquivos de saída
são duas tabelas por cada montagem, uma da anotação com *eggnog* e outra
com *kegg*.

> 🇪🇸 Con el comado anterior, es realizada la anotación de todas las ORF
> predichas en el directorio `17.GenePrediction/` con todas las bases de
> datos para Diammond dentro de la carpeta `dbs/`. Vea que en el loop
> fueron declaradas dos variables, `i` que corresponde a cada uno de los
> archivos de las ORFs (nucleótidos) predichos con Prodigal e la
> variable `j` que corresponde a cada uno de los archivos terminados en
> `.dmnd` dentro de la carpeta `dbs/`, o sea las bases de datos
> `kegg.dmnd` y `eggnog.dmnd`. Los archivos de salida son dos tablas por
> cada ensamble, una con la anotación con *eggnog* e otra con *kegg*.

### 11.3 Prokka

[**Prokka**](https://github.com/tseemann/prokka) é uma ferramente
amplamente usada para anotação funcional em genomas.

#### 11.3.1. Instalação

Siga os seguintes comandos para a instalação de **Prokka**:

    # Crie um ambiente e instale prokka
    conda create -y -n prokka prokka==1.14.6

    # Ative o ambiente
    conda activate prokka

    # Instale alguma dependencias adicionais
    conda install -y perl-app-cpanminus
    cpanm Bio::SearchIO::hmmer --force

#### 11.3.2 Uso

**Prokka** tem diferentes nìveis de comandos segundo a expertise do
usuário (iniciante, moderado, especialista, experto, mago, etc). Para
este tutorial usaremos o nível moderado.

O comando para anotar genoma por genoma é:

> 🇪🇸 **Prokka** tiene diferentes níveles de comando según la experticia
> del usuario (iniciante, moderado, especialista, experto, mago, etc).
> Para este tutorial usaremos el nível moderado.
>
> El comando para anotar genoma por genoma

    prokka --outdir 19.Prokka -prefix MAG10 13.MAGS/HQ_MQ_MAGs/MAG10.fa --cpus 6

Ou em loop para automatizar a anotação de todos seus genomas:

    for i in 13.MAGS/HQ_MQ_MAGs/*.fa
    do
    BASE=$(basename $i .fa)
    prokka --outdir 19.Prokka --prefix ${BASE} $i --cpus 6 --force
    done

**SINTAXE**

    prokka --outdir output/ --prefix prefix genome.fa --cpus xx --force

-   `--outdir`: Diretório de saída
-   `--prefix`: prefijo para os outputs
-   `genome.fa`: caminho para o genoma em formato fasta
-   `--cpus`: número de núcleos/threads
-   `--force`: forçar o programa a sobre escrever se a pasta já estiver
    criada.

**Outputs**

-   `.gff`: anotações em formato GFF3, com as sequências e as anotações,
    pode ser visualizado no programa Artemis.
-   `.gbk`: arquivo Genbank derivado do `.gff`. Se o input foi um
    arquivo multifasta, este será um arquivo multi-Genbank
-   `.fna`: sequências input em nucleotídeos
-   `.fna`: arquivo de poteínas com a translação dos CDS
-   `.ffn`: arquivo fasta com todas os transcritos preditos (CDS, rRNA,
    tRNA, tmRNA, misc\_RNA)
-   `.sqn`: anotações formato Sequin
-   `.txt`: Estatísticas relacionadas com as *features* anotadas
-   `.tsv`: tabela com todas as *features* anotadas (locus\_tag, ftype,
    len\_bp, gene, EC\_number, COG, product)

**Nota:** Para mais informações visite o
[GitHub](https://github.com/tseemann/prokka).

#### 11.4. Manipulação de Dados

Após a anotação funcional com Diamond (Kegg e EggNOG) e com Prokka, você
terá três tabelas por MAG com cada base de dados. Para facilitar a
ánalise dessas funções é melhor juntar as tabelas numa só, tengo todas
as anotações de todos os MAGs. Para a unifiação de todas as tabelas é
necessário uma série de passos de formatação a modo de não perder a
trazabilidade das anotações.

**Nota:** Em cada etapa verifique o que foi feito nas tabelas usando o
comando `head` e/ou `tail`.

**1. Separando a terceira coluna**

A terceira coluna das tabelas geradas pelo Diamond, traz o código de
acesso do NCBI e separado por \|, o número KO. Por exemplo: WP00000.0 \|
K00001. O seguinte comando separa essas informações em duas colunas
usando um script de *Perl*:

    cd 18.FunctionalAnnotation


    for i in *.txt; do BASE=$(basename $i .txt); perl -pe 's/\|?(?:\s+gi|ref)?\|\s*/\t/g' $i > ${BASE}_formated.txt; done

Elimine as tabelas iniciais para não poluir a pasta:

    rm *keggdb.txt

    rm *eggnog.txt

**2. Concantenando as anotações com KEGG e EggNOG**

    for i in *_keggdb_formated.txt; do BASE=$(basename $i _keggdb_formated.txt); cat $i ${BASE}_eggnog_formated.txt > ${BASE}; done

**3. Criando uma coluna com o nome do MAG**

Esta etapa consiste em criar uma coluna em cada tabela com o nome do MAG
que corresponda. Para isto é usado no comando o nome do arquivo que
corresponde ao nome do MAG.

    for i in *; do nawk '{print FILENAME"\t"$0}' $i > $i.bk; mv $i.bk $i; done

**4. Concatenando todas as tabelas em uma**

Por último concatene todas as tabelas de anotação dos MAGs em uma só:

    cat * > funcannot.txt

Descarregue [aqui](https://figshare.com/ndownloader/files/33953774) da
tabela `kegg.tsv` que contém todas os níveis jerárquicos e faça upload
dela junto com `funcannot.txt` no ambiente R. A continuação encontra um
[Script do R](https://github.com/khidalgo85/Binning/blob/master/kegg.R)
para trabalhar com as duas tabelas anteriores.

``` r
library(dplyr)
library(stringr)
library(tidyr)


### Lendo a tabela única de anotação funcional
func <- read.delim("FunctionalAnnotation/funcannot.txt", header = F) %>% 
  select(V1,V2,V3,V5,V17) 

### Filtrando só as anotações de KEGG
func.annot.kegg <- func %>% 
  filter(str_detect(V5, "^K")) %>% # Filtra strings que começem com K (i.e. K00001)
  # Renomea as colunas
  rename(Genome = V1, ContigID = V2, length = V3, KO = V5, pident = V17) %>% 
  # converte para data.frame
  as.data.frame()


# Lê a tabela das informações completas do KEGG
kegg <- read.delim("FunctionalAnnotation/kegg.tsv", header = F) %>% 
  rename(KO = V1, Level1 = V2, Level2 = V3, Level3 = V4, GenName = V5)

## Junta as tabelas da anotação do Kegg e as informações dos níveis do KEGG
func.annot.kegg.final <- left_join(func.annot.kegg %>% 
                                     group_by(KO) %>% 
                                     mutate(id = row_number()),
                                   kegg %>% 
                                     group_by(KO) %>% 
                                     mutate(id = row_number()), 
                                   by = c("KO", "id"))

head(func.annot.kegg.final)
#> # A tibble: 6 × 10
#> # Groups:   KO [6]
#>   Genome ContigID         length KO    pident    id Level1 Level2 Level3 GenName
#>   <chr>  <chr>             <int> <chr>  <dbl> <int> <chr>  <chr>  <chr>  <chr>  
#> 1 MAG10  NODE_23_length_…    636 K009…   77.7     1 09100… 09104… 00240… tmk, D…
#> 2 MAG10  NODE_23_length_…   1656 K018…   88.2     1 09100… 09101… 00630… E5.4.9…
#> 3 MAG10  NODE_23_length_…    405 K056…   77.6     1 09100… 09101… 00630… MCEE, …
#> 4 MAG10  NODE_23_length_…   1014 K071…   76.7     1 09190… 09194… 99997… K07139…
#> 5 MAG10  NODE_23_length_…    645 K007…   70.9     1 09100… 09108… 00730… thiE; …
#> 6 MAG10  NODE_23_length_…    783 K031…   90.2     1 09100… 09108… 00730… thiG; …
```

------------------------------------------------------------------------

## Em construção…
