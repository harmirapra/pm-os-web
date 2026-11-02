# pm-os-web

Veřejná jednostránková prezentace pm-os (česky `/`, anglicky `/en/`).
Statický web: Railway (Railpack) sám najde složku `public/` a servíruje ji pomocí Caddy.
Bez Dockerfile, bez buildu. Obsah `public/` se generuje skriptem `deploy/sync.sh` v projektu
PACT – ručně ho neupravuj. Změny jdou přes pull request (CI job `kontrola`).
