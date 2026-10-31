# Murder Mystery 2.3 — Pulse Hubs

Painel roxo e verde claro com Auto farm fast, Under mapa deitado, velocidade do farm de 15 a 29, ESP, busca de arma e ações por função ao confirmar bolsa 50.

Farm e pickup aguardam no lobby e usam somente alvos do mapa da partida confirmada. O pickup teleporta até a arma e volta à posição exata do farm. Reset aos 50 só é armado após observar uma bolsa abaixo de 50 na partida atual; ativar com uma leitura antiga de 50 não dispara reset.

O farm confirma participação pelo mapa e posição, junto de um sinal explícito, interface visível ou função confirmada. A interface CoinBags não é obrigatória quando existe outra confirmação. Reset e ataques continuam exigindo função confirmada. A descoberta aceita mapas em pastas, contêineres plurais e hitboxes de coleta com nomes variáveis dentro dos contêineres de moedas. Quando faltar alvo, o rodapé mostra quantos foram reconhecidos e quantos estão elegíveis; falhas dos callbacks são mostradas no painel.

Execute o carregador completo no cliente:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Pulse-Hubs/scripts/main/murder-mystery/loader.lua"))()
```

O carregador aguarda o jogo e o jogador local. Se houver falha de download, compilação ou execução, tenta mostrar uma notificação e escreve o motivo no console. Assim, não é necessário colar todo o arquivo principal no editor.

O script compila com o compilador oficial Luau. Os testes locais simulam lobby, partida, retorno de pickup e armar o reset; não executam a física real do Delta/MM2. Os acertos, a coleta e o movimento continuam sujeitos à validação do servidor.

O reset aos 50 exige Inocente confirmado. Xerife, Assassino, Herói e função desconhecida não autorizam reset. Sair da partida, mudar de rodada, respawnar ou reativar a opção exige uma nova leitura abaixo de 50. Consulte [LEIA-ME.txt](LEIA-ME.txt) para opções e configuração.
