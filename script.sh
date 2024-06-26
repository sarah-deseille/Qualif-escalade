#!/usr/bin/bash
#déf. des var. globales
DIR_PATH="." #stockage des fichiers à produire
SEPARATOR=":" #séparateur

# gestion des options avec getopts
while getopts "d:f:hc:" opt; do
    case $opt in
    #traiter chaque catégorie passer en paramètres
    c) #echo "${@:2}" #2 -> commence par le deuxième arg (après le -c)
        for i in "${@:2}"
        do
            echo $i
        done
        ;;
    #indique répertoire de stockage des fichiers à produire
    d)
        DIR_PATH=$OPTARG
        ;;
    #indique le chemin du fichier de config
    f)
        FILE_PATH=$OPTARG
        ;;
    #affiche le synopsis du script + s'arrêter
    h)
cat <<HERE >&2 #mise en place d'un here document nommé HERE
Les fonctions possibles sont les suivantes :
    -d : indiquer le répertoire de stockage des fichiers à produire
    -f : indiquer le chemin du fichier de config
HERE
        exit 1
        ;;

    \?) #passe ici quand l'option n'est pas reconnue
    echo "L'option -$OPTARG est invalide" >&2
    exit 1
    ;;

    :) #passe ici quand il manque l'argument d'une option
    echo "L'option -$OPTARG attend un argument" >&2
    exit 1
    ;;
    esac
done

