# OCaml Examples

Simple OCaml programs demonstrating syntax, functions, and algorithms.

## Files

- `hello.ml`: Basic console printing
- `fibonacci.ml`: Naive and tail-recursive Fibonacci
- `functions.ml`: Map, filter, fold, currying, composition, and pipeline operator
- `quicksort.ml`: Quicksort on lists using pattern matching
- `bst.ml`: Binary Search Tree insertion, search, and in-order traversal
- `eval.ml`: Expression evaluator using an Abstract Syntax Tree

## How to Run

### Run directly with the interpreter

```bash
ocaml hello.ml
ocaml fibonacci.ml
ocaml functions.ml
ocaml quicksort.ml
ocaml bst.ml
ocaml eval.ml
```

### Compile to binary

```bash
ocamlopt -o hello hello.ml && ./hello
ocamlopt -o fibonacci fibonacci.ml && ./fibonacci
ocamlopt -o functions functions.ml && ./functions
ocamlopt -o quicksort quicksort.ml && ./quicksort
ocamlopt -o bst bst.ml && ./bst
ocamlopt -o eval eval.ml && ./eval
```

## Clean build files

```bash
rm -f hello fibonacci functions quicksort bst eval *.cmi *.cmx *.o
```
