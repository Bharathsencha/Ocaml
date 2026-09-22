type 'a tree =
  | Empty
  | Node of 'a * 'a tree * 'a tree

let rec insert x = function
  | Empty -> Node (x, Empty, Empty)
  | Node (v, left, right) ->
      if x < v then Node (v, insert x left, right)
      else if x > v then Node (v, left, insert x right)
      else Node (v, left, right)

let rec contains x = function
  | Empty -> false
  | Node (v, left, right) ->
      if x = v then true
      else if x < v then contains x left
      else contains x right

let rec inorder = function
  | Empty -> []
  | Node (v, left, right) -> inorder left @ [v] @ inorder right

let () =
  let values = [50; 30; 70; 20; 40; 60; 80] in
  let t = List.fold_left (fun acc x -> insert x acc) Empty values in
  let sorted = inorder t in
  Printf.printf "BST in-order: [%s]\n" (String.concat ", " (List.map string_of_int sorted));
  Printf.printf "Contains 40: %b\n" (contains 40 t);
  Printf.printf "Contains 99: %b\n" (contains 99 t)
