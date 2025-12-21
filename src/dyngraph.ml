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

(* Implémentation concrète de Vertex *)
module Vertex = struct
  type t = { name : string; id : int }
  let compare a b = Int.compare a.id b.id
  let to_string v = Printf.sprintf "%s(%d)" v.name v.id
  let get_id v = v.id
  let get_name v = v.name
  let make name id = { name; id }
end

(* Foncteur conforme à l'interface *)
module Make(E : VERTEX_TYPE) : DYNAMIC_GRAPH with type vertex = E.t = struct
  type vertex = E.t
  type graph = (string, (vertex * int) list) Hashtbl.t

  module VMap = Map.Make(struct
    type t = vertex
    let compare = E.compare
  end)

  let empty : graph = Hashtbl.create 0

  let is_empty g = Hashtbl.length g = 0

  let add_vertex v g = 
    let name = E.get_name v in
    if not (Hashtbl.mem g name) then
      Hashtbl.add g name [];
    g

  let remove_vertex v g = 
    let name = E.get_name v in
    if Hashtbl.mem g name then begin
      Hashtbl.remove g name;
      Hashtbl.iter (fun key neighbors ->
        let filtered = List.filter (fun (neighbor, _) -> E.get_name neighbor <> name) neighbors in
        Hashtbl.replace g key filtered
      ) g
    end;
    g

  let add_edge src weight dst g =
    let src_name = E.get_name src in
    let dst_name = E.get_name dst in
    
    let g = add_vertex src g in
    let g = add_vertex dst g in
    
    let current_neighbors = Hashtbl.find g src_name in

    let filtered_neighbors = List.filter (fun (neighbor, _) -> E.get_name neighbor <> dst_name) current_neighbors in
    let new_neighbors = (dst, weight) :: filtered_neighbors in
    Hashtbl.replace g src_name new_neighbors;
    g

  let remove_edge src weight dst g =
    let src_name = E.get_name src in
    let dst_name = E.get_name dst in
    
    if Hashtbl.mem g src_name then begin
      let current_neighbors = Hashtbl.find g src_name in
      let filtered_neighbors = List.filter (fun (neighbor, w) -> 
          not (E.get_name neighbor = dst_name && w = weight)) current_neighbors in
      Hashtbl.replace g src_name filtered_neighbors
    end;
    g

    
  let dijkstra g source =

    let get_neighbors v =
      let name = E.get_name v in
      match Hashtbl.find_opt g name with Some l -> l | None -> []
    in

    let rec loop pq dist pred =
      match pq with
      | [] -> dist, pred
      | (d,u) :: rest ->
        let current = match VMap.find_opt u dist with Some x -> x | None -> max_int in
        if d > current then loop rest dist pred
        else
          let dist', pred', rest' =
            List.fold_left (fun (dist_acc, pred_acc, q_acc) (v,w) ->
              let old = match VMap.find_opt v dist_acc with Some x -> x | None -> max_int in
              let nd = d + w in
              if nd < old then
                ( VMap.add v nd dist_acc,
                  VMap.add v u pred_acc,
                  (nd, v) :: q_acc )
              else (dist_acc, pred_acc, q_acc)
            ) (dist, pred, rest) (get_neighbors u)
          in
          let sorted = List.sort (fun (d1,_) (d2,_) -> Int.compare d1 d2) rest' in
          loop sorted dist' pred'
    in

    let dist0 = VMap.add source 0 VMap.empty in
    let dist, pred = loop [0, source] dist0 VMap.empty in

    let rec build_path v acc =
      if E.compare v source = 0 then source :: acc
      else match VMap.find_opt v pred with
        | None -> acc
        | Some p -> build_path p (v :: acc)
    in

    VMap.fold (fun v _ acc ->
      if E.compare v source = 0 then acc
      else (E.get_id v, build_path v []) :: acc
    ) dist []

end
