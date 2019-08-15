# twebengine-sample
Exemplo relativo ao TWebEngine e TWebChannel

Baixe o fonte nivercomp.prw e o arquivo twebchannel.js ([disponivel aqui](https://github.com/totvs/twebchannel-js)).

Compile ambos em seu ambiente Protheus para execução

# Documentação sobre os componentes:

[TWebEngine](http://tdn.totvs.com/display/tec/twebengine)

[TWebChannel](http://tdn.totvs.com/display/tec/twebchannel)

## Função principal

Na função principal instanciamos os componentes TWebEngine (chromium embedded), TWebChannel (WebSocket) e NiverComp (WebComponent de teste).

Neste mesmo trecho definimos o bloco de código bJsToAdvpl, responsavel por receber as mensagens vindas do JavaScript.

Quanto ao bloco de código bLoadFinish, ele será disparado logo após o término da carga da página HTML feita à partir do método Navigate do componente TWebEngine.

![](https://raw.githubusercontent.com/totvs/twebengine-sample/master/images/mainfunction.png)

## Método Template

No método Template, fazendo uso do command BeginContent e EndContent podemos inserir um bloco de texto HTML de maneira simples.

Este método retorna o HTML principal que será exibido em tela.

![](https://raw.githubusercontent.com/totvs/twebengine-sample/master/images/template.png)

## Métodos Script e Style

Os métodos Script e Style farão exatamente o mesmo, respectivamente inserindo um trecho JavaScript e um CSS.

![](https://raw.githubusercontent.com/totvs/twebengine-sample/master/images/scripts.png)
![](https://raw.githubusercontent.com/totvs/twebengine-sample/master/images/style.png)

## Métodos Get e Set

Os métodos Get e Set irão manter um Vetor com valores utilizados no exemplo, como o nome e as datas de aniversário cadastradas.

![](https://raw.githubusercontent.com/totvs/twebengine-sample/master/images/getter_setter.png)

## Visualização:

Aqui o exemplo sendo executado.

![](https://raw.githubusercontent.com/totvs/twebengine-sample/master/images/screenshot_1.png)
