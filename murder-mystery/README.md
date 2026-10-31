# Murder Mystery — Pulse Hubs

Painel roxo e verde claro com Auto farm fast, Under mapa deitado, velocidade do farm de 15 a 29, ESP, busca de arma e ações por função ao confirmar bolsa 50.

Execute o carregador completo no cliente:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Pulse-Hubs/scripts/main/murder-mystery/loader.lua"))()
```

O carregador aguarda o jogo e o jogador local. Se houver falha de download, compilação ou execução, tenta mostrar uma notificação e escreve o motivo no console. Assim, não é necessário colar todo o arquivo principal no editor.

O script compila com o compilador oficial Luau. Isso não confirma funcionamento no Delta/MM2. O tamanho do arquivo, sozinho, não comprova que um limite do executor causou a falha anterior. Os acertos, a coleta e o movimento continuam sujeitos à validação do servidor.

O reset aos 50 exige Inocente confirmado. Xerife, Assassino, Herói e função desconhecida não autorizam reset. Após respawn, é necessário observar uma bolsa abaixo de 50 antes de rearmar as ações. Consulte [LEIA-ME.txt](LEIA-ME.txt) para opções e configuração.
