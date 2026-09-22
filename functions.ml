let add x y = x + y
let add5 = add 5

let rec map f = function
  | [] -> []
  | x :: xs -> f x :: map f xs

let rec filter p = function
  | [] -> []
  | x :: xs -> if p x then x :: filter p xs else filter p xs

let rec fold_left f acc = function
  | [] -> acc
  | x :: xs -> fold_left f (f acc x) xs

let ( << ) f g x = f (g x)

let () =
  Printf.printf "add5 10 = %d\n" (add5 10);
  let numbers = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10] in
  let squares = map (fun x -> x * x) numbers in
  let evens = filter (fun x -> x mod 2 = 0) numbers in
  let sum = fold_left ( + ) 0 numbers in
  let pipeline_result =
    numbers
    |> filter (fun x -> x > 5)
    |> map (fun x -> x * 2)
    |> fold_left ( + ) 0
  in
  let double_then_inc = (fun x -> x + 1) << (fun x -> x * 2) in
  Printf.printf "Squares: %s\n" (String.concat ", " (List.map string_of_int squares));
  Printf.printf "Evens: %s\n" (String.concat ", " (List.map string_of_int evens));
  Printf.printf "Sum: %d\n" sum;
  Printf.printf "Pipeline result: %d\n" pipeline_result;
  Printf.printf "double_then_inc(4) = %d\n" (double_then_inc 4)
