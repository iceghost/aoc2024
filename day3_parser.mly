%token <int> INT
%token MUL
%token DO
%token DONT
%token COMMA
%token LPAREN
%token RPAREN
%token TRASH
%start main
%type <Day3_node.node> main
%%

main:
	| DO LPAREN RPAREN { Do }
	| DONT LPAREN RPAREN { Dont }
	| MUL LPAREN num COMMA num RPAREN { Mul ($3, $5) }
;

num:
	| INT { $1 }
;
