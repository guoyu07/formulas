%{
  let output s =
    let prompt = ">> " in  
    begin
      print_endline s;
      print_string prompt;
      flush stdout
    end

  let help_string = " Usage:\n  simpl (exp|formula)\n  lin formula\n  qez formula"
%}

%token <float> FLOAT_LIT
%token <int> INT_LIT
%token <string> ID
%token TRUE FALSE
%token FORALL EXISTS
%token SIMPL QEZ LIN HELP
%token OPAREN CPAREN OSQUARE CSQUARE
%token COMMA
%token NEWLINE
%token OR AND NOT
%token GT GTE LT LTE EQ NEQ
%token PLUS MINUS STAR

%left OR
%left AND
%right NOT
%left GT GTE LT LTE EQ NEQ
%left PLUS MINUS
%left STAR

%start input
%type <unit> input

%%

input: 
    /* empty */ {}
  | input line {}
;

line:
  /* parsing command line input */
    NEWLINE {}
  | formula NEWLINE { output (" [f] " ^ (Ast.string_of_formula $1)) }
  | exp NEWLINE { output (" [e] " ^ (Ast.string_of_exp $1)) }
  | SIMPL exp NEWLINE { output (" [se] " ^ (Ast.string_of_exp (Qe.simplify_exp $2))) }
  | SIMPL formula NEWLINE { output (" [sf] " ^ (Ast.string_of_formula (Qe.simplify $2))) }
  | LIN formula NEWLINE { output (" [linz] " ^ (Ast.string_of_formula (Qe.lin_z $2 (Ast.IntVar "v0"))))}
  | QEZ formula NEWLINE { output (" [qez] " ^ (Ast.string_of_formula (Qe.qe_z $2)))}
  | HELP NEWLINE { output help_string }
;

formula: 
  | bformula { Ast.BForm $1 }
  | formula OR formula { Ast.mkOr $1 $3 }
  | formula AND formula { Ast.mkAnd $1 $3 }
  | NOT formula { Ast.mkNot $2 }
  | FORALL OPAREN ID COMMA formula CPAREN { Ast.mkForall $3 $5 }
  | EXISTS OPAREN ID COMMA formula CPAREN { Ast.mkExists $3 $5 }
  | OPAREN formula CPAREN { $2 }
;

bformula:
    TRUE { Ast.mkTrue }
  | FALSE { Ast.mkFalse }
  | exp GT exp { Ast.mkGt $1 $3 }
  | exp GTE exp { Ast.mkGte $1 $3 }
  | exp LT exp { Ast.mkLt $1 $3 }
  | exp LTE exp { Ast.mkLte $1 $3 }
  | exp EQ exp { Ast.mkEq $1 $3 }
  | exp NEQ exp { Ast.mkNeq $1 $3 }
;

exp:
    FLOAT_LIT { Ast.FConst $1 }
  | INT_LIT { Ast.IConst $1 }
  | ID { Ast.mkVar $1 }
  | exp PLUS exp { Ast.mkAdd $1 $3 }
  | exp MINUS exp { Ast.mkSubtract $1 $3 }
  | INT_LIT STAR exp { Ast.mkMult $1 $3 }
  | OSQUARE exp CSQUARE { Ast.mkFloor $2 }
  | OPAREN exp CPAREN { $2 }
;

%%