#include "totvs.ch"

/*{Protheus.doc} u_NiverComp
    Funcao de teste para o TWebEngine/TWebChannel
    @author Ricardo Mansano
    @since 14/08/2019
    @see: http://tdn.totvs.com/display/tec/twebengine
          http://tdn.totvs.com/display/tec/twebchannel
    @observation:
          Compativel com SmartClient Desktop(Qt);
                SmartClient HTML(WebApp);
                SmartClient Electron;
*/
function u_NiverComp
    local oWebEngine
    private aNiversLocal := {}
    private oWebChannel, oNiverComp

    oDlg := TWindow():New(0, 0, 800, 600, "WebComponent in AdvPL")
        // WebSocket (comunicacao AdvPL x JavaScript)
        oWebChannel := TWebChannel():New()
        oWebChannel:bJsToAdvpl := {|self,key,value| jsToAdvpl(self,key,value) } 
        oWebChannel:connect()

        // WebEngine (chromium embedded)
        oWebEngine := TWebEngine():New(oDlg,0,0,100,100,/*cUrl*/,oWebChannel:nPort)
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

        // WebComponent de teste
        oNiverComp := NiverComp():Constructor()
        oWebEngine:navigate(;
            iif(oNiverComp:GetOS()=="UNIX", "file://", "")+;
            oNiverComp:mainHTML)
        
        // bLoadFinished sera disparado ao fim da carga da pagina
        // instanciando o bloco de codigo do componente, e tambem um customizado
        oWebEngine:bLoadFinished := {|webengine, url| oNiverComp:OnInit(webengine, url),;
                                                      myLoadFinish(webengine, url) }

    oDlg:Activate("MAXIMIZED")
return

// Funcao customizada que sera disparada apos o termino da carga da pagina
static function myLoadFinish(oWebEngine, url)
    conout("myLoadFinish:")
    conout("Class: " + GetClassName(oWebEngine))
    conout("URL: " + url)
    conout("TempDir: " + oNiverComp::tmp)
return

// Blocos de codigo recebidos via JavaScript
static function jsToAdvpl(self,key,value)
	conout("",;
		"jsToAdvpl->key: " + key,;
           	"jsToAdvpl->value: " + value)

    // ---------------------------------------------------------------
    // Insira aqui o tratamento para as mensagens vindas do JavaScript
    // ---------------------------------------------------------------
    Do Case 
        case key  == "<submit>" // [*Submit]
            aadd( aNiversLocal, StrTokArr(value, ",") )
            oNiverComp:set("aNivers", aNiversLocal, {|| showNiverItens()} )
    
        case key  == "<delItem>" // [*Delete_Item]
            nItem := val(value) // Indice da linha
            ADel( aNiversLocal, nItem )
            ASize( aNiversLocal, len(aNiversLocal)-1 )
            oNiverComp:set("aNivers", aNiversLocal, {|| showNiverItens()})
    EndCase
Return

// Exibe itens inseridos
static function showNiverItens()
    local i, person, niver
    local aNivers := oNiverComp:get("aNivers")
    local cNiverItens := ""

        // [*LoopCreation]
        for i := 1 to len(aNivers)
            person := aNivers[i,1]
            niver := aNivers[i,2]

            // Constroi a linha, ja com o botao para sua propria delecao 
            // [*Material_UI Lite]
            cNiverItens +=;
            "<div class='divLine'>"+;
                "<button onclick='twebchannel.jsToAdvpl(`<delItem>`," +cValTochar(i)+ ")'" +;
                    "class='mdl-button mdl-js-button mdl-button--icon'>"+;
                    "<i class='material-icons'>delete_forever</i>"  +;
                "</button> |"+;
                niver + " | " + person +;
            "</div>"              
        next i

    // "Injeta" itens no DIV HTML (Ajax)
    //oWebEngine:runJavaScript('niver_item.innerHTML="' +cNiverItens+ '"')
    oWebChannel:advplToJS("<niver-new>", cNiverItens)
return

// Classe WebComponent de teste
class NiverComp 
    data mainHTML
    data mainData
    data tmp

    Method Constructor() CONSTRUCTOR
    Method OnInit()     // Instanciado pelo bLoadFinished 
    Method Template()   // HTML inicial
    Method Script()     // JS inicial
    Method Style()      // Style inicial

    Method Get()
    Method Set()

    Method SaveFile(cContent)
    Method GetOS()
endClass

// Construtor
Method Constructor() class NiverComp
    local cMainHTML
    ::tmp := GetTempPath()
    ::mainHTML := ::tmp + lower(getClassName(self)) + ".html"
    ::mainData := {} // Array com as variaveis globais (State)
 
    // ----------------------------------------------------
    // Importante: Compile o twebchannel.js em seu ambiente
    // ----------------------------------------------------
    // Baixa do RPO o arquivo twebchannel.js e salva no TEMP
    // Este arquivo eh responsavel pela comunicacao AdvPL x JS
    h := fCreate(iif(::GetOS()=="UNIX", "l:", "") + ::tmp + "twebchannel.js")
    fWrite(h, GetApoRes("twebchannel.js"))
    fClose(h)

    // HTML principal
    cMainHTML := ::Script() + chr(10) +;
                 ::Style() + chr(10) +;
                 ::Template()

    // Verifica se o HTML principal foi criado
    if !::SaveFile(cMainHTML)
        msgAlert("Arquivo HTML principal nao pode ser criado")
    endif
return

// Instanciado apos a carga da pagina HTML
Method OnInit(webengine, url) class NiverComp
    // Desabilita pintura evitando refreshs desnecessarios
    webengine:SetUpdatesEnable(.F.)

    // -------------------------------------------------------------------
    // Importante: Acoes que dependam da carga devem ser instanciadas aqui
    // -------------------------------------------------------------------

    // Processa mensagens pendentes e reabilita pintura
    ProcessMessages()
    sleep(300)
    webengine:SetUpdatesEnable(.T.)
return

// Pagina HTML inicial
Method Template() class NiverComp
    BeginContent var cHTML
        <head>
            <!-- [*Material_UI Lite] -->
            <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
            <link rel="stylesheet" href="https://code.getmdl.io/1.3.0/material.indigo-pink.min.css">
            <script defer src="https://code.getmdl.io/1.3.0/material.min.js"></script>
        </head>
        <script src="twebchannel.js"></script>
        <script>
            var niver_item

            window.onload = function() {
                niver_item = document.getElementById('niver-item');

                // Fecha conexao entre o AdvPL e o JavaScript via WebSocket
                twebchannel.connect( () => { console.log('Websocket Connected!'); } );
                twebchannel.advplToJs = function(key, value) {

                    // ----------------------------------------------------------
                    // Insira aqui o tratamento para as mensagens vindas do AdvPL
                    // ----------------------------------------------------------
                    if (key === "<script>") {
                        let tag = document.createElement('script');
                        tag.setAttribute("type", "text/javascript");
                        tag.innerText = value;
                        document.getElementsByTagName("head")[0].appendChild(tag);
                    }
                    else if(key === "<niver-new>") {
                        niver_item.innerHTML = value
                    }
                }
            };
        </script>
        <body>
            <!--[*Form]-->
            <form id="niverForm" onSubmit="return onClickSubmit(event, niverForm);" > 
                <!-- [*Material_UI Lite] -->
                <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
                    <input class="mdl-textfield__input" type="text" id="person" value=" ">
                    <label class="mdl-textfield__label" for="person">Aniversariante</label>
                </div>
                <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label"
                      style="max-width: 200px;">
                    <input class="mdl-textfield__input" type="date" id="niver" value="2019-01-01">
                    <label class="mdl-textfield__label" for="niver">Niver</label>
                </div>

                <button class="button" id="btnSubmit">INSERIR</button> <!--[*CustomButton]-->
            </form>

            <div id="niver-item"/>
        <body>
    EndContent
return cHTML

// Scripts
Method Script() class NiverComp
    BeginContent var cScript
        <script>
            // [*Submit]
            onClickSubmit = (e, form) => {
                e.preventDefault()
                
                // Varre itens preenchidos
                let elements = form.elements
                let retToAdvpl = ""
                for(let i = 0 ; i < elements.length ; i++){
                    let item = elements.item(i)
                    if (form.elements[i].type != "submit"){
                        retToAdvpl += item.value

                        // Se o proximo elemento for um submit nao insere o separador
                        if (form.elements[i+1].type != "submit"){
                            retToAdvpl += ","
                        }
                    }
                }

                // Retorna informacoes do Form para o AdvPL
                twebchannel.jsToAdvpl("<submit>", retToAdvpl)
                form.reset()
                document.getElementById("person").focus()
                return false
            }
        </script>
    EndContent
return cScript   

// Estilos
Method Style() class NiverComp
    BeginContent var cStyle
        <style>
            /* [*CustomButton] */
            .button {
                padding: 10px; 
                border-radius: 5px;
                border: none;
                color: #fff;
                background-color: #007bff;
                font-size: 14px;
                width: 100px;
                height: 40px; 
            }
            .button:hover{
                background-color: #0069d9;
            }

            /* [*StyleSheet]*/
            .divLine{
                margin: 0;
                margin-bottom: 2;
                border-bottom-color: #ff0000;
                border-bottom-style: dotted;
                border-bottom-width: 1;
            }
        </style>
    EndContent
return cStyle

// Getter [*Getter_and_Setter]
Method Get(cVarname) class NiverComp
    // Recupera valor do array global (State)
    local nPosBase := AScan( ::mainData, {|x| x[1] == cVarname} )
    if nPosBase > 0
        return ::mainData[nPosBase, 2]
    endif
return ""

// Setter [*Getter_and_Setter]
Method Set(cVarname, xValue, bUpdate) class NiverComp
    // Define/Atualiza valor do array global (State)
    local nPosBase := AScan( ::mainData, {|x| x[1] == cVarname} )
    if nPosBase > 0
        if valType(xValue) == "A"
            ::mainData[nPosBase, 2] := aClone(xValue)
        else
            ::mainData[nPosBase, 2] := xValue
        endif
    else
        Aadd(::mainData, {cVarname, xValue})
    endif
    
    // Dispara bloco de codigo customizado
    // apos atualizacao do valor
    if valtype(bUpdate) == "B"
        eval(bUpdate)
    endif
return

// Salva arquivo em disco
Method SaveFile(cContent) class NiverComp
    local nHdl := fCreate(iif(::GetOS()=="UNIX", "l:", "") + ::mainHTML)
    if nHdl > -1
        fWrite(nHdl, cContent)
        fClose(nHdl)
    else
        return .F.
    endif
return .T.

// Retorna Sistema Operacional em uso
Method GetOS() class NiverComp
    local stringOS := Upper(GetRmtInfo()[2])

    if GetRemoteType() == 0 .or. GetRemoteType() == 1
        return "WINDOWS"
    elseif GetRemoteType() == 2 
        return "UNIX" // Linux ou MacOS		
    elseif GetRemoteType() == 5 
        return "HTML" // Smartclient HTML		
    elseif ("ANDROID" $ stringOS)
        return "ANDROID" 
    elseif ("IPHONEOS" $ stringOS)
        return "IPHONEOS"
    endif    
return ""
