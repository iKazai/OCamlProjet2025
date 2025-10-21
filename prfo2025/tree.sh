#!/bin/bash

# Script : tree_project.sh
# Description : Affiche l'arborescence du projet en cours (sans utiliser 'tree')

# Dossier cible (par défaut, le répertoire courant)
DIR=${1:-.}

echo "Arborescence du projet : $DIR"
echo "----------------------------------------"

# Utilisation de 'find' et 'sed' pour afficher une structure arborescente
find "$DIR" | sed -e "s|[^/]*/|   |g" -e "s|--- | |"

echo "----------------------------------------"
