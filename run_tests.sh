#!/bin/bash

# =============================================================================
# Script de test — expressBookReviews (IBM Node.js Final Project)
# Génère les fichiers de preuve avec les noms exacts attendus par l'évaluation
#
# Usage : chmod +x run_tests.sh && ./run_tests.sh [HOST] [PORT]
# Exemple : ./run_tests.sh localhost 5000
#
# Fichiers générés (dans ./assessement/) :
#   getallbooks, getbooksbyISBN, getbooksbyauthor, getbooksbytitle,
#   getbookreview, register, login, reviewadded, deletereview
# =============================================================================

HOST="${1:-localhost}"
PORT="${2:-5000}"
BASE="http://${HOST}:${PORT}"

USER1="testuser1"
PASS1="password123"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

OUTDIR="./assessement"
mkdir -p "$OUTDIR"

COOKIE_JAR=$(mktemp /tmp/cookies_XXXXXX.txt)
trap "rm -f $COOKIE_JAR" EXIT

section() {
  echo ""
  echo -e "${CYAN}══════════════════════════════════════════${NC}"
  echo -e "${CYAN}  $1${NC}"
  echo -e "${CYAN}══════════════════════════════════════════${NC}"
}

label() { echo -e "\n${YELLOW}▶ $1${NC}"; }

# Exécute une commande curl, affiche + sauvegarde dans $OUTDIR/$OUTFILE
# Usage : capture OUTFILE CMD...
capture() {
  local outfile="$OUTDIR/$1"
  shift
  local cmd="$*"
  echo -e "${GREEN}$ ${cmd}${NC}"
  {
    echo "$ ${cmd}"
    echo ""
    eval "$cmd"
    echo ""
  } | tee "$outfile"
  echo -e "(→ sauvegardé dans ${outfile})"
}

# =============================================================================
# TASK 2 — Liste de tous les livres  →  getallbooks
# =============================================================================
section "TASK 2 — GET /  →  getallbooks"

capture "getallbooks" \
  curl -s -X GET "${BASE}/"

# =============================================================================
# TASK 3 — Par ISBN (on teste ISBN 1 à 10, on garde tous dans getbooksbyISBN)
# =============================================================================
section "TASK 3 — GET /isbn/:isbn  →  getbooksbyISBN"

{
  for isbn in $(seq 1 10); do
    echo "--- ISBN ${isbn} ---"
    echo "$ curl -s -X GET ${BASE}/isbn/${isbn}"
    echo ""
    curl -s -X GET "${BASE}/isbn/${isbn}"
    echo ""
  done
} | tee "$OUTDIR/getbooksbyISBN"
echo "(→ sauvegardé dans $OUTDIR/getbooksbyISBN)"

# =============================================================================
# TASK 4 — Par auteur  →  getbooksbyauthor
# =============================================================================
section "TASK 4 — GET /author/:author  →  getbooksbyauthor"

{
  for author in "Chinua%20Achebe" "Hans%20Christian%20Andersen" "Dante%20Alighieri" "Unknown" "Leo%20Tolstoy" "Fyodor%20Dostoevsky"; do
    echo "--- author: ${author} ---"
    echo "$ curl -s -X GET ${BASE}/author/${author}"
    echo ""
    curl -s -X GET "${BASE}/author/${author}"
    echo ""
  done
} | tee "$OUTDIR/getbooksbyauthor"
echo "(→ sauvegardé dans $OUTDIR/getbooksbyauthor)"

# =============================================================================
# TASK 5 — Par titre  →  getbooksbytitle
# =============================================================================
section "TASK 5 — GET /title/:title  →  getbooksbytitle"

{
  for title in "Things%20Fall%20Apart" "Fairy%20tales" "The%20Divine%20Comedy" "The%20Epic%20Of%20Gilgamesh" "The%20Book%20Of%20Job" "One%20Thousand%20and%20One%20Nights"; do
    echo "--- title: ${title} ---"
    echo "$ curl -s -X GET ${BASE}/title/${title}"
    echo ""
    curl -s -X GET "${BASE}/title/${title}"
    echo ""
  done
} | tee "$OUTDIR/getbooksbytitle"
echo "(→ sauvegardé dans $OUTDIR/getbooksbytitle)"

# =============================================================================
# TASK 6 — Reviews initiales  →  getbookreview
# =============================================================================
section "TASK 6 — GET /review/:isbn  →  getbookreview"

{
  for isbn in $(seq 1 10); do
    echo "--- review ISBN ${isbn} ---"
    echo "$ curl -s -X GET ${BASE}/review/${isbn}"
    echo ""
    curl -s -X GET "${BASE}/review/${isbn}"
    echo ""
  done
} | tee "$OUTDIR/getbookreview"
echo "(→ sauvegardé dans $OUTDIR/getbookreview)"

# =============================================================================
# TASK 7 — Inscription  →  register
# =============================================================================
section "TASK 7 — POST /register  →  register"

capture "register" \
  curl -s -X POST "${BASE}/register" \
    -H "'Content-Type: application/json'" \
    -d "'{\"username\":\"${USER1}\",\"password\":\"${PASS1}\"}'"

# =============================================================================
# TASK 8 — Connexion  →  login
# =============================================================================
section "TASK 8 — POST /customer/login  →  login"

capture "login" \
  curl -s -X POST "${BASE}/customer/login" \
    -H "'Content-Type: application/json'" \
    -c "${COOKIE_JAR}" \
    -d "'{\"username\":\"${USER1}\",\"password\":\"${PASS1}\"}'"

# Si le cookie_jar est vide (première tentative a échoué), réessai sans -c
if [ ! -s "$COOKIE_JAR" ]; then
  echo "⚠ Cookie jar vide — nouvelle tentative login..."
  curl -s -X POST "${BASE}/customer/login" \
    -H "Content-Type: application/json" \
    -c "$COOKIE_JAR" \
    -d "{\"username\":\"${USER1}\",\"password\":\"${PASS1}\"}" > /dev/null
fi

# =============================================================================
# TASK 9 — Ajout/modification de review  →  reviewadded
# =============================================================================
section "TASK 9 — PUT /customer/auth/review/:isbn  →  reviewadded"

{
  echo "--- Ajout review ISBN 1 ---"
  CMD="curl -s -X PUT ${BASE}/customer/auth/review/1 -H 'Content-Type: application/json' -b ${COOKIE_JAR} -d '{\"review\":\"Excellent livre, un classique de la littérature africaine.\"}'"
  echo "$ ${CMD}"
  echo ""
  eval "$CMD"
  echo ""

  echo "--- Modification review ISBN 1 (même user) ---"
  CMD2="curl -s -X PUT ${BASE}/customer/auth/review/1 -H 'Content-Type: application/json' -b ${COOKIE_JAR} -d '{\"review\":\"Review mise à jour : chef-d oeuvre, mais dense à lire.\"}'"
  echo "$ ${CMD2}"
  echo ""
  eval "$CMD2"
  echo ""

  echo "--- Vérification GET /review/1 après ajout ---"
  echo "$ curl -s -X GET ${BASE}/review/1"
  echo ""
  curl -s -X GET "${BASE}/review/1"
  echo ""

  echo "--- Ajout review ISBN 2 ---"
  CMD3="curl -s -X PUT ${BASE}/customer/auth/review/2 -H 'Content-Type: application/json' -b ${COOKIE_JAR} -d '{\"review\":\"Les contes d Andersen sont magiques.\"}'"
  echo "$ ${CMD3}"
  echo ""
  eval "$CMD3"
  echo ""
} | tee "$OUTDIR/reviewadded"
echo "(→ sauvegardé dans $OUTDIR/reviewadded)"

# =============================================================================
# TASK 10 — Suppression de review  →  deletereview
# =============================================================================
section "TASK 10 — DELETE /customer/auth/review/:isbn  →  deletereview"

{
  echo "--- Suppression review ISBN 1 ---"
  CMD="curl -s -X DELETE ${BASE}/customer/auth/review/1 -b ${COOKIE_JAR}"
  echo "$ ${CMD}"
  echo ""
  eval "$CMD"
  echo ""

  echo "--- Vérification GET /review/1 après suppression ---"
  echo "$ curl -s -X GET ${BASE}/review/1"
  echo ""
  curl -s -X GET "${BASE}/review/1"
  echo ""

  echo "--- Suppression review ISBN 2 ---"
  CMD2="curl -s -X DELETE ${BASE}/customer/auth/review/2 -b ${COOKIE_JAR}"
  echo "$ ${CMD2}"
  echo ""
  eval "$CMD2"
  echo ""
} | tee "$OUTDIR/deletereview"
echo "(→ sauvegardé dans $OUTDIR/deletereview)"

# =============================================================================
# RÉSUMÉ
# =============================================================================
section "✅ Génération terminée"
echo ""
echo "Fichiers produits dans ${OUTDIR}/ :"
echo ""
for f in getallbooks getbooksbyISBN getbooksbyauthor getbooksbytitle getbookreview register login reviewadded deletereview; do
  if [ -f "${OUTDIR}/${f}" ]; then
    size=$(wc -c < "${OUTDIR}/${f}")
    echo "  ✔  ${f}  (${size} octets)"
  else
    echo "  ✘  ${f}  MANQUANT"
  fi
done

echo ""
echo "⚠ TASK 1 (githubrepo) : capture manuelle — faire :"
echo "   curl -s https://api.github.com/repos/mickaelbestard/expressBookReviews | grep -E '\"full_name\"|\"fork\"|\"parent\"' > assessement/githubrepo"
echo ""
echo "⚠ TASK 11 : soumettre l'URL GitHub de final_project/router/general.js"
