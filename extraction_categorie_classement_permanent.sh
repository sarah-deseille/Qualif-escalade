#!/usr/bin/bash
#déf. des var. globales
DIR_PATH="." #stockage des fichiers à produire
SEPARATOR=":" #séparateur
#U16F="FEMME_U16"
CATEGORIE_ACTUELLE=""
NOM_CATEGORIE="" #nom voulu pour le fichier de sortie

#def. fonctions

#but : trouver la catégorie nommée dans le fic.
# $1 : nom de la catégorie
# $2 : chemin du fichier de données 
# return : 0 si trouvé, 1 sinon
function find_category {
    local category=$1
    local file=$2
    local categorie_found=1

    OLDIFS=$IFS #sauvegarde de la valeur de IFS, IFS = Internal Field Separator (variable interne)
    IFS=$'\n' #IFS est un caractère de séparation interne

    while read -r ligne
    do
        if grep -q "$category" <<< $ligne # <<< permet de dire à grep de parcourir ligne par ligne.
        then
            categorie_found=0
            break
        fi
    done < $file
    
    IFS=$OLDIFS #restauration de la valeur de IFS
    return $categorie_found
}


#but : extraire les enregistrement d'une catégorie
function extract_category_record {
    local category=$1
    local file=$2
    local categorie_found=1
    local tbody_found=1 #drapeau pour commencer à chercher tbody

    OLDIFS=$IFS #sauvegarde de la valeur de IFS, IFS = Internal Field Separator (variable interne)
    IFS=$'\n' #IFS est un caractère de séparation interne

    while read -r ligne
    do
        if grep -q "id=\"$category" <<< $ligne # <<< permet de dire à grep de parcourir ligne par ligne.
        then
            categorie_found=0
            #si je trouve, j'affiche la ligne
            #echo $ligne
            echo "catégorie trouvée"
        fi

        if [ "$categorie_found" -eq 0 ] 
        then
            if grep -q '<tbody>' <<< $ligne # trouver tbody -> enregistrement de la catégorie
            then
                tbody_found=0 #j'ai trouvé tbody
                echo "tbody trouvé"
            fi
        fi

        #les deux conditions sont présentes : cat trouvé et tbodu trouvé
        if [[ $categorie_found -eq 0 ]] && [[ $tbody_found -eq 0 ]]
        then
            if grep -q '</tbody>' <<< $ligne # trouver tbody -> enregistrement de la catégorie
            then
                categorie_found=1
                tbody_found=1
                echo "fin de tbody trouvé"
                break
            else
                echo "$ligne" >> "$DIR_PATH/$NOM_CATEGORIE"_france.txt
            fi
        fi
    done < $file
    
    IFS=$OLDIFS #restauration de la valeur de IFS
    return $categorie_found
}

# gestion des options avec getopts
while getopts "d:f:hc:" opt; do
    case $opt in
    #traiter chaque catégorie passer en paramètres
    c) #echo "${@:2}" #2 -> commence par le deuxième arg (après le -c)
        for i in "${@:2}"
        do
            echo $i
            #switch case pour traiter chaque catégorie
            case $i in
                "u16f")
                    echo "FEMME_U16"
                    CATEGORIE_ACTUELLE="FEMME_U16"
                    NOM_CATEGORIE="u16f"
                    ;;
                "u18f")
                    echo "FEMME_U18"
                    CATEGORIE_ACTUELLE="FEMME_U18"
                    NOM_CATEGORIE="u18f"
                    ;;
                "u20f")
                    echo "FEMME_U20"
                    CATEGORIE_ACTUELLE="FEMME_U20"
                    NOM_CATEGORIE="u20f"
                    ;;
                "u16h")
                    echo "HOMME_U16"
                    CATEGORIE_ACTUELLE="HOMME_U16"
                    NOM_CATEGORIE="u16h"
                    ;;
                "u18h")
                    echo "HOMME_U18"
                    CATEGORIE_ACTUELLE="HOMME_U18"
                    NOM_CATEGORIE="u18h"
                    ;;
                "u20h")
                    echo "HOMME_U20"
                    CATEGORIE_ACTUELLE="HOMME_U20"
                    NOM_CATEGORIE="u20h"
                    ;;
                *)
                    echo "catégorie non reconnue"
                    ;;
            esac
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

#test de la fonction find_category
# if find_category "$U16F" "ascii/classement_permanent"
# then
#     echo "cat1 trouvée"
# else
#     echo "cat1 non trouvée"
# fi

extract_category_record "$CATEGORIE_ACTUELLE" "ascii/classement_permanent"