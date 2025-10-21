(* Dynamic Graph module interface *)

open Schema

(** A concrete vertex implementation *)
module Vertex : VERTEX_TYPE

(** Functor to create a dynamic graph with a given vertex type *)
module Make (E : VERTEX_TYPE) : DYNAMIC_GRAPH with type vertex = E.t
