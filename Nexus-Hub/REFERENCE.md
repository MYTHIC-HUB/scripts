# Referencia visual do Nexus Hub

As fotos e os videos acessiveis enviados pelo usuario sao a referencia de interface. O nome solicitado
e Nexus Hub e a cor de destaque solicitada e vermelho. O catalogo conserva os
rotulos em ingles que aparecem nas imagens e nao importa o codigo do Pulse Hub.

## Cobertura das imagens

O catalogo inclui Murderer, Sheriff, Visuals, Player, Teleport, Farm, Animations,
Troll, Music, Mobile, Settings e Server. Chat, Pulse Users e Config Hub tinham
apenas nomes na navegacao e foram removidos na revisao solicitada pelo usuario.

Os subpaineis ESP Presets, Text, Chams, Lights e Look aparecem recolhidos. As
abas World, Weather, Sky, Effects, Auras, Favorites, Configs e About aparecem
apenas como navegacao. Seus controles internos nao foram inventados.
As subabas sem conteudo fotografado foram removidas da interface atual.

Foram registrados os controles de movimento, anti-aim, aimbot, tracers, farm,
farm por papel, caixas, webhook, animacoes, emotes, aparencia, musica, botoes de
toque, interface, desempenho e servidor que estao visiveis nas capturas.

## Limites da transcricao

- As fotos mostram estados em uso; nao comprovam os valores padrao do original.
  O Nexus inicia recursos de jogo desligados. Valores numericos reproduzem os
  valores legiveis quando possivel. A escala inicial foi ajustada para 0.8 pelo
  tamanho da nova interface; o menu continua ajustavel.
- Os extremos de varios sliders nao aparecem. Os intervalos do catalogo sao
  limites da nova implementacao, sem alegacao de serem identicos aos originais.
- Menus fechados nao revelam todas as opcoes. Somente opcoes observadas foram
  catalogadas. Raridades PULSE, Ancient e Godly tambem aparecem nos cards.
- O usuario confirmou depois o nome Under Map e os limites: Fast 24, Under Map
  22 e Teleport 26. Tambem confirmou Spin com velocidade ate 100. Essas regras
  prevalecem sobre valores e nomes truncados nas capturas.
- A caixa `Halloween...` e `Other maps: Dupe...` estao truncados nas fotos;
  suas identidades completas e protocolos continuam sem confirmacao.
- Os controles Walk Speed Value, Gravity Value e Hip Height Value sao entradas
  necessarias para os ajustes nomeados, mas seus valores e seus subpaineis nao
  ficam legiveis nas fotos. Estao documentados como escolhas de implementacao.
- As fotos mostram cards de skins, miniaturas de animacoes, capas e musicas,
  sem revelar IDs de assets, endpoints ou arquivos. Nomes nao substituem esses
  dados; os recursos dependentes ficam identificados por capacidade.
- O catalogo de skins registra apenas os nomes legiveis: nao fabrica as 391
  entradas, as 238 facas, as 120 emotes ou as 15 musicas indicadas na interface.
- Os presets de avatar mostram miniaturas, mas os nomes e IDs nao estao legiveis.
  O painel de presets permanece sem entradas inventadas.
- O painel Map Priority mostra uma lista com numeros, imagens e botoes; varios
  nomes estao truncados. O catalogo nao atribui nomes nem prioridades ficticias.
- Botoes de selecao, busca, curtida, repeticao, shuffle, play, anterior e proximo
  foram identificados pelos icones visiveis. Campos de ID sao uma representacao
  funcional dos seletores de assets, sem afirmar equivalencia do catalogo remoto.
- Somente os titulos Auto Bomb Jump e No Clip Button aparecem na parte cortada
  da tela Mobile; seus controles internos nao foram acrescentados.

## Dependencias de comportamento

Imagens comprovam o desenho e os nomes dos controles, sem comprovar remotes,
formatos de chamadas, regras atuais do MM2, permissao de assets ou integracoes
externas. `capability` identifica esses requisitos para a interface mostrar
suporte real, em vez de apresentar uma funcao pendente como implementada.

A integracao deve verificar a presenca e a assinatura do recurso correspondente
antes de executar. A ausencia de uma ferramenta Knife ou Gun no cliente nao
comprova um papel; os marcadores precisam distinguir dados confirmados de
inferencias. Estatisticas devem usar dados observados, sem contadores simulados.

Envio de webhook exige URL fornecida pelo usuario e ativacao explicita no menu.
A montagem e a verificacao do script nao devem enviar mensagens de teste.

## Evidencia adicional de integracao

Foi inspecionado codigo publico, sem executar carregadores ou scripts de
terceiros. As assinaturas documentadas foram reimplementadas e condicionadas a
caminhos e classes existentes no cliente:

- [YARHM 1.20](https://github.com/Joystickplays/psychic-octo-invention/blob/main/source/yarhm/1.20/yarhm.lua): mapa em 5177-5183, disparo da arma em 5494-5500, Stab em 6137-6141 e Throw em 6158-6163.
- [NewMM2](https://github.com/tontov/NewMM2/blob/main/SCRIPT): dados de papeis em 435 e spawns de lobby em 5454.

Os caminhos incluem Remotes.Extras.GetPlayerData (RemoteFunction),
Remotes.Gameplay.PlayerDataChanged (RemoteEvent), RegularLobby.Spawns,
CoinContainer/Spawns no modelo de mapa e remotes associados as ferramentas.
As linhas identificam a versao consultada; essas fontes podem mudar.
Nenhuma dessas chamadas foi validada em uma sessao de MM2 neste ambiente.

## Revisao de integracoes e playlist

Os protocolos de caixas, perfil, nivel e Prestige foram consultados em
[cliente MM2 v1456](https://github.com/tlredz/decompiledGames/tree/0552a0f3502217a1cf89df66be9bd0f153e47fa4/murder-mystery-2/v1456),
especialmente Modules/ShopModule.lua, Modules/ProfileData.lua e Menu/GUI.lua.
A abertura usa OpenCrate(crateId, DataType, currency), com metadados e saldo
validados em tempo de execucao; a contagem depende de item retornado reconhecido.

O pedido mais recente restringiu a playlist a Craudete, de Brancoala.
O usuario esclareceu depois que ela deve ficar na aba Sounds. O HUD compacto,
a ausencia do painel Keybinds e dos avisos de ativacao tambem seguem esse pedido.
A [pagina do artista](https://www.palcomp3.com.br/brancoala/craudete/) fornece
um MP3 publico cujo link respondeu HTTP 200 e audio/mpeg na verificacao.
Somente o endereco e publicado; o arquivo musical nao e redistribuido pelo repo.
O backend SoundCloud preparado foi deixado fora desta versao porque essa
playlist usa o audio diretamente, sem credenciais SoundCloud.

O comportamento Teleport solicitado depois das capturas e lobby -> moeda ->
lobby, com cadencia dependente do slider. Pickup tenta contato e usa movimento
continuo quando necessario; nao faz salto de posicao ate GunDrop. Esses fluxos
possuem testes com objetos simulados; nao houve validacao no cliente MM2.

Nove packs de animacao foram adicionados aos tres iniciais. Os 63 novos IDs
foram consultados em economy.roblox.com/v2/assets/{id}/details: todos retornaram
AssetTypeId 24 e Creator.Id 1. Isso confirma tipo/criador; permissao e reproducao
dependem do cliente, rig e regras do asset em execucao.

## Revisao pelos videos enviados

- 4CIqx0HpnQs, 00:09-00:27: inventario do MM2 com aba Changer, Knife/Gun,
  busca, etiquetas Changer e selecoes separadas a direita. Entre 00:10-00:26,
  Gingerscope/Evergun mostram FX e Gingerscythe/Icecrusher mostram Evo.
- Dfu2Fv59OGQ, 00:06-00:08: a divisoria da barra lateral muda de posicao e os
  cards Trade/Farm passam de duas colunas para uma, sem zoom da janela inteira.
  Em 00:00-00:05 e 00:35-00:39, ESP exibe esqueleto e triangulos direcionais.
- O Teleport Delay 3.0 aparece nessa gravacao, mas o usuario corrigiu que se
  trata de comportamento antigo. O Nexus conserva a especificacao atual de
  velocidade maxima 26 e ciclo lobby -> moeda -> lobby.
- O arquivo SAKS_Qe86tw excedeu 32 MiB e nao foi transferido; nao fundamenta
  controles ou comportamentos desta revisao.

O inventario e os metadados foram conferidos no cliente MM2 v1456 citado acima:
Game.Inventory2/Nav/Main.Weapons.Items e variacoes Game.Inventory e
Lobby.Screens.Inventory/Nav.Main. Item.Image fornece miniaturas; FX e metadados
Evo fornecem os selos. Evergun usa a chave interna TreeGun2023 e Icecrusher,
IceHammer. Um nome ou imagem na database nao prova que o modelo esta replicado.
Por isso, os cards funcionais dependem de modelos observados em tempo de execucao.
As gravacoes nao comprovam replicacao das skins para outros jogadores nem
adicao de itens reais negociaveis.
