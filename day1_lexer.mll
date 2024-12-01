{
open Day1_parser
}
rule token = parse
    [' ']     { token lexbuf }
  | ['\n']        { EOL }
  | ['0'-'9']+ as lxm { INT(int_of_string lxm) }
  | eof            { EOF }
