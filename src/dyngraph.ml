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

module Graph : DYNAMIC_GRAPH = struct
  type vertex = string
  type graph = (string, (string * int) list) Hashtbl.t

  module VMap = Map.Make(String)

  let empty : graph = Hashtbl.create 0

  let is_empty g = Hashtbl.length g = 0

  let add_vertex v g = 
    if not (Hashtbl.mem g v) then
      Hashtbl.add g v [];
    g

  let remove_vertex v g = 
    if Hashtbl.mem g v then begin
      Hashtbl.remove g v;
      Hashtbl.iter (fun key neighbors ->
        let filtered = List.filter (fun (neighbor, _) -> neighbor <> v) neighbors in
        Hashtbl.replace g key filtered
      ) g
    end;
    g

  let add_edge src weight dst g =
    let g = add_vertex src g in
    let g = add_vertex dst g in
    
    let current_neighbors = Hashtbl.find g src in
    let filtered_neighbors = List.filter (fun (neighbor, _) -> neighbor <> dst) current_neighbors in
    let new_neighbors = (dst, weight) :: filtered_neighbors in
    Hashtbl.replace g src new_neighbors;
    g

  let remove_edge src weight dst g =
    if Hashtbl.mem g src then begin
      let current_neighbors = Hashtbl.find g src in
      let filtered_neighbors = List.filter (fun (neighbor, w) -> 
          not (neighbor = dst && w = weight)) current_neighbors in
      Hashtbl.replace g src filtered_neighbors
    end;
    g


  (*
  Renvoie une liste qui a pour clé les noeuds du graphe 
  et pour valeur un couple contenant la distance de ce noeud à la source et 
  une liste contenant le chemin vers ce noeud
  *)
  let dijkstra g source =

    let get_neighbors v =
      match Hashtbl.find_opt g v with Some l -> l | None -> []
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
      if v = source then source :: acc
      else match VMap.find_opt v pred with
        | None -> acc
        | Some p -> build_path p (v :: acc)
    in

    VMap.fold (fun v _ acc ->
      let distance = match VMap.find_opt v dist with Some x -> x | None -> max_int in
      let path = build_path v [] in
      (v, (distance, path)) :: acc
    ) dist []

end
