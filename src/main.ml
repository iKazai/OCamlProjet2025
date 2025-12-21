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


let () =
	let file = Sys.argv.(1) in
	let transitions, (start_name, goal_name) = Analyse.analyse_file_1 file in
	let graph = build_graph transitions in
	let results = Dyngraph.Graph.dijkstra graph start_name in
	let (_, (distance, path)) = List.find (fun (v, _) -> v = goal_name) results in
	Analyse.output_sol_1 distance path