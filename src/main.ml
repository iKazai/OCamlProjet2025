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

let () =
	let file = Sys.argv.(1) in
	let transitions, paths = Analyse.analyse_file_2 file in
	let graph = build_graph transitions in
	Analyse.output_sol_2 (List.combine paths (all_start_times paths graph))