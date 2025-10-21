(* Implementation file for schema - defines the shared type signatures *)

(** Signature for vertex types *)
module type VERTEX_TYPE = sig
  type t
  val compare : t -> t -> int
  val to_string : t -> string
  val get_id : t -> int
  val get_name : t -> string
  val make : string -> int -> t
end

(** Signature for dynamic graph operations *)
module type DYNAMIC_GRAPH = sig
  type vertex
  type graph
  
  val empty : graph
  val is_empty : graph -> bool
  
  val add_vertex : vertex -> graph -> graph
  val remove_vertex : vertex -> graph -> graph
  
  val add_edge : vertex -> int -> vertex -> graph -> graph
  val remove_edge : vertex -> int -> vertex -> graph -> graph

  val find_best_path : vertex -> vertex -> graph -> (vertex * int) list
end