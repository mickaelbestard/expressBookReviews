#!/bin/bash

# =============================================================================
# Script de test — expressBookReviews (IBM Node.js Final Project)
# Génère les fichiers de preuve avec les noms exacts attendus par l'évaluation
#
# Usage : chmod +x run_tests.sh && ./run_tests.sh [HOST] [PORT]
# Exemple : ./run_tests.sh localhost 5000
# =============================================================================

HOST="${1:-localhost}"
PORT="${2:-5000}"
BASE="http://${HOST}:${PORT}"

USER1="testuser1"
PASS1="password123"
USER2="testuser2"
PASS2="password456"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

OUTDIR="./assessement"
mkdir -p "${OUTDIR}"

# Un cookie jar par utilisateur
COOKIE_JAR1=$(mktemp /tmp/cookies1_XXXXXX.txt)
COOKIE_JAR2=$(mktemp /tmp/cookies2_XXXXXX.txt)
trap "rm -f ${COOKIE_JAR1} ${COOKIE_JAR2}" EXIT

section() {
  echo ""
  echo -e "${CYAN}══════════════════════════════════════════${NC}"
  echo -e "${CYAN}  $1${NC}"
  echo -e "${CYAN}══════════════════════════════════════════${NC}"
}

# =============================================================================
# TASK 2 — Liste de tous les livres  →  getallbooks
# =============================================================================
section "TASK 2 — GET /  →  getallbooks"

{
  echo "$ curl -s -X GET ${BASE}/"
  echo ""
  curl -s -X GET "${BASE}/"
  echo ""
} | tee "${OUTDIR}/getallbooks"

# =============================================================================
# TASK 3 — Par ISBN (1 à 10)  →  getbooksbyISBN
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
} | tee "${OUTDIR}/getbooksbyISBN"

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
} | tee "${OUTDIR}/getbooksbyauthor"

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
} | tee "${OUTDIR}/getbooksbytitle"

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
} | tee "${OUTDIR}/getbookreview"

# =============================================================================
# TASK 7 — Inscription  →  register
# =============================================================================
section "TASK 7 — POST /register  →  register"

{
  echo "--- Enregistrement ${USER1} ---"
  echo "$ curl -s -X POST ${BASE}/register -H 'Content-Type: application/json' --data-raw '{\"username\":\"${USER1}\",\"password\":\"${PASS1}\"}'"
  echo ""
  curl -s -X POST "${BASE}/register" \
    -H "Content-Type: application/json" \
    --data-raw "{\"username\":\"${USER1}\",\"password\":\"${PASS1}\"}"
  echo ""

  echo "--- Enregistrement ${USER2} ---"
  echo "$ curl -s -X POST ${BASE}/register -H 'Content-Type: application/json' --data-raw '{\"username\":\"${USER2}\",\"password\":\"${PASS2}\"}'"
  echo ""
  curl -s -X POST "${BASE}/register" \
    -H "Content-Type: application/json" \
    --data-raw "{\"username\":\"${USER2}\",\"password\":\"${PASS2}\"}"
  echo ""
} | tee "${OUTDIR}/register"

# =============================================================================
# TASK 8 — Connexion  →  login
# Chaque user a son propre cookie jar (-c pour écrire, -b pour lire)
# =============================================================================
section "TASK 8 — POST /customer/login  →  login"

{
  echo "--- Login ${USER1} ---"
  echo "$ curl -s -X POST ${BASE}/customer/login -H 'Content-Type: application/json' -c COOKIE_JAR1 --data-raw '{\"username\":\"${USER1}\",\"password\":\"${PASS1}\"}'"
  echo ""
  curl -s -X POST "${BASE}/customer/login" \
    -H "Content-Type: application/json" \
    -c "${COOKIE_JAR1}" \
    --data-raw "{\"username\":\"${USER1}\",\"password\":\"${PASS1}\"}"
  echo ""

  echo "--- Login ${USER2} ---"
  echo "$ curl -s -X POST ${BASE}/customer/login -H 'Content-Type: application/json' -c COOKIE_JAR2 --data-raw '{\"username\":\"${USER2}\",\"password\":\"${PASS2}\"}'"
  echo ""
  curl -s -X POST "${BASE}/customer/login" \
    -H "Content-Type: application/json" \
    -c "${COOKIE_JAR2}" \
    --data-raw "{\"username\":\"${USER2}\",\"password\":\"${PASS2}\"}"
  echo ""
} | tee "${OUTDIR}/login"

# =============================================================================
# TASK 9 — Ajout/modification de review  →  reviewadded
# =============================================================================
section "TASK 9 — PUT /customer/auth/review/:isbn  →  reviewadded"

{
  echo "--- ${USER1} : ajout review ISBN 1 ---"
  echo "$ curl -s -X PUT '${BASE}/customer/auth/review/1?review=Excellent%2C%20un%20classique%20de%20la%20litterature%20africaine.' -b COOKIE_JAR1"
  echo ""
  curl -s -X PUT "${BASE}/customer/auth/review/1?review=Excellent%2C%20un%20classique%20de%20la%20litterature%20africaine." \
    -b "${COOKIE_JAR1}"
  echo ""

  echo "--- ${USER2} : ajout review ISBN 1 (coexistence avec USER1) ---"
  echo "$ curl -s -X PUT '${BASE}/customer/auth/review/1?review=Perspective%20differente%20%3A%20livre%20dense%20mais%20enrichissant.' -b COOKIE_JAR2"
  echo ""
  curl -s -X PUT "${BASE}/customer/auth/review/1?review=Perspective%20differente%20%3A%20livre%20dense%20mais%20enrichissant." \
    -b "${COOKIE_JAR2}"
  echo ""

  echo "--- Verification GET /review/1 (doit afficher les deux reviews) ---"
  echo "$ curl -s -X GET ${BASE}/review/1"
  echo ""
  curl -s -X GET "${BASE}/review/1"
  echo ""

  echo "--- ${USER1} : modification review ISBN 1 ---"
  echo "$ curl -s -X PUT '${BASE}/customer/auth/review/1?review=Review%20mise%20a%20jour%20%3A%20chef-d%20oeuvre%20mais%20difficile%20a%20lire.' -b COOKIE_JAR1"
  echo ""
  curl -s -X PUT "${BASE}/customer/auth/review/1?review=Review%20mise%20a%20jour%20%3A%20chef-d%20oeuvre%20mais%20difficile%20a%20lire." \
    -b "${COOKIE_JAR1}"
  echo ""

  echo "--- Verification GET /review/1 apres modification ---"
  echo "$ curl -s -X GET ${BASE}/review/1"
  echo ""
  curl -s -X GET "${BASE}/review/1"
  echo ""
} | tee "${OUTDIR}/reviewadded"

# =============================================================================
# TASK 10 — Suppression de review  →  deletereview
# =============================================================================
section "TASK 10 — DELETE /customer/auth/review/:isbn  →  deletereview"

{
  echo "--- ${USER1} : suppression review ISBN 1 ---"
  echo "$ curl -s -X DELETE ${BASE}/customer/auth/review/1 -b COOKIE_JAR1"
  echo ""
  curl -s -X DELETE "${BASE}/customer/auth/review/1" \
    -b "${COOKIE_JAR1}"
  echo ""

  echo "--- Verification GET /review/1 (review USER2 doit rester) ---"
  echo "$ curl -s -X GET ${BASE}/review/1"
  echo ""
  curl -s -X GET "${BASE}/review/1"
  echo ""

  echo "--- ${USER2} : suppression review ISBN 1 ---"
  echo "$ curl -s -X DELETE ${BASE}/customer/auth/review/1 -b COOKIE_JAR2"
  echo ""
  curl -s -X DELETE "${BASE}/customer/auth/review/1" \
    -b "${COOKIE_JAR2}"
  echo ""

  echo "--- Verification GET /review/1 (aucune review) ---"
  echo "$ curl -s -X GET ${BASE}/review/1"
  echo ""
  curl -s -X GET "${BASE}/review/1"
  echo ""
} | tee "${OUTDIR}/deletereview"

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