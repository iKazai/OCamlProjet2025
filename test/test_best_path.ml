open Dyngraph

let test_djikstra () =
  let module G = Dyngraph.Make(Dyngraph.Vertex) in
  let g = G.empty in
  let v1 = Dyngraph.Vertex.make "A" 1 in
  let v2 = Dyngraph.Vertex.make "B" 2 in
  let v3 = Dyngraph.Vertex.make "C" 3 in
  let g = G.add_vertex v1 g in
  let g = G.add_vertex v2 g in
  let g = G.add_vertex v3 g in
  let g = G.add_edge v1 1 v2 g in
  let g = G.add_edge v2 2 v3 g in
  let g = G.add_edge v1 4 v3 g in
  assert (G.dijkstra v1 v3 g = Some 3);
  assert (G.dijkstra v1 v2 g = Some 1);
  assert (G.dijkstra v2 v3 g = Some 2);
  assert (G.dijkstra v1 v1 g = Some 0);
  Printf.printf "Dijkstra test passed!\n"

let () =
  test_djikstra ()