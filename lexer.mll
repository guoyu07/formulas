{
  open Parser
}

let alpha = ['a'-'z' 'A'-'Z' '_']
let digit = ['0'-'9']
let id = alpha(alpha|digit)*
let intnum = digit+
let fnum = digit*('.')digit+
let whitespace = [' ' '\t']

rule tokenizer = parse
    "or" { OR }
  | "and" { AND }
  | "all" { FORALL }
  | "ex" { EXISTS }
  | "true" { TRUE }
  | "false" { FALSE }
  | "simpl" { SIMPL }
  | "qez" { QEZ }
  | "lin" { LIN }
  | "help" { HELP }
  | ',' { COMMA }
  | ')' { CPAREN }
  | '(' { OPAREN }
  | '[' { OSQUARE }
  | ']' { CSQUARE }
  | '=' { EQ }
  | "!=" { NEQ }
  | '>' { GT }
  | ">=" { GTE }
  | '<' { LT }
  | "<=" { LTE }
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { STAR }
  | intnum as numstr { INT_LIT (int_of_string numstr) }
  | fnum as numstr { FLOAT_LIT (float_of_string numstr) }
  | id as idstr { ID idstr }
  | whitespace { tokenizer lexbuf }
  | '\n' { NEWLINE }
  | _ { tokenizer lexbuf }
  | eof { raise End_of_file }
