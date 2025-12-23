# Phase 1 :
Difficultés rencontrées :
CHoisir la représentation de données la plus adaptée au projet. 
Choix de graphes dynamique pour représenter la base.

J'étais parti sur un type VERTEX_TYPE qui ne servait à rien et qui complexifiait le projet je l'ai enlevé et tout va mieux

1. choisir le type du graphe
2. l'implémenter 
3. implémenter dijkstra 
4. faire le main 
6. faire des tests (make test lance les tests)


# Phase 2 :

Mettre en place un fichier test avec 10 transitions et 5 individus

Pour un trajets à n modules on aura n-1 temps car le dernier n'est pas traversé

Ajout d'une fonction neighbours car on ne peut pas utiliser Hashtbl.find_opt directement sur un graph

Si j'ai un chemin de type A -> B avec A ou B qui n'existe pas ca marche quand meme, il faudrait régler ca en faisant la vérification du chemin plus tôt

