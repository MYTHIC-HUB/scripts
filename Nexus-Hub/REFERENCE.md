# Referencia visual do Nexus Hub

As telas enviadas pelo usuario sao a referencia de interface. O nome solicitado
e Nexus Hub e a cor de destaque solicitada e vermelho. O catalogo conserva os
rotulos em ingles que aparecem nas imagens e nao importa o codigo do Pulse Hub.

## Cobertura das imagens

O catalogo inclui Murderer, Sheriff, Visuals, Player, Teleport, Farm, Animations,
Troll, Music, Mobile, Settings e Server. Chat, Pulse Users e Config Hub aparecem
na navegacao, mas suas telas internas nao foram mostradas.

Os subpaineis ESP Presets, Text, Chams, Lights e Look aparecem recolhidos. As
abas World, Weather, Sky, Effects, Auras, Favorites, Configs e About aparecem
apenas como navegacao. Seus controles internos nao foram inventados.

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
- O metodo de farm `Under...`, a caixa `Halloween...` e `Other maps: Dupe...`
  estao truncados nas fotos. O catalogo preserva a grafia observada; a identidade
  completa e o significado dessas opcoes ainda precisam de confirmacao.
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
