# MYTHIC-HUB: áudio autorizado para distribuição

Esta pasta é o ponto de hospedagem configurado no carregador MYTHIC-HUB v7.

Somente publique MP3s que você tenha **direito de redistribuir**. Ter um áudio do TikTok, Spotify ou YouTube não concede esse direito.

Nomes de arquivo esperados pela biblioteca:

- `i-non-mi-innamorero.mp3`
- `1-thing-hoodtrap.mp3`
- `sou-favela.mp3`
- `tseluy.mp3`
- `amor-emmanuel.mp3`

Quando cada MP3 autorizado estiver publicado nesta pasta, o script poderá buscá-lo automaticamente por HTTP e salvar em `MYTHIC-HUB/audio/` na workspace do executor. Usuários não precisam instalar ZIP manualmente.

O player exige as funções de executor `request` ou `game:HttpGet`, `isfile`, `writefile`, `makefolder` e `getcustomasset` (ou equivalente). O resultado também depende das restrições de carregamento do Roblox. O código não contorna permissões de ativos.

**Status:** os cinco arquivos MP3 foram extraídos do ZIP enviado e publicados nesta pasta. Os links de download podem ser usados pelo player; a reprodução no Arceus X Neo ainda precisa de teste em execução real.
