#!/usr/bin/bash

#def. fonctions 

function top10 {
    local file=$1

    #parcourir file et afficher les 10 premiers
    grep -Eo '<tr>.*</tr>' $file | head -n 10 #grep -Eo : utilisation d'expression régulière étendue
    

}

top10 u18h_france