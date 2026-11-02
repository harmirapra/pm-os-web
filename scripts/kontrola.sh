#!/usr/bin/env bash
# Kontrola obsahu repa pm-os-web (spouští ji CI, jde ji pustit i ručně: bash scripts/kontrola.sh).
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
chyba() { echo "CHYBA: $*"; fail=1; }

for f in public/index.html public/en/index.html public/404.html public/robots.txt public/sitemap.xml \
  public/privacy.html public/cookies.html public/impressum.html \
  public/en/privacy.html public/en/cookies.html public/en/impressum.html \
  public/assets/favicon.svg public/assets/og.png public/assets/og-en.png \
  public/fonts/ibm-plex-sans-var-latin.woff2 public/fonts/ibm-plex-mono-400-latin.woff2; do
  [ -s "$f" ] || chyba "chybí nebo je prázdný soubor $f"
done

grep -rn "DOPLNIT" public >/dev/null 2>&1 && chyba "zbylo DOPLNIT: $(grep -rln DOPLNIT public | tr '\n' ' ')"
grep -rn 'href="#"' public --include=*.html >/dev/null 2>&1 && chyba "zástupné odkazy href=\"#\" v patičce"

[ -e Dockerfile ] && chyba "v kořeni repa je Dockerfile – Railway by přestal používat statický režim"

# Relativní fonts/ a assets/ z právních stránek musí existovat.
for page in public/privacy.html public/cookies.html public/impressum.html public/en/privacy.html public/en/cookies.html public/en/impressum.html; do
  [ -f "$page" ] || continue
  base=$(dirname "$page")
  for r in $(grep -ohE '(\.\./)?(fonts|assets)/[A-Za-z0-9._-]+' "$page" | sort -u); do
    [ -f "$base/$r" ] || chyba "$page odkazuje na $r, neexistuje"
  done
done

# Kanonické adresy a OG obrázky mají mířit na ostrou doménu.
for page in public/index.html public/en/index.html; do
  grep -q 'rel="canonical" href="https://pmos.michalhartman.com/' "$page" || chyba "$page: špatný canonical"
  grep -q 'og:image" content="https://pmos.michalhartman.com/assets/og' "$page" || chyba "$page: špatný og:image"
done

# Do veřejného repa nesmí nic, co tam nepatří.
find . -path ./.git -prune -o \( -name '.env*' -o -name '*.py' -o -name 'NAVRH.md' -o -name '_render-*' -o -name 'screens' \) -print | grep . >/dev/null && chyba "nalezen soubor, který nepatří do repa: $(find . -path ./.git -prune -o \( -name '.env*' -o -name '*.py' -o -name 'NAVRH.md' -o -name '_render-*' -o -name 'screens' \) -print | tr '\n' ' ')"

[ "$fail" = 0 ] && echo "kontrola OK" || exit 1
