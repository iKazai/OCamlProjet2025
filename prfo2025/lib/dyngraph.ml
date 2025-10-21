open Schema

module Vertex = struct
  type t = { name : string; id : int }
  
  let compare v1 v2 = Int.compare v1.id v2.id
  
  let to_string v = Printf.sprintf "%s(%d)" v.name v.id
  
  let get_id v = v.id
  
  let get_name v = v.name
  
  let make name id = { name; id }
end

[@@@warning "-32"] (* Avoid unused variable warnings *)
let initialisation g start = 
  let rec aux vl d = 
    match vl with
    | [] -> d
    | hd::tl -> if hd = start then aux tl (0::d) else aux tl (max_int::d)
    in let vertex_list = Hashtbl.fold (fun vertex _ acc -> vertex :: acc) g [] in 
  aux vertex_list []

let find_min q d = 
  let rec aux vl mini vertex_min = 
    match vl with 
    | [] -> vertex_min
    | s::tl -> 
      let new_min = (List.nth d) in
       if new_min < mini then aux tl new_min s
       else aux tl mini vertex_min
  in let vertex_list = Hashtbl.fold (fun vertex _ acc -> vertex :: acc) q [] in 
  let empty_vertex = { name = ""; id = -1 } in
  aux vertex_list max_int empty_vertex

[@@@warning "+32"]
module Make(E : VERTEX_TYPE) = struct
  type vertex = E.t
  
  (* Graph represented as a hashtable with vertex name as key and list of (neighbor_vertex, weight) as value *)
  type graph = (string, (vertex * int) list) Hashtbl.t

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
      (* Remove the vertex from adjacency list *)
      Hashtbl.remove g name;
      (* Remove all edges pointing to this vertex *)
      Hashtbl.iter (fun key neighbors ->
        let filtered = List.filter (fun (neighbor, _) -> E.get_name neighbor <> name) neighbors in
        Hashtbl.replace g key filtered
      ) g
    end;
    g

  let add_edge src weight dst g =
    let src_name = E.get_name src in
    let dst_name = E.get_name dst in
    
    (* Ensure both vertices exist *)
    let g = add_vertex src g in
    let g = add_vertex dst g in
    
    (* Add edge from src to dst *)
    let current_neighbors = Hashtbl.find g src_name in
    (* Remove existing edge if any, then add new one *)
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

  let find_best_path _ _ _ = []
end
