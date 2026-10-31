# BlueX Hub v1.0

O arquivo `BlueX_Hub_v1.0.txt` contém todo o código Luau, sem módulos, bibliotecas ou downloads obrigatórios. A interface e os controladores estão implementados; **a compatibilidade com o MM2 publicado não foi validada e suas automações não funcionam sem integração autorizada com a experiência**.

## Execução

Em uma experiência que você possa editar no Roblox Studio, crie um **LocalScript** em `StarterPlayer > StarterPlayerScripts` e cole o conteúdo completo do `.txt`. Inicie com Play. O arquivo `.txt` não executa diretamente. Não foi incluído executor ou método de instalar scripts em experiências de terceiros.

Sem integração, o resultado esperado é: interface disponível, Farm inicialmente desligado, ESP visual com cargos desconhecidos, bolsa `?/?` e diagnóstico indicando as funções indisponíveis. Não há sondagem de remotes, inferência de cargos por armas ou leitura de interfaces privadas de MM2.

## Arquitetura

Onze componentes lógicos ficam no mesmo arquivo:

- **UI Manager:** quatro abas, abertura de aproximadamente 2 s, ícones vetoriais, toque, arraste, bolinha e efeitos suspensos ao ocultar.
- **Farm Controller:** estados OFF, WAITING, RUNNING, RECOVERING e ERROR; uma tarefa de movimento por vez e cancelamento por geração.
- **Fast Mode:** estratégia de caminhada normal, velocidade própria e seleção de rotas alcançáveis.
- **Under Map Mode:** estratégia experimental com pontos inferiores explicitamente autorizados e orientação horizontal de costas; sem troca automática para Fast.
- **Coin Tracker:** cache de moedas, limites por rodada, intervalo após falhas e confirmação por recibo específico.
- **Role Tracker:** aceita somente cargos publicados no contrato; ausência de informação produz Unknown.
- **ESP Controller:** Highlight, rótulos, tracers e distância independentes, com limpeza de personagens antigos.
- **Player Controller:** exclusividade de movimento, velocidade manual, postura e colisões restauráveis.
- **Settings Manager:** esquema versionado, validação, JSON e salvamento com debounce.
- **Recovery Manager:** respawn e indicação de inatividade; não simula entradas.
- **Diagnostics Manager:** histórico limitado, supressão de repetições e estado atual do hub.

O adaptador Integration valida o contrato opcional descrito no início do script. Não existe carregamento remoto de código.

## Controles

**Farm:** o seletor contém exatamente Auto Farm Fast e Auto Farm Under Map. Somente a velocidade do modo selecionado aparece. Ambos começam em 24, têm faixa 16–30 e incrementos de 1. Auto Reset e Auto Kill sendo Murderer compartilham preferências entre os modos. O interruptor Ativar Auto Farm solicita execução; WAITING informa quando faltam condições.

**ESP:** quatro controles começam ligados: ESP Cargos, Highlight, ESP Tracers e ESP Distância. Cargos desconhecidos aparecem em cinza. Highlight usa preenchimento com 70% de transparência e AlwaysOnTop. Tracers partem da base da tela e são ocultos para alvos fora da projeção da câmera. O orçamento limita Highlights a 30; rótulos têm distância máxima de 2.000 studs. Atualizações ocorrem a 10 Hz, ou 4 Hz no modo desempenho.

**Player:** Speed Manual começa em 16 e é ajustável entre 16 e 30. Só é aplicada sem controle de Farm e com autorização. Noclip é exclusivamente manual: registra colisões originais, restaura peças removidas e desliga se detectar correção de colisão pelo ambiente. O Under Map não o ativa. Retomar manualmente libera a pausa por inatividade; isso não impede a desconexão automática do Roblox.

**Config:** abertura Premium, efeitos luminosos, modo desempenho e diagnóstico. X e minimizar ocultam somente a janela. A bolinha arrastável reabre a aba anterior. Para encerrar todos os recursos, o protocolo interno Shutdown é utilizado durante reexecução; X não o chama.

## Salvamento e respawn

As preferências ficam no atributo **local** `Player.BlueXHub_Settings_v1`, como JSON `{version=1, values={...}}`. São preservadas em reexecuções na mesma sessão Roblox: velocidades, modo, opções compartilhadas, ESP, aparência, posições, aba e minimização. Noclip e Farm não são restaurados como ativos em nova execução. Dados inválidos, versão incompatível e falhas de escrita são tratados.

**Não há persistência em arquivo ou entre sessões.** O cliente Roblox padrão não oferece essas APIs. DataStore exigiria código e autorização no servidor; não foi simulado. O script não usa `readfile`, `writefile`, `getgenv` ou APIs de executor.

No respawn, a intenção de Farm ativo e o modo são mantidos, mas a execução aguarda personagem vivo, rodada ativa e um snapshot correspondente ao novo personagem. Limites de moedas e reset sobrevivem ao respawn da mesma rodada e a lacunas temporárias de replicação. Farm desligado permanece desligado. A execução antiga é encerrada antes de criar a nova interface; uma segunda inicialização concorrente também é bloqueada.

## Integração e limitações técnicas

Os nomes `BlueXIntegrationV1`, `BlueX_StateV1`, `BlueXCoin` e similares são um **contrato de aplicação definido para esta entrega**, não APIs existentes de Roblox ou de MM2. O cabeçalho do script especifica tipos e campos. Ele exige uma pasta replicada autorizada para o PlaceId atual, snapshots atômicos por jogador/rodada/personagem e permissões explícitas. Cada spawn recebe um `BlueX_CharacterId` único, publicado pelo servidor. Não foi entregue um servidor MM2, pois seus dados e mecanismos não estão disponíveis aqui.

| Recurso | Implementação e limite real |
| --- | --- |
| Fast | PathfindingService + Humanoid:MoveTo. Compara até três rotas entre as seis moedas elegíveis mais próximas e pondera a distância do Murderer conhecido. Sem tags/dados autorizados, não inicia. Velocidade e coleta podem ser restringidas pelo servidor. |
| Confirmação de coleta | Exige recibo autoritativo com coinId exato e sequência posterior à tentativa. Nem desaparecimento visual nem aumento genérico da bolsa comprovam a moeda-alvo. Máximo de duas tentativas por moeda/rodada. |
| Under Map | Exige ponto inferior acessível por caminho normal e autorização de coleta inferior por moeda. AlignOrientation solicita face para cima; não perfura chão, teleporta ou ativa noclip. Caminhada horizontal pode falhar no motor. Falha mantém o modo e fica no diagnóstico, sem notificações de recuperação. Coleta inferior em MM2 não está comprovada. |
| Auto Reset | Só com bolsa cheia e cargo Innocent/Sheriff confirmado. Requer permissão e um RemoteEvent opcional RequestReset implementado pelo servidor da própria experiência. Envia uma solicitação por rodada e aguarda respawn; não afirma que o servidor a aceitou. Nunca reseta Murderer ou cargo desconhecido. |
| Auto Kill | Só com Murderer confirmado, bolsa cheia, permissão, alvo explicitamente autorizado e Tool própria marcada para uso automático. Usa EquipTool/Activate normais, com duas tentativas por alvo/rodada. Condições são revalidadas durante a perseguição e antes da ativação. Não cria dano nem confirma eliminação. Automação integral em MM2 não foi implementada/validada. |
| Cargos e bolsa MM2 | Não disponíveis neste ambiente. Permanecem desconhecidos sem snapshot legítimo. Capacidade não é fixada em 50. |
| Speed e noclip | Alterações locais condicionadas às permissões do contrato. Não garantem aceitação/replicação pelo servidor. Não há bypass de anticheat ou correções. |
| Anti-AFK | Apenas indicação de inatividade e retomada manual. Não evita kick por inatividade. |

Sem integração, as opções continuam visíveis para inspeção, mas ativá-las **não concede permissões ou inventa dados**.

## Verificação

Foi usado o compilador oficial **Luau 0.745**, proveniente de `github.com/luau-lang/luau/releases/tag/0.745`. O script completo passou na compilação de sintaxe/bytecode. O analisador CLI não possui os tipos/globais de Roblox; sua execução não substitui o Script Analysis do Studio.

Os testes determinísticos executam os fragmentos reais de Settings/Core com doubles de serviços, JSON, sinais, vetores e agendamento. Cobrem: validação de integração e snapshots, dados desconhecidos, bolsa/capacidade real, recibos por ID/sequência, duas tentativas/cooldown, velocidades independentes, preferências compartilhadas, esquema e falha de escrita, restauração de velocidade manual, autorização, worker único, ausência de fallback Under Map, limites de reset, condições de combate, respawn, inatividade e custo de rotas. O resultado exato está em `BlueX_Hub_v1.0_VALIDACAO.txt`.

**Não testados:** renderização, áreas de toque, tempo visual real da abertura, rotação de tela, consumo/memória em Android, física/pose Under Map, Pathfinding em um mapa real, recepção do reset pelo servidor, coleta de moedas ou dano de uma Tool. Nenhum teste ocorreu em uma sessão de MM2 ou no Roblox Studio.

Os critérios visuais e de interação 1–5, 7, 10–13, 16–17 exigem validação manual no Studio/mobile. Os critérios de estado/persistência 6, 8–9, 14–15 e 18–22 têm cobertura parcial por testes lógicos; isso não comprova o funcionamento completo no motor. O critério 23 é atendido pela identificação explícita dessas limitações.

Para reproduzir a montagem e a verificação no workspace:

```bash
python3 assemble_bluex.py
tools/luau-0.745/luau-compile --null BlueX_Hub_v1.0.txt
python3 tests/build_tests.py
tools/luau-0.745/luau tests/run_contracts.luau
```

O arquivo principal já está montado e não depende desses arquivos auxiliares para executar no Roblox.
