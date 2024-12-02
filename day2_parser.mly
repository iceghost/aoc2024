%token <int> INT
%token EOL
%token EOF
%start main
%type <int list list> main
%%
main:
    lines EOF { $1 }
;
lines:
    | { [] }
    | line lines { $1 :: $2 }
line:
    nums EOL { $1 }

nums:
	| { [] }
	| num nums { $1 :: $2 }

num:
    INT { $1 }
;
