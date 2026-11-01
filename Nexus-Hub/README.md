# Nexus Hub

Implementacao original em Luau a partir das capturas enviadas, com o nome Nexus
Hub e destaque vermelho. O arquivo distribuido e `NexusHub.luau`; ele inclui
todos os modulos e nao baixa codigo de terceiros.

## Usar

Carregador publicado:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Pulse-Hubs/scripts/58c1ce5bd39f91fc161d7f3af2c9a1a4aae955ca/Nexus-Hub/NexusHub.luau"))()
```

O carregador usa loadstring e HttpGet fornecidos pelo ambiente do cliente.
No Studio, use o arquivo completo como LocalScript.

`NexusHub.luau` precisa executar no cliente Roblox. No Studio, o mesmo arquivo
pode ser usado como LocalScript em StarterPlayerScripts. Tambem ha um projeto
Rojo para os modulos em `src/`. Um Script do servidor nao possui LocalPlayer.

Use P ou Ctrl direito para mostrar/ocultar. Em telas de toque, use o botao
NEXUS para reabrir e arraste o cabecalho para mover o painel. O menu preserva
duas colunas e ajusta sua escala ao tamanho da tela.

Atualizacao: o Spin possui velocidade de 0 a 100 rad/s. Os limites do farm sao
Fast 24, Under Map 22 e Teleport 26. O limite do slider muda junto com o metodo,
e valores acima do limite sao corrigidos tambem na camada de movimento.
Under Map usa uma pose deitada, movimento sob o mapa e contato para coleta;
Fly pausa o farm e Spin pausa durante Fly/farm para evitar disputa de rotacao.
Fake Korblox usa a perna oficial Korblox Deathspeaker em um overlay local,
preservando as partes e juntas originais do personagem R15. Carregamento
incompleto conserva a perna original.

Foram removidas paginas e subabas vazias que nao tinham conteudo fotografado:
Chat, Nexus Users, Config Hub, World, Weather, Sky, Effects, Auras, Favorites,
Configs e About. Os painéis com funcoes mostradas foram preservados.

Os atalhos fotografados foram registrados: B (Kill All), F (Shot Murder),
V (No Clip), Z (Spin), Q (Bhop), R (Invisible), X (Wall Hop). Um atalho so atua
quando sua funcao possui suporte. Durante Fly, Q fica reservado para descer.

## Cobertura

O catalogo reproduz as paginas, subabas e controles que aparecem nas imagens.
As imagens nao fornecem os protocolos internos de combate, votacao, inventario,
caixas, skins de armas, streaming ou dados privados do hub original.

Os recursos implementados incluem interface, pesquisa, controles de toque,
movimento local, voo, noclip, salto, efeitos locais de aparencia, otimizacoes
reversiveis, animacoes por ID, musica local por Sound ID, ESP por objetos
observados, coleta por objetos identificados, visualizacao de tracers e acoes
de servidor quando as APIs correspondentes existem.

Fontes publicas legiveis tambem documentaram caminhos para dados de papeis,
spawns de lobby/mapa, disparo da arma, ataque de faca de curto alcance e
lancamento automatico. Essas integracoes verificam a presenca das instancias e
classes correspondentes antes de habilitar seus controles. O codigo-fonte
publico nao substitui a validacao na versao do MM2 em execucao.

O painel Webhook aceita uma URL Discord informada no menu quando o ambiente
possui API HTTP. Envio exige ativar Send Farm Stats ou clicar Send Test. O
conteudo usa estatisticas observadas e nao inclui nome, UserId ou Job ID.
Disconnect Alert permanece desativado por falta de evento de desconexao validado.

Controles sem integracao aparecem desativados e mostram o motivo ao tocar.
Eles nao sao simulados como funcionais. Em particular, nao ha equivalencia
completa validada de desync, flings, caixas,
duplicacao de votos, farm por papel ou SoundCloud.
Os pontos de integracao ficam em `context.adapters` de `src/Main.client.luau`.
Receber uma imagem comprova a interface, sem comprovar essas chamadas internas.

Dados de papel recebidos nos caminhos documentados possuem validade curta e
sao distinguidos de inferencias por ferramentas. Sem esses dados, Knife ou Gun
observados fundamentam os indicadores; ausencia dessas ferramentas nao prova
que um jogador seja inocente. Coletores usam
objetos realmente presentes; o contador nao aumenta apenas porque o personagem
se moveu ate uma moeda. Estatisticas sem fonte exibem dados nao confirmados.
O nome Under Map e seus limites foram confirmados posteriormente pelo usuario.

Invisible, Fake Headless, Fake Korblox, roupas, animacoes e musica sao efeitos
locais. A replicacao depende do jogo e do asset. Movimentos locais podem ser
corrigidos pelo servidor. A opcao Anti-Fling limita velocidades locais; nao
garante protecao contra todas as interacoes fisicas.

Fechar pelo X ou Unload restaura as propriedades mantidas pelo hub, remove seus
objetos e desconecta seus eventos. Executar novamente encerra a instancia
anterior antes de criar o novo painel.

## Verificacao e desenvolvimento

`node build.mjs` gera o arquivo unico a partir de `src/`. Nao ha dependencias npm.
Os testes `tests/controller.spec.luau` e `tests/catalog.spec.luau` executam com
o runtime oficial Luau. Eles cobrem integridade do catalogo, validacao de valores,
dispatch, rollback e encerramento do controlador.
`tests/farm-limits.spec.luau` verifica os tres limites, a mudanca de metodo,
rollback, reset e Spin 0-100.
`node tests/movement.mjs CAMINHO_DO_LUAU` executa o motor real de movimento com
objetos de teste e verifica os limites em varias taxas de quadros. Esse teste
nao simula fisica, renderizacao ou validacao de coleta do servidor Roblox.

Skins usam modelos realmente replicados no cliente, preservando Tools e remotes.
Emotes usam o catalogo nativo e Humanoid:PlayEmote; os seletores de animacao
incluem packs Zombie, Robot e Ninja com IDs oficiais. As opcoes de Silent Aim,
tracers de tiros locais e mira de faca exigem as APIs de interceptacao expostas
pelo ambiente. Kill All usa o protocolo da faca e contato quando disponivel;
isso nao e uma confirmacao de eliminacao pelo servidor.

A sintaxe dos modulos e do arquivo unico foi verificada com Luau 0.745.
Renderizacao, comportamento no MM2 atual, coleta, combate e replicacao ainda
exigem verificacao em um cliente Roblox. Nao houve execucao do hub no jogo
neste ambiente.

Os limites de transcricao das imagens estao em `REFERENCE.md`.
