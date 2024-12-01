open Base

let part1 s =
  let ss = String.split_lines s in
  let left, right =
    List.fold
      ~init:([], [])
      ~f:(fun (left, right) line ->
        match
          String.split ~on:' ' line |> List.filter ~f:(Fn.compose not String.is_empty)
        with
        | [ a; b ] -> Int.of_string a :: left, Int.of_string b :: right
        | _ -> raise (Failure "what the fuck"))
      ss
  in
  let left_sorted = List.sort ~compare:Int.compare left in
  let right_sorted = List.sort ~compare:Int.compare right in
  match
    List.map2 ~f:(fun left right -> Int.abs (left - right)) left_sorted right_sorted
  with
  | Ok l -> List.sum (module Int) ~f:Fn.id l
  | _ -> raise (Failure "two list unequal length")
;;

type phase =
  | Search
  | Count of int
  | Trail of int * int

let rec part2_help sum ls rs = function
  | Search ->
    (match ls, rs with
     | l :: ls', r :: rs' ->
       if l < r
       then part2_help sum ls' rs Search
       else if l > r
       then part2_help sum ls rs' Search
       else part2_help sum ls rs (Count 0)
     | _ -> sum)
  | Count count ->
    (match ls, rs with
     | l :: _, r :: rs' ->
       if l = r
       then part2_help sum ls rs' (Count (count + 1))
       else if l < r
       then part2_help sum ls rs (Trail (l, count))
       else raise (Failure "what the fuck")
     | l :: _, [] -> part2_help sum ls [] (Trail (l, count))
     | [], _ -> raise (Failure "what the fuck"))
  | Trail (x, count) ->
    (match ls with
     | l :: ls' ->
       if l = x
       then part2_help (sum + (l * count)) ls' rs (Trail (l, count))
       else part2_help sum ls rs Search
     | [] -> sum)
;;

let part2 s =
  let ss = String.split_lines s in
  let left, right =
    List.fold
      ~init:([], [])
      ~f:(fun (left, right) line ->
        match
          String.split ~on:' ' line |> List.filter ~f:(Fn.compose not String.is_empty)
        with
        | [ a; b ] -> Int.of_string a :: left, Int.of_string b :: right
        | _ -> raise (Failure "what the fuck"))
      ss
  in
  let left_sorted = List.sort ~compare:Int.compare left in
  let right_sorted = List.sort ~compare:Int.compare right in
  part2_help 0 left_sorted right_sorted Search
;;

let%test_unit _ =
  let input = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3\n" in
  [%test_result: int] (part1 input) ~expect:11
;;

let%test_unit _ =
  let input = [%embed_file_as_string "inputs/day1.txt"] in
  [%test_result: int] (part1 input) ~expect:3246517
;;

let%test_unit _ =
  let input = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3\n" in
  (* sorted:
     1   3
     2   3
     3   3
     3   4
     3   5
     4   9 *)
  [%test_result: int] (part2 input) ~expect:31
;;

let%test_unit _ =
  let input = [%embed_file_as_string "inputs/day1.txt"] in
  [%test_result: int] (part2 input) ~expect:29379307
;;
