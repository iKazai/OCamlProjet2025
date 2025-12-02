module type VERTEX_TYPE = sig
  type t
  val compare : t -> t -> int
  val to_string : t -> string
  val get_id : t -> int
  val get_name : t -> string
  val make : string -> int -> t
end

module type DYNAMIC_GRAPH = sig
    type vertex
    type graph
    val empty : graph
    val is_empty : graph -> bool
    val add_vertex : vertex -> graph -> graph
    val remove_vertex : vertex -> graph -> graph
    val add_edge : vertex -> int -> vertex -> graph -> graph
    val remove_edge : vertex -> int -> vertex -> graph -> graph
  val dijkstra : graph -> vertex -> (int * vertex list) list
end

module Vertex : VERTEX_TYPE
module Make (E : VERTEX_TYPE) : DYNAMIC_GRAPH with type vertex = E.t