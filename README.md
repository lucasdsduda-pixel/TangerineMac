# l’orangerie

Aplicativo pessoal para macOS, inspirado no Open Tangerine e destinado a processamento local de arquivos.

> **Estado do projeto:** esta branch está sendo preparada como uma versão completa para macOS. A compilação e o teste final precisam ser feitos em um Mac com Xcode.

## Requisitos

- macOS 13 ou posterior.
- Xcode compatível com Swift 5.9 ou posterior.
- Espaço livre suficiente para o aplicativo e para os arquivos temporários gerados durante conversões.

## Instalação para desenvolvimento/teste

### 1. Baixar o projeto

No GitHub, abra a branch `l-orangerie` e escolha **Code → Download ZIP**, ou clone o repositório:

```bash
git clone -b l-orangerie https://github.com/lucasdsduda-pixel/TangerineMac.git
cd TangerineMac
```

### 2. Abrir no Xcode

Abra o projeto pelo Xcode:

```bash
open Package.swift
```

No Xcode, aguarde o carregamento dos pacotes/targets e selecione o produto **lOrangerie**.

### 3. Executar

Escolha um destino **My Mac** e pressione **Run (⌘R)**.

Se o Xcode solicitar permissões para acessar arquivos escolhidos pelo usuário, conceda somente as permissões necessárias para os arquivos/pastas que você pretende processar.

## Primeiro uso

1. Abra o **l’orangerie**.
2. Arraste um ou mais arquivos para a janela, quando a ferramenta selecionada aceitar drag-and-drop.
3. Escolha a operação desejada.
4. Configure os parâmetros disponíveis, como formato, qualidade ou tamanho.
5. Selecione a pasta de saída.
6. Inicie o processamento.
7. Confirme os arquivos gerados na pasta de destino.

## Utilização

### Processamento em lote

Adicione vários arquivos à fila sempre que a ferramenta permitir. O processamento deve ocorrer no próprio Mac, sem necessidade de enviar os arquivos para um servidor.

### Imagens

Para conversões de imagem, selecione o formato de saída disponível e, quando aplicável, ajuste:

- qualidade JPEG;
- dimensões/redimensionamento;
- pasta de destino.

### PDF e documentos

Quando uma ferramenta de PDF/documento estiver disponível, selecione os arquivos de entrada, configure as opções apresentadas pela interface e escolha o destino dos resultados.

### Áudio e vídeo

Para mídia, selecione os arquivos e a operação/formato disponível. Arquivos grandes podem exigir espaço temporário adicional e mais tempo de processamento.

### Arquivos compactados

Use as ferramentas de arquivo/compactação para operações suportadas pela versão instalada. Evite processar arquivos de origem que você não possua ou não tenha autorização para modificar.

## Privacidade: operação local

O objetivo do l’orangerie é **não enviar arquivos ou dados pessoais para a Internet**.

A arquitetura desta variante deve manter o processamento no dispositivo e não utilizar:

- upload de arquivos;
- armazenamento em nuvem;
- analytics ou telemetria;
- serviços externos para conversão;
- envio de conteúdo para APIs de terceiros;
- verificação automática de atualizações.

### Como verificar localmente

Para uma verificação adicional, o usuário pode executar o aplicativo sem conexão com a Internet e testar as operações. Também é recomendável revisar as dependências e chamadas de rede do código antes de distribuir qualquer build.

**Importante:** bibliotecas nativas de terceiros usadas para processamento podem ter seus próprios requisitos/licenças. A presença de uma biblioteca local não significa que seus arquivos sejam enviados pela Internet; a implementação final deve ser auditada antes da primeira versão de produção.

## Solução de problemas

### O Xcode não encontra o produto

Feche e reabra `Package.swift`, aguarde a resolução das dependências e confirme que o destino **My Mac** está selecionado.

### O aplicativo não consegue ler/gravar um arquivo

Confirme que o arquivo existe, que você possui permissão para acessá-lo e que a pasta de destino está disponível. Tente selecionar novamente o arquivo/pasta através da interface do aplicativo.

### Uma conversão falha

Verifique se o formato de entrada é suportado pela ferramenta escolhida, se há espaço livre suficiente e se o arquivo de origem não está corrompido.

### O processamento de vídeo/áudio é lento

Isso pode ser normal para arquivos grandes e operações que exigem recodificação. Não interrompa o processo até que a fila indique conclusão ou erro.

## Build do aplicativo

Depois que o projeto completo estiver validado no macOS, o build de distribuição pode ser feito pelo Xcode usando **Product → Archive**. Para uso pessoal, também é possível executar diretamente pelo Xcode.

Não considere um arquivo `.app` como validado apenas por existir: antes de usar uma build de produção, execute as principais operações e confirme que o aplicativo funciona com a rede desconectada.

## Licença

O projeto original utilizado como base é distribuído sob **GPL-3.0**. Os componentes derivados devem manter os termos da licença, avisos de copyright e atribuições exigidos pela licença aplicável. Consulte os arquivos de licença incluídos no repositório antes de redistribuir o aplicativo.

## Projeto original

Open Tangerine: https://github.com/sintaxerrorpvtltd/Open-Tangerine

## Uso pessoal

Este projeto é destinado ao uso pessoal do proprietário do repositório. Antes de redistribuir qualquer build, revise a GPL-3.0 e as licenças de todas as dependências utilizadas.
