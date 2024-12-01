%token <int> INT
%token EOL
%token EOF
%start main
%type <int list * int list> main
%%
main:
    lines EOF { $1 }
;
lines:
    | { ([], []) }
    | line lines { (fst $1 :: fst $2, snd $1 :: snd $2) }
line:
    num num EOL { ($1, $2) }
num:
    INT { $1 }
;
