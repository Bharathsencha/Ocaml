type expr =
  | Val of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval = function
  | Val n -> n
  | Add (a, b) -> eval a + eval b
  | Sub (a, b) -> eval a - eval b
  | Mul (a, b) -> eval a * eval b
  | Div (a, b) -> eval a / eval b

let rec to_string = function
  | Val n -> string_of_int n
  | Add (a, b) -> Printf.sprintf "(%s + %s)" (to_string a) (to_string b)
  | Sub (a, b) -> Printf.sprintf "(%s - %s)" (to_string a) (to_string b)
  | Mul (a, b) -> Printf.sprintf "(%s * %s)" (to_string a) (to_string b)
  | Div (a, b) -> Printf.sprintf "(%s / %s)" (to_string a) (to_string b)

let () =
  let e = Sub (Add (Val 10, Mul (Val 4, Val 5)), Div (Val 20, Val 2)) in
  Printf.printf "Expression: %s\n" (to_string e);
  Printf.printf "Result: %d\n" (eval e)
