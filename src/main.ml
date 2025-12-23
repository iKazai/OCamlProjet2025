(*
	Construis un graphe à partir des transitions analysées.
	@requires transitions : (string * string * int) list
	@ensures retourne un graphe Dyngraph.Graph.t construit à partir des transitions
	@ensures chaque transition (src, dst, w) est ajoutée dans les deux sens (src -> dst et dst -> src)
*)
let build_graph transitions =
	let rec aux transitions_acc graph_acc =
		match transitions_acc with
		| [] -> graph_acc
		| (src, dst, w) :: tl ->
				let g = Dyngraph.Graph.add_edge src w dst graph_acc in
				let g = Dyngraph.Graph.add_edge dst w src g in
				aux tl g
	in
	aux transitions Dyngraph.Graph.empty


(*
	Renvoie la liste des temps de départ pour chaque module dans le chemin donné
	@requires Si path ne contient que deux modules, ils sont connectés dans le graphe
	@ensures La liste retournée contient au moins un élément (0 pour le premier module)
	@raises failwith si le chemin est incorrect (deux modules non connectés)
	@raises failwith si le chemin contient moins de deux modules
*)
let start_times path graph = 
	let rec aux path_acc time_res total_acc =
	match path_acc with 
		| [] -> failwith "[start_times] : Empty path"
		| [x] -> failwith "[start_times] : Only one module in the path"
		| [a;b] -> time_res
		| src::dst::tl -> match Dyngraph.Graph.neighbours graph src with
			| [] -> failwith "[start_times] : Incorrect path"
			| neighbours -> 
				match List.find_opt (fun (neighbor, weight) -> neighbor = dst) neighbours with  
				| None -> failwith "[start_times] : Incorrect path"
				| Some (neighbor, weight) -> aux (dst::tl) ((total_acc + weight)::time_res) (total_acc + weight)

	in List.rev (aux path [0] 0)

(*
	Renvoie la liste des listes des temps de départ pour chaque chemin dans la liste donnée
*)
let all_start_times paths graph = 
	let rec aux = function 
		| [] -> []
		| hd::tl -> (start_times hd graph)::(aux tl)
	in aux paths 


type individual = {
	original_path : string list;
	path : string list;
	initial_starts : int list;
	scheduled_starts : int list;
}


(*
	Renvoie le poids de l'arête entre deux nœuds donnés
	@raises failwith si l'arête n'existe pas dans le graphe
*)
let get_edge_weight graph node1 node2 = 
	match List.find_opt (fun (neighbor, weight) -> neighbor = node2) (Dyngraph.Graph.neighbours graph node1) with  
			| None -> failwith "[edge_weight] : Edge doesn't exist"
			| Some (neighbor, weight) -> weight


let get_tuple_edge node1 node2 = 
	if node1 < node2 then (node1, node2) else (node2, node1)


(*
	Mets à jour un tunnel après un temps dt
	e est un couple de modules dont le tunnel est occupé
	r est le temps restant durant lequel ce tunnel sera occupé 
*)
let update_tunnel dt (e, r) =
  if r - dt <= 0 then None else Some (e, r - dt)


(*
	Mets à jour la liste des tunnels en conflit après un temps dt
	active contient la liste des tunnels en conflit
*)
let decr_active active dt =
	List.filter_map (update_tunnel dt) active 


(*
	Trouve le temps minimum avant qu'un tunnel se libère.
	@ensures s'il n'y a aucun tunnel à libérer, min_active renvoie None
*)
let min_active active = 
	if active = [] then None else
	let rec aux min_acc lst = 
		match lst with
		| [] -> min_acc
		| (_, r)::tl -> if min_acc > r then aux r tl else aux min_acc tl
	in 
	let (_, first_min) = (List.hd active) in
	Some (aux first_min (List.tl active))


(*
	Trouve le minimum parmi les initial_starts de tous les individus.
	@requires indiv_lst est une liste d'individus
*)
let min_head indiv_lst =
	List.fold_left (
		fun acc i -> 
			match i.initial_starts with
			[] -> acc
			| hd::_ -> min acc hd
	) max_int indiv_lst


(*
	Fonction auxiliaire à process_edge qui traite le cas ou le tunnel est occupé
	Ajoute le temps restant avant que le tunnel soit libéré à l'individu
	rem est le temps restant avant que le tunnel se libère
*)
let handle_occupied indiv rem =
	{ indiv with initial_starts = List.map (fun n -> n + rem) indiv.initial_starts }


(*
	Fonction auxiliaire à process_edge qui traite le cas ou le tunnel est libre
	Ajoute le tunnel à la liste de tunnels actifs
	Le tunnel étant libre, on ajoute le temps de passage à scheduled_starts de l'individu
	On utilise get_tuple_edge car "A" "B" et "B" "A" représente le même tunnel
*)
let handle_free graph active indiv src dst time =
	let w = get_edge_weight graph src dst in
	let active' = ((get_tuple_edge src dst), w)::active in
	let indiv' = { indiv with scheduled_starts = indiv.scheduled_starts@[time] } in
	(active', indiv', true)


(*
	Quand un individu veut traverser une arête, soit il l'emprunte (si libre), soit il attend (si occupée).
	On vérifie si le tunnel est occupé. Le booléen retourné indique si le passage a réellement démarré :
	- true  : tunnel libre, on a ajouté un scheduled_start et avancé.
	- false : tunnel occupé, on a seulement décalé les initial_starts, sans traverser l'arête.
*)
let process_edge graph time src dst active indiv =
	match List.find_opt (fun (e, _) -> e = get_tuple_edge src dst) active with
	| None -> handle_free graph active indiv src dst time 
	| Some (_, rem) -> (active, handle_occupied indiv rem, false)


(*
	Pour chaque individu, si son prochain initial_starts est 0, il essaie de traverser l'arête suivante.
	Parcourt les individus avec fold_left
	1. Si path a moins d'un élément, l'individu a fini son chemin, on la garder telle quelle
	2. Sinon, si initial_starts commence par 0 :
		a) Récupère src = path[0] et dst = path[1]
		b) Appelle process_edge pour l'avancer ou la délayer
		c) Enlève le premier élément de path et initial_starts
	3. Sinon : ne rien faire
*)	
let try_move graph time active indiv_lst =
	let (active_final, indivs_rev) = 
	List.fold_left (fun (active_acc, indivs_acc) indiv ->
		match indiv.path, indiv.initial_starts with
		(* Une fois qu'un individu est traité (entame le tunnel, ne bouge pas, est délayé) on l'ajoute à l'avant de l'accumulateur. On renversera l'accumulateur à la fin pour l'optimisation *)
		(* Etape 1. *)
      	| [], _ | [_], _ -> (active_acc, indiv :: indivs_acc) 
		(* Etape 2.a) *)
		| src::dst::tl, 0::rest_starts ->
			(* Etape 2.b) *)
			let (active', indiv', moved) = process_edge graph time src dst active_acc indiv in
			(* Etape 2.c) *)
			if moved then
				let indiv'' = {indiv' with path = dst::tl; initial_starts = rest_starts } in
				(active', indiv'' :: indivs_acc)
			else
				(* Tunnel occupé : on garde le path et les initial_starts ajustés *)
				(active', indiv' :: indivs_acc)
		(* Etape 3. *)
		| _ -> (active_acc, indiv :: indivs_acc)
    )
    (active, [])
    indiv_lst
	in
	(active_final, List.rev indivs_rev)

  
(*
	1. Initialiser chaque individu avec son chemin et initial_starts
	2. Boucler tant qu'il y a du travail :
		a) Calcule le prochain événement : dt_next_start (min head) et dt_active (tunnel libéré)
		b) Avancer du min des deux
		c) Décrémenter les initial_starts de tous
		d) Appeler try_move pour avancer les individus
		e) Décrémenter les tunnels occupés
	3. Retourner la liste (chemin, scheduled_starts) et le temps total
*)
let schedule_paths graph paths =

	(*
		Initialise un individu en fonction d'un chemin
	*)
	let init_individual indivs_path =
		{
			original_path = indivs_path;
			path = indivs_path; 
			initial_starts = start_times indivs_path graph; 
			scheduled_starts = [] 
		}
	in

	(* Etape 2 *)
	(*
		[finished] contient la solution finale, les individus qui ont terminé et qui ont donc leur scheduled_times complet
	*)
	let rec loop time active indiv_lst finished =
		match indiv_lst with
			| [] -> (* Il faut gérer le cas où il reste des tunnels occupés *) 
				(match min_active active with
					| None -> (List.rev finished, time)
					| Some dt -> loop (time + dt) (decr_active active dt) indiv_lst finished)

			| _ ->
				(* Etape 2.a) *)
				(* 
					Temps avant le prochain départ parmi tous les individus.
					Concrètement, c’est le minimum des têtes de leurs initial_starts.
					Parfois tous le monde traverse un tunnel ou attend, il ne se passe rien.
				*)
				let dt_next_start = min_head indiv_lst in

				(*
					Temps restant avant que le prochain tunnel occupé se libère.
					Concrètement, c’est le minimum des temps restants dans la liste active
				*)
				let dt_active = match min_active active with None -> max_int | Some dt -> dt in
				let dt = min dt_next_start dt_active in

				if dt = max_int then (List.rev finished, time)
				else
				
				(* Etape 2.b) *)
				let time' = time + dt in
				(* Etape 2.c) *)
				let indiv_lst' = List.map (fun p -> { p with initial_starts = List.map (fun n -> max 0 (n - dt)) p.initial_starts }) indiv_lst in

				(* Etape 2.e) *)
				let active' = decr_active active dt in

				(* Etape 2.d) *)
				let (active'', indivs_updated) = try_move graph time' active' indiv_lst' in

				(* 
					Sépare les terminés de ceux qui continuent 
					Ceux qui ont fini doivent être ajouté à finished	
				*)
				let indiv_done, indiv_continue = 
					List.partition (fun p -> match p.path with [] | [_] -> true | _ -> false) indivs_updated
				in

				let finished' =
					List.fold_left (fun acc p ->
						(p.original_path, p.scheduled_starts) :: acc)
					finished
					indiv_done
			in
			loop time' active'' indiv_continue finished'
  	in
	loop 0 [] (List.map init_individual paths) (* Etape 1 *) []

let () =
  let file = Sys.argv.(1) in
  let transitions, paths = Analyse.analyse_file_2 file in
  let graph = build_graph transitions in
  let schedules, total_time = schedule_paths graph paths in
  Analyse.output_sol_2 schedules;
  Format.printf "%d@." total_time