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


# Phase 2 : ordonnancement (simulation des tunnels)

## Objectif
Simuler tous les trajets en parallèle en résolvant les conflits de tunnels. On fait tourner une horloge discrète et on détermine, à chaque événement, qui peut entrer dans quel tunnel.

## Modèle de données
Chaque personne est un `individual` :
```ocaml
type individual = {
	original_path : string list;  (* chemin complet pour la sortie *)
	path : string list;           (* chemin restant à parcourir *)
	initial_starts : int list;    (* délais avant chaque départ *)
	scheduled_starts : int list;  (* temps réels où elle est entrée dans un tunnel *)
}
```

## Événements temps et conflits
- `min_head` : plus petit départ imminent sur tous les individus.
- `min_active` + `decr_active` : temps restant avant libération d’un tunnel occupé et décrément de ces timers.
- `process_edge` : regarde si le tunnel `src-dst` est libre. Retourne un booléen `moved` pour dire si on a réellement pris le tunnel.
	```ocaml
	match find_opt tunnel active with
	| None -> (* libre *) handle_free ... , moved = true
	| Some rem -> (* occupé *) handle_occupied ... , moved = false
	```

## Avancer les individus (try_move)
Pour chaque individu :
- S’il est arrivé (`path` vide ou 1 nœud), on le laisse tel quel.
- S’il doit partir maintenant (`initial_starts` commence par 0), on tente `process_edge`.
	- `moved = true` : on consomme l’arête, on avance `path` et `initial_starts`, on ajoute le temps dans `scheduled_starts`.
	- `moved = false` : tunnel occupé, on ne touche pas au `path`; seuls les délais ont été augmentés.

## Boucle principale `loop`
1. Calculer `dt_next_start` (prochain départ) et `dt_active` (prochaine libération de tunnel). Avancer le temps du minimum.
2. Décrémenter tous les `initial_starts` du `dt` écoulé.
3. Décrémenter les tunnels actifs (`decr_active`).
4. Appeler `try_move` pour faire avancer ceux qui peuvent.
5. Séparer ceux qui ont terminé (`path` vide ou un seul nœud) et accumuler le résultat final : `(original_path, scheduled_starts)`.

## Problèmes rencontrés et fixes
- **Bug critique :** j’avançais `path` même quand le tunnel était occupé ⇒ individus marqués finis trop tôt, `scheduled_starts` plus courts que le chemin ⇒ crash `List.iter2` dans `output_sol_2`.
	- Fix : `process_edge` renvoie `moved`; `try_move` n’avance le chemin que si `moved = true`.
- **Chemin perdu dans la sortie :** une fois arrivé, `path` est vide. J’ai ajouté `original_path` pour afficher le chemin complet dans la solution.
- **Garde-fou retiré :** j’avais ajouté un `pad_to` pour combler les temps manquants. Une fois le bug d’avancement corrigé, `scheduled_starts` a toujours la bonne longueur, donc `pad_to` a été supprimé.

## Résultat
Les tests (ex. `base_phase2_10_5.txt`) passent : l’ordonnancement affiche tous les trajets avec leurs temps de passage et le temps total final.


# Phase 3 : 

Il suffit d'utiliser dijkstra sur le chemin que veut emprunter un individu puis la phase 2

Pour améliorer la création de plus court chemin, j'aurais pu garder ceux que calculais déjà au lieu d'appliquer dijkstra sur chaque chemin du fichier