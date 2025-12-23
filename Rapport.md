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

## je viens de comprendre qu'il faut renvoyer les nouveaux chemins avec les start_times modifié pour que les traversements soient possibles en itérant un ordonnancement donc en faisant tourner une simulation et en règlant les conflits de tunnels

Mettre en place un fichier test avec 10 transitions et 5 individus

Pour un trajets à $n$ modules on aura $n-1$ temps car le dernier n'est pas traversé

Ajout d'une fonction neighbours car on ne peut pas utiliser Hashtbl.find_opt directement sur un graph

Si j'ai un chemin de type A -> B avec A ou B qui n'existe pas ca marche quand meme, il faudrait régler ca en faisant la vérification du chemin plus tôt

Pour l'ordonnancement j'ai l'idée suivante : 
### Faire tourner une horloge qui a chaque temps (un poids de 5 c'est 5 temps) regarde où sont les gens dans la base 

On peut partir sur une fonction `loop` qui prend la liste des listes de `start_times` (le temps à partir de **maintenant** à laquelle une personne va commencer sa traversée du tunnel) et la liste des chemins (la liste des modules à traverser)

**Propriété de la loop :**

Les deux listes de listes ont la même taille c'est le nombre d'individus, si un individu a un chemin de taille $n$, son nombre de `start_times` doit être de $n-1$ (c'est un prédicat qu'il serait cool de vérifier a chaque tour)

La fonction s'arrête si une des deux est vide puisque tous le monde a fini son trajet

Si une liste est vide, cela signifie qu'un individu a fini son trajet on enlève ce résidu (la liste vide restante)

**Pour un individu :**
* Si il passe un tunnel, le module source est enlevé de sa liste puisqu'il l'a passé
* Si un temps est a 0, il s'apprête à passer le tunnel on enlève ce 0 de sa liste des `start_times`
* A chaque passage dans la boucle on retire 1 à tous ses `start_times`

**Pour deux individus en conflit :**
* On ne peut pas avoir deux personnes dans un même tunnel donc on en prend 1 et on lui ajoute (à tous ses temps) le prochain `start_time` de l'autre (qui sera d'ailleurs égal au poids de la transition) (puisque quand ce prochain `start_times` sera a 0, cela signifiera que l'autre entame un autre tunnel donc le tunnel en conflit est enfin libre)

* Si un tunnel est déjà pris on ajoute pareil le prochain `start_time`pour qu'il attende que ce soit libre et je ne fais pas de priorité même s'il attend depuis longtemps


