module type DYNAMIC_GRAPH = sig
    type vertex = string
    type graph
    val empty : graph
    val is_empty : graph -> bool
    val add_vertex : vertex -> graph -> graph
    val remove_vertex : vertex -> graph -> graph
    val add_edge : vertex -> int -> vertex -> graph -> graph
    val remove_edge : vertex -> int -> vertex -> graph -> graph

    (*
    [dijkstra graph source] retourne une liste de couples (v,(d,p)) où v est un sommet atteignable depuis source, d est la distance minimale entre source et v, et p est le chemin minimal entre source et v (sous forme de liste de sommets, source en tête, v en queue).
    Si un sommet n'est pas atteignable depuis source, il n'apparaît pas dans la liste.
    @requires source est un sommet de graph
    @ensures tous les sommets de la liste sont atteignables depuis source dans graph
    @ensures tous les sommets atteignables depuis source dans graph apparaissent dans la liste
    *)
    val dijkstra : graph -> vertex -> (vertex * (int * vertex list)) list

    (*
    [neighbours graph v] retourne la liste des voisins de v dans graph, sous forme de couples (voisin, poids de l'arête entre v et voisin).
    Si v n'existe pas dans graph, retourne la liste vide.
    @requires v est un sommet de graph
    @ensures tous les sommets de la liste sont des voisins de v dans graph
    @ensures tous les voisins de v dans graph apparaissent dans la liste
    *)
    val neighbours : graph -> vertex -> (vertex * int) list
end

module Graph : DYNAMIC_GRAPH