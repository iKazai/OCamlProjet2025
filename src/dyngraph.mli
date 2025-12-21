module type DYNAMIC_GRAPH = sig
    type vertex = string
    type graph
    val empty : graph
    val is_empty : graph -> bool
    val add_vertex : vertex -> graph -> graph
    val remove_vertex : vertex -> graph -> graph
    val add_edge : vertex -> int -> vertex -> graph -> graph
    val remove_edge : vertex -> int -> vertex -> graph -> graph
    val dijkstra : graph -> vertex -> (vertex * (int * vertex list)) list
end

module Graph : DYNAMIC_GRAPH