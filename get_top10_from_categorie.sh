#!/usr/bin/bash
#déf. des var. globales
DIR_PATH="." #stockage des fichiers à produire
SEPARATOR=":" #séparateur
CATEGORIE_ACTUELLE=""
NOM_CATEGORIE="" #nom voulu pour le fichier de sortie
FILE_PATH="ascii/classement_permanent" #fic de données par défaut

#def. fonctions 
function top10 {
    local file=$1

    #parcourir file et afficher les 10 premiers
    grep -Eo '<tr>.*</tr>' $file | head -n 10
    #grep -Eo : utilisation d'expression régulière étendue
    
    return 0;

}

#fonction pour récupérer le title (titre du club des joueurs d'un fic)
function get_title_file {
    local nomCategorie=$1
    awk -F"<td>" '{print $3}' $nomCategorie | awk -F"</td>" '{print $1}' 
    #la première partie : on dit que le délimiteur est <td>, et on lui demande d'afficher la 3ème colonne soit le title du club de chaque ligne du fic
    #la deuxième partie : on dit que le délimiteur est </td>, et on lui demande d'afficher la première colonne soit le title du club de chaque ligne du fic
}

#fonction : chercher dans chaque fichier la ligne dont le numéro est fourni en paramètre
function get_line {
    local line_number=$1

    for file in "$DIR_PATH"/*.txt
    do
        RECORD+="$(sed -n "$line_number"p $file):"
    done
    echo $RECORD
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
                    top10 "u16f_france" >> "$DIR_PATH/$NOM_CATEGORIE"_prequalifies
                    ;;
                "u18f")
                    echo "FEMME_U18"
                    CATEGORIE_ACTUELLE="FEMME_U18"
                    NOM_CATEGORIE="u18f"
                    top10 "u18f_france" >> "$DIR_PATH/$NOM_CATEGORIE"_prequalifies
                    ;;
                "u20f")
                    echo "FEMME_U20"
                    CATEGORIE_ACTUELLE="FEMME_U20"
                    NOM_CATEGORIE="u20f"
                    top10 "u20f_france" >> "$DIR_PATH/$NOM_CATEGORIE"_prequalifies
                    ;;
                "u16h")
                    echo "HOMME_U16"
                    CATEGORIE_ACTUELLE="HOMME_U16"
                    NOM_CATEGORIE="u16h"
                    top10 "u16h_france" >> "$DIR_PATH/$NOM_CATEGORIE"_prequalifies
                    ;;
                "u18h")
                    echo "HOMME_U18"
                    CATEGORIE_ACTUELLE="HOMME_U18"
                    NOM_CATEGORIE="u18h"
                    top10 "u18h_france" >> "$DIR_PATH/$NOM_CATEGORIE"_prequalifies
                    ;;
                "u20h")
                    echo "HOMME_U20"
                    CATEGORIE_ACTUELLE="HOMME_U20"
                    NOM_CATEGORIE="u20h"
                    top10 "u20h_france" >> "$DIR_PATH/$NOM_CATEGORIE"_prequalifies
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

#awk -F"<td>" '{print $3}' u16f_prequalifies | awk -F"</td>" '{print $1}'
top10 "$DIR_PATH/$NOM_CATEGORIE"_france > "$DIR_PATH/$NOM_CATEGORIE"_prequalifies
get_title_file "$DIR_PATH/$NOM_CATEGORIE"_prequalifies > titreClub.txt 

awk -F"$SEPARATOR" '

    #fonction pour récupérer le code FFME - dans le fic ascii/clubs - champs1
    function get_code_ffme(nomTitle) {
        found=0
        codeFFME=""

        while ("cat ascii/clubs" | getline && !found) {
            if ($2 == nomTitle) {
                codeFFME=$1
                found=1 #on a trouvé le code FFME
            }
        }

        #si on ne trouve pas le code FFME
        if (!found)
            codeFFME = "N"
        
        close("cat ascii/clubs")
        return codeFFME
    }

    {
        codeFFME = get_code_ffme($1)
        print codeFFME
    }' titreClub.txt > codeFFME.txt


awk -F"$SEPARATOR" '

    #fonction pour récupérer la ligue - champs3 - dans le fic ascii/codeFFME_departements_ligue
    function get_ligue(codeFFME) {
        found=0
        ligue=""

        while ("cat ascii/codeFFME_departements_ligue" | getline && !found) {
            if ($1 == codeFFME) {
                ligue = $3
                found=1 #on a trouvé la ligue
            }
        }

        #si on ne trouve pas la ligue
        if (!found)
            ligue = "N"
        
        close("cat ascii/codeFFME_departements_ligue")
        return ligue
    }

    {
        ligue = get_ligue($1)
        print ligue
    }' codeFFME.txt > listeLigue.txt


awk -F"$SEPARATOR" '

    #fonction pour récupérer la zone- champs1 - dans le fic ascii/zones_ligues_qualifies
    function get_zone(ligue) {
        found=0
        zone=""

        while ("cat ascii/zones_ligues_qualifies" | getline && !found) {
            if ($2== ligue) {
                zone = $1
                found=1 #on a trouvé la zone
            }
        }

        #si on ne trouve pas la zone
        if (!found)
            zone = "N"
        
        close("cat ascii/zones_ligues_qualifies")
        return zone
    }

    {
        zone = get_zone($1)
        print zone
    }' listeLigue.txt > listeZone.txt

get_line 1