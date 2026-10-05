#!/usr/bin/env bash
# Création du projet VideoTrends : squelette Next.js + dépôt GitHub.
# Usage : placer ce script et CLAUDE.md dans le même dossier, puis lancer :
#   bash setup-videotrends.sh            (dépôt privé par défaut)
#   VISIBILITY=public bash setup-videotrends.sh
set -euo pipefail

NAME="videotrends"
VISIBILITY="${VISIBILITY:-private}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for cmd in node npm git; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Erreur : '$cmd' est requis."; exit 1; }
done

if [ ! -f "$HERE/CLAUDE.md" ]; then
  echo "Erreur : CLAUDE.md introuvable à côté du script."
  exit 1
fi

if [ -e "$HERE/$NAME" ]; then
  echo "Erreur : le dossier '$NAME' existe déjà ici."
  exit 1
fi

echo "1/4 Génération du squelette Next.js (TypeScript, Tailwind, ESLint, App Router)..."
cd "$HERE"
npx create-next-app@latest "$NAME" \
  --typescript --tailwind --eslint --app --src-dir \
  --import-alias "@/*" --use-npm --yes

echo "2/4 Ajout de CLAUDE.md..."
cp "$HERE/CLAUDE.md" "$HERE/$NAME/CLAUDE.md"
cd "$HERE/$NAME"

# create-next-app initialise déjà git ; on sécurise le cas contraire.
[ -d .git ] || git init -b main

echo "3/4 Commit initial..."
git add .
git commit -m "Initialisation du projet VideoTrends" || echo "(rien à committer)"

echo "4/4 Création du dépôt GitHub ($VISIBILITY)..."
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh repo create "$NAME" "--$VISIBILITY" --source=. --remote=origin --push
  echo "Dépôt créé et poussé."
else
  echo "GitHub CLI (gh) absent ou non connecté."
  echo "Fais ceci à la main :"
  echo "  1. Crée le dépôt vide '$NAME' sur https://github.com/new (sans README)."
  echo "  2. Dans $(pwd) :"
  echo "     git remote add origin git@github.com:<ton-compte>/$NAME.git"
  echo "     git push -u origin main"
fi

echo
echo "Vérification : lance 'cd $NAME && npm run dev' puis ouvre http://localhost:3000"
