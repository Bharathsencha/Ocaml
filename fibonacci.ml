let rec fib_naive n =
  if n <= 0 then 0
  else if n = 1 then 1
  else fib_naive (n - 1) + fib_naive (n - 2)

let fib_tail n =
  let rec aux count a b =
    if count = 0 then a
    else aux (count - 1) b (a + b)
  in
  aux n 0 1

let () =
  for i = 0 to 10 do
    Printf.printf "fib(%d) = %d\n" i (fib_tail i)
  done;
  Printf.printf "fib_naive(10) = %d\n" (fib_naive 10);
  Printf.printf "fib_tail(10) = %d\n" (fib_tail 10)
