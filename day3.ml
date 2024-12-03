open Base

let part1 input =
  let res = ref 0 in
  try
    let lexbuf = Lexing.from_string input in
    while true do
      try
        match Day3_parser.main Day3_lexer.token lexbuf with
        | Mul (a, b) -> res := !res + (a * b)
        | _ -> ()
      with
      | Stdlib.Parsing.Parse_error -> ()
    done
  with
  | Day3_lexer.Eof -> !res
;;

let%test_unit _ =
  let input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))" in
  [%test_result: int] (part1 input) ~expect:161
;;

let%test_unit _ =
  let input = [%embed_file_as_string "inputs/day3.txt"] in
  [%test_result: int] (part1 input) ~expect:184511516
;;

let part2 input =
  let res = ref 0 in
  let enabled = ref true in
  try
    let lexbuf = Lexing.from_string input in
    while true do
      try
        match Day3_parser.main Day3_lexer.token lexbuf with
        | Mul (a, b) -> res := !res + if !enabled then a * b else 0
        | Do -> enabled := true
        | Dont -> enabled := false
      with
      | Stdlib.Parsing.Parse_error -> ()
    done
  with
  | Day3_lexer.Eof -> !res
;;

let%test_unit _ =
  let input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))" in
  [%test_result: int] (part2 input) ~expect:48
;;

let%test_unit _ =
  let input = [%embed_file_as_string "inputs/day3.txt"] in
  [%test_result: int] (part2 input) ~expect:90044227
;;
