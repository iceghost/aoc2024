open Base
open Base.Poly

let rec diffs = function
  | [] -> []
  | _ :: [] -> []
  | a :: b :: rest -> (b - a) :: diffs (b :: rest)
;;

module Part1 : sig
  val main : string -> int
end = struct
  let rec check_help ~sign = function
    | [] -> true
    | x :: xs ->
      if Int.sign x <> sign || Int.abs x > 3 then false else check_help ~sign xs
  ;;

  let check xs = check_help ~sign:Sign.Pos xs || check_help ~sign:Sign.Neg xs

  let main s =
    s
    |> Lexing.from_string
    |> Day2_parser.main Day2_lexer.token
    |> List.map ~f:diffs
    |> List.map ~f:check
    |> List.count ~f:Fn.id
  ;;
end

module Part2 : sig
  val main : string -> int
end = struct
  let rec check_help ~tries ~sign xs =
    if tries = 0
    then false
    else (
      let bad x = Int.sign x <> sign || Int.abs x > 3 in
      match xs with
      | l :: left, m, r :: right ->
        if bad m
        then
          check_help ~sign ~tries:(tries - 1) (left, m + l, r :: right)
          || check_help ~sign ~tries:(tries - 1) (l :: left, m + r, right)
        else check_help ~sign ~tries (m :: l :: left, r, right)
      | [], m, r :: right ->
        if bad m
        then
          check_help ~sign ~tries:(tries - 1) ([], m + r, right)
          || check_help ~sign ~tries:(tries - 1) ([], r, right)
        else check_help ~sign ~tries ([ m ], r, right)
      | l :: left, m, [] ->
        if bad m
        then
          check_help ~sign ~tries:(tries - 1) (left, m + l, [])
          || check_help ~sign ~tries:(tries - 1) (left, l, [])
        else true
      | [], _, [] -> true)
  ;;

  let check = function
    | [] -> true
    | x :: xs ->
      check_help ~tries:2 ~sign:Sign.Pos ([], x, xs)
      || check_help ~tries:2 ~sign:Sign.Neg ([], x, xs)
  ;;

  let main s =
    s
    |> Lexing.from_string
    |> Day2_parser.main Day2_lexer.token
    |> List.map ~f:diffs
    |> List.map ~f:check
    |> List.count ~f:Fn.id
  ;;
end

let%test_unit _ =
  let input = "7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9\n" in
  [%test_result: int] (Part1.main input) ~expect:2
;;

let%test_unit _ =
  let input = [%embed_file_as_string "inputs/day2.txt"] in
  [%test_result: int] (Part1.main input) ~expect:680
;;

let%test_unit _ =
  let input = "7 6 4 2 1\n1 2 7 8 9\n9 7 6 2 1\n1 3 2 4 5\n8 6 4 4 1\n1 3 6 7 9\n" in
  [%test_result: int] (Part2.main input) ~expect:4
;;

let%test_unit _ =
  let input = [%embed_file_as_string "inputs/day2.txt"] in
  [%test_result: int] (Part2.main input) ~expect:710
;;
