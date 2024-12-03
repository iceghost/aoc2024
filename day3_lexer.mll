{
open Day3_parser
exception Eof
}
rule token = parse
	| "mul"             { MUL }
	| "do"              { DO }
	| "don't"           { DONT }
	| '('               { LPAREN }
	| ','               { COMMA }
	| ')'               { RPAREN }
	| ['0'-'9']+ as lxm { INT(int_of_string lxm) }
	| eof               { raise Eof }
	| _                 { TRASH }
