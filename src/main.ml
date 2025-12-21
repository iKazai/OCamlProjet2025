module G = Dyngraph.Make(Dyngraph.Vertex)

let build_graph transitions =
	let id_counter = ref 0 in
	let name_to_vertex = Hashtbl.create 16 in

	let get_vertex name =
		match Hashtbl.find_opt name_to_vertex name with
		| Some v -> v
		| None ->
				incr id_counter;
				let v = Dyngraph.Vertex.make name !id_counter in
				Hashtbl.add name_to_vertex name v;
				v
	in

	let graph =
		List.fold_left
			(fun g (src, dst, w) ->
				 let v_src = get_vertex src in
				 let v_dst = get_vertex dst in
				 let g = G.add_edge v_src w v_dst g in
				 let g = G.add_edge v_dst w v_src g in
				 g)
			G.empty
			transitions
	in
	graph, name_to_vertex

	
let () =
	let file = Sys.argv.(1) in
	let transitions, (start_name, goal_name) = Analyse.analyse_file_1 file in
	let graph, table = build_graph transitions in
	Printf.printf "Plan charge : %d tunnels, %d modules.\n"
		(List.length transitions) (Hashtbl.length table);
	Printf.printf "Depart : %s | Arrivee : %s\n" start_name goal_name;