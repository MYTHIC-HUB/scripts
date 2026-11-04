# Nexus Vault

Painel funcional em portugues para hospedar scripts Lua e entregar carregadores
mediante chaves revogaveis. Implementacao propria; nao replica o codigo ou a
marca do loadmor.net. Nao inclui ofuscacao. Codigo executado no cliente pode ser extraido.

## Executar

Requer Node.js 20 ou superior. Execute `npm ci` para instalar as dependencias.

Configure `NEXUS_ADMIN_PASSWORD` com uma senha de pelo menos 12 caracteres e
execute `npm start`. O endereco local e `http://127.0.0.1:3000`.

Variaveis:

- `PORT`: 3000 por padrao.
- `HOST`: 127.0.0.1 por padrao; use 0.0.0.0 em um container publicado.
- `NEXUS_DATA_DIR`: diretorio persistente para o arquivo `vault.json`.
- `NEXUS_HTTPS=1`: ativa cookie Secure; use em producao atras de HTTPS.
- `NEXUS_ADMIN_PASSWORD`: obrigatoria; nenhuma senha fixa esta incluida.

Para hospedagem, configure essas variaveis no provedor Node, um volume persistente
e HTTPS. Esta implementacao suporta uma unica instancia por diretorio de dados;
nao execute varias replicas escrevendo no mesmo arquivo. Reiniciar o servidor
preserva sessoes, scripts, chaves, revogacoes e contadores no volume. Trocar a
senha do administrador invalida as sessoes anteriores.
Use backups protegidos: o codigo fonte fica no armazenamento do servidor.

## Fluxo

Entre no painel, crie um script, gere uma chave, escolha validade e usos e copie
ou baixe o carregador. A chave completa aparece somente ao ser gerada. O servidor
armazena seu hash. Pause o script, revogue chaves ou atualize o codigo pelo painel.
Revogacao bloqueia entregas futuras, sem apagar copias que ja foram baixadas.

O endpoint de entrega e `/s/<script-id>?key=<chave>`. Uma chave em uma URL e um
segredo de acesso: nao registre query strings em proxies. Limites de usos contam
cada GET autorizado, inclusive recargas. Remova qualquer cache no proxy para `/s/`.
Nao existe dependencia de login do ChatGPT. Para Vercel, `api/index.mjs` usa
Vercel Blob privado com leituras sem cache e escritas condicionais por ETag.
Conecte um Blob store privado e configure NEXUS_ADMIN_PASSWORD na hospedagem.
O armazenamento e compartilhado entre instancias; limites de uso sao atomicos.
Chaves, scripts e sessoes nunca sao armazenados em arquivos publicos do site.

## Verificacao

`npm test` executa os testes HTTP locais de autenticacao, CSRF, cadastro, entrega,
expiracao, revogacao, atualizacao, exclusao isolada, persistencia e concorrencia.
O painel e responsivo; renderizacao em navegador ainda precisa ser verificada.
