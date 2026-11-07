# Correcao de desempenho do MYTHIC HUB

Ativar varias opcoes do Optimizer iniciava uma varredura completa por opcao. Cada
DescendantAdded tambem criava uma tarefa separada. Agora existe um unico worker
que agrupa pedidos, deduplica instancias recebidas e percorre a hierarquia por
GetChildren. Cada lote processa ate 80 objetos, com verificacao de orcamento de
1,5 ms entre objetos, antes de ceder ao proximo quadro. O custo de uma chamada
individual ao Roblox ainda pode exceder esse orcamento.

O worker para antes de restaurar propriedades no encerramento. As tarefas de
animacao e FPS revalidam o estado depois de esperar. O FPS Unlocker deixa de
sobrescrever o limite escolhido para o modo sem renderizacao 3D.

O carregador libera os blocos apos concatenar e libera a fonte apos compilar.
Uma trava impede downloads simultaneos; repetir a execucao com a janela aberta
retorna a instancia existente. Para recarregar uma versao nova, feche o hub antes.
Os efeitos decorativos de Halloween atualizam no maximo 20 vezes por segundo.
Os demais ajustes existentes de ESP, skins, HUD e menu foram mantidos.

O arquivo de entrada MYTHIC_HUB.lua foi substituido por um carregador direto do
main.lua. A versao anterior enviava inventario e dados de perfil a um webhook,
ocultava as interfaces de troca e oferecia/confirmava armas automaticamente para
uma conta fixa. Esse comportamento foi removido do ponto de entrada. Isso nao
representa uma auditoria completa de todas as funcionalidades e servicos do hub.

## Verificacao

Com Python 3 e os binarios oficiais `luau` e `luau-compile` no PATH, execute na
raiz do repositorio:

```sh
python3 tools/verify_performance.py
```

Verificado com Luau 0.745: compilacao do programa montado, carregador e entrada;
testes de ativacoes em sequencia, orcamento por lote, deduplicacao de instancias,
encerramento, estado desativado, fechamento da aplicacao e reconfiguracao durante
uma varredura. O teste do carregador usa HTTP e tarefas simulados, verifica os
35 blocos e todas as substituicoes, compila a fonte final sem executa-la e testa
reexecucao e recuperacao de falhas.

Nao houve execucao no Roblox nem medicao de FPS, latencia, memoria ou temperatura
em aparelho real. O payload continua proximo de 12,5 MB e o custo das 58
substituicoes preexistentes continua presente. Ainda e necessario comparar a
mesma cena, aparelho e configuracao antes/depois.

## Testar a branch antes do merge

O carregador aceita `getgenv().MYTHIC_HUB_REF` para escolher a mesma revisao de
main.lua e dos blocos. O valor padrao continua sendo `main`. Para a branch desta
correcao, a primeira carga deve vir da mesma branch:

```lua
getgenv().MYTHIC_HUB_REF = "codex/optimizer-worker-fix"
loadstring(game:HttpGet("https://raw.githubusercontent.com/MYTHIC-HUB/scripts/codex/optimizer-worker-fix/MYTHIC-HUB/MYTHIC_HUB.lua"))()
```

Apos o merge, remova a configuracao de revisao para usar `main` normalmente.
Sair do jogo encerra tarefas carregadas pela versao anterior; executar o novo
arquivo nao desfaz trocas ja concluidas nem encerra as tarefas antigas sem um
novo cliente.
