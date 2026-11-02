# Nexus Hub

Implementacao original em Luau a partir das capturas enviadas, com o nome Nexus
Hub e destaque vermelho. O arquivo distribuido e `NexusHub.luau`; ele inclui
todos os modulos e nao baixa codigo de terceiros.

## Usar

Carregador publicado:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Pulse-Hubs/scripts/624cc637887e930c780756c4d206105d8e18c515/Nexus-Hub/NexusHub.luau"))()
```

O carregador usa loadstring e HttpGet fornecidos pelo ambiente do cliente.
No Studio, use o arquivo completo como LocalScript.

`NexusHub.luau` precisa executar no cliente Roblox. No Studio, o mesmo arquivo
pode ser usado como LocalScript em StarterPlayerScripts. Tambem ha um projeto
Rojo para os modulos em `src/`. Um Script do servidor nao possui LocalPlayer.

Use P ou Ctrl direito para mostrar/ocultar. Em telas de toque, use o botao
NEXUS para reabrir e arraste o cabecalho para mover o painel. O menu preserva
duas colunas nas paginas de controles e largura completa em Music, Animations e
no catalogo de skins. A escala acompanha o tamanho da tela. O HUD de FPS/ping
foi reduzido; o painel flutuante Keybinds e os avisos rotineiros de ativacao foram
removidos. Falhas aparecem somente no rodape interno do menu.

Atualizacao: o Spin possui velocidade de 0 a 100 rad/s. Os limites do farm sao
Fast 24, Under Map 22 e Teleport 26. O limite do slider muda junto com o metodo,
e valores acima do limite sao corrigidos tambem na camada de movimento.
Under Map usa uma pose deitada, movimento sob o mapa e contato para coleta;
Fly pausa o farm e Spin pausa durante Fly/farm para evitar disputa de rotacao.
O intervalo apos contato foi reduzido para 0.10 s em Fast e 0.12 s em Under Map,
com 0.025 s entre alvos. Teleport espera no lobby, visita a moeda e retorna ao
lobby apos 0.08 s; o slider controla a cadencia (4/speed segundos, teto 26).
Os tempos de contato nao garantem que o servidor confirmou a coleta.
Auto Pickup Gun tenta contato sem reposicionar o personagem e, se necessario,
segue uma rota continua ate a arma. A rota tem prioridade sobre a coleta e pode
ser interrompida ao desligar o pickup automatico. Nao ha salto de posicao para a arma.
O disparo de bolsa cheia usa um fluxo separado sem mover a camera ou resetar o
personagem, com uma solicitacao por vez e descarte de estados antigos ao renascer.
Reset automatico requer um adapter confirmado; nenhum sinal Player.Kill e usado.
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

Integracoes adicionadas: caixas pelo catalogo Shop.Weapons do jogo, selecao de
moeda e saldo real, abertura manual/automatica com uma solicitacao por vez,
animacao nativa, Prestige elegivel e acoes de bolsa cheia. Novos dados observados
de caixas e papeis possuem prioridade sobre os indicadores genericos.
Anti Aim/Desync agora possui uma janela temporaria de pose e velocidade com
restauracao antes da camera. Seus efeitos na replicacao ainda precisam de um
teste com outros clientes; os testes locais verificam restauracao e conflitos.

Os recursos implementados incluem interface, pesquisa, controles de toque,
movimento local, voo, noclip, salto, efeitos locais de aparencia, otimizacoes
reversiveis, animacoes por ID, a musica local Craudete, ESP por objetos
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
completa validada de replicacao do Desync, flings e duplicacao de votos.
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
Os testes farmflow cobrem a visita Teleport com retorno ao lobby, cancelamento
de estados antigos, pickup sem salto e disparo sem alteracao de camera/posicao.
O teste integrations-bag verifica prioridade, tentativas limitadas, exclusao de
reset junto com disparo e cancelamento ao terminar rodada/renascer/descarregar.
Os testes integrations-rules e integrations-lifecycle verificam dados de caixas,
saldo, recompensa reconhecida e cancelamento de compras agendadas sem usar RPC.
Os testes Desync verificam restauracao de frames, OFF, respawn e unload.

## Musica solicitada

A playlist contem somente **Craudete - Brancoala**, na aba **Music > Sounds**,
conforme a ultima correcao do usuario.
Fonte: [pagina do artista no Palco MP3](https://www.palcomp3.com.br/brancoala/craudete/).
O audio permanece na CDN do artista; nenhum MP3 foi incluido no repositorio.
O primeiro Play carrega o arquivo para `NexusHub/audio/craudete.mp3` no ambiente
do cliente, usando HTTP, writefile e getcustomasset/getsynasset. O arquivo e
validado antes de tocar. O carregamento nao acontece durante a montagem ou os
testes. A guia SoundCloud foi removida; os efeitos continuam em Boombox.
Nao e necessario cadastro SoundCloud para essa playlist.

Skins usam modelos realmente replicados no cliente, preservando Tools e remotes.
Emotes usam o catalogo nativo e Humanoid:PlayEmote; os seletores de animacao
incluem 12 packs: Zombie, Robot, Ninja, Stylish, Bubbly, Cartoony, Levitation,
Astronaut, Vampire, Werewolf, Mage e Toy. Os 63 clipes dos nove packs novos
foram confirmados como animacoes do criador Roblox pela API Economy.
As opcoes de Silent Aim,
tracers de tiros locais e mira de faca exigem as APIs de interceptacao expostas
pelo ambiente. Kill All usa o protocolo da faca e contato quando disponivel;
isso nao e uma confirmacao de eliminacao pelo servidor.

A sintaxe dos modulos e do arquivo unico foi verificada com Luau 0.745.
Renderizacao, comportamento no MM2 atual, coleta, combate e replicacao ainda
exigem verificacao em um cliente Roblox. Nao houve execucao do hub no jogo
neste ambiente.

Os limites de transcricao das imagens estao em `REFERENCE.md`.
