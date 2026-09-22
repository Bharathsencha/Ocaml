let rec quicksort = function
  | [] -> []
  | pivot :: rest ->
      let smaller = List.filter (fun x -> x < pivot) rest in
      let larger = List.filter (fun x -> x >= pivot) rest in
      quicksort smaller @ [pivot] @ quicksort larger

let () =
  let unsorted = [34; 7; 23; 32; 5; 62; 12; 4; 99; 1] in
  let sorted = quicksort unsorted in
  let show lst = String.concat ", " (List.map string_of_int lst) in
  Printf.printf "Unsorted: [%s]\n" (show unsorted);
  Printf.printf "Sorted: [%s]\n" (show sorted)
