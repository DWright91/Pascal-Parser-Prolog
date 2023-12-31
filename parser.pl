/*
* Neeraj Mandal
* Jeremy Stalmer
* Dalton Wright
* CSCI 330 Final Project
* Pascal Parser Using Prolog
*/


parserProgram(File,Result) :- read_in(File,L), lexer(L,Tokens), parser(Tokens,Result).
run :- write('Testing Pascal Program'), nl, nl,
  parseFiles(['a.txt']).
parseFiles([]).
parseFiles([H|T]) :- write('Parsing started/'), write(H), nl,
  read_in(H,L), write(L), nl, lexer(L,Tokens), nl, parser(Tokens,_), nl,
  write(H), write(' Parsing of Pascal program done'), nl, nl, parseFiles(T).

/*READER*/
read_in(File, [W|Ws]) :- see(File), get0(C),
  readword(C, W, C1),
  restsent(W, C1, Ws),
  nl, seen.

readword(C, W, _) :- C = -1, W = C.
readword(C, W, C2) :- C = 58, get0(C1), readwordaux(C, W, C1, C2).
readword(C, W, C1) :- single_character(C), name(W, [C]), get0(C1).
readword(C, W, C2) :- in_word(C, NewC), get0(C1), restword(C1, Cs, C2), name(W, [NewC| Cs]).
readword(_, W, C2) :- get0(C1), readword(C1, W, C2).
readwordaux(C, W, C1, C2) :- C1 = 61, name(W, [C, C1]), get0(C2).
readwordaux(C, W, C1, C2) :- C1 \= 61, name(W, [C]), C1 = C2.

single_character(40).                  /* ( */
single_character(41).                  /* ) */
single_character(42).                  /* + */
single_character(43).                  /* * */
single_character(44).                  /* , */
single_character(59).                  /* ; */
single_character(58).                  /* : */
single_character(61).                  /* = */
single_character(46).                  /* . */

in_word(C, C) :- C > 96, C < 123.
in_word(C, L) :- C > 64, C < 91, L is C + 32.
in_word(C, C) :- C > 47, C < 58.

restword(C, [NewC | Cs], C2) :- in_word(C, NewC), get0(C1), restword(C1, Cs, C2).
restword(C, [], C).
restsent(W, _, []) :- W = -1.
restsent(W, _, []) :- lastword(W).
restsent(_, C, [W1|Ws]) :- readword(C, W1, C1), restsent(W1, C1, Ws).
lastword(W) :- W = '.'.

/*LEXER*/
lexer([],[]).
lexer([H|T], [F|S]) :- match(H, F), lexer(T, S).
match(L,F) :- L = '(', F is 40.
match(L,F) :- L = ':', F is 58.
match(L,F) :- L = '=', F is 68.
match(L,F) :- L = ')', F is 41.
match(L,F) :- L = '*', F is 42.
match(L,F) :- L = ',', F is 44.
match(L,F) :- L = ';', F is 59.
match(L,F) :- L = '.', F is 46.
match(L,F) :- L = '+', F is 43.
match(L,F) :- L = ':=', F is 271.
match(L,F) :- L = 'program', F is 256.
match(L,F) :- L = 'input', F is 257.
match(L,F) :- L = 'var', F is 259.
match(L,F) :- L = 'integer', F is 260.
match(L,F) :- L = 'begin', F is 261.
match(L,F) :- L = 'end', F is 262.
match(L,F) :- L = 'output', F is 258.
match(L,F) :- L = 'boolean', F is 263.
match(L,F) :- L = 'real', F is 264.
match(L,F) :- name(L, [T|S]), char_type(T, digit), match_digit(S), F is 272.
match(L,F) :- name(L, [T|S]), char_type(T, alpha), match_alpha(S), F is 270.
match_digit([ ]).
match_digit([H|T]) :- char_type(H,digit), match_digit(T).
match_alpha([ ]).
match_alpha([H|T]) :- char_type(H, alpha), match_alpha(T).
match_alpha([H|T]) :- char_type(H, digit), match_alpha(T).

/*PARSER*/
parser(Tokens, Res) :- (prog(Tokens, Res), Res = [], write('Parse SUCCESS!')); write('Parse ERROR!').
prog          --> prog_head, var_part, stat_part.
prog_head     --> program, id, lpar, input, comma, output, rpar, scolon.
/*statement part for Pascal*/
stat_part     --> begin, stat_list, end, point.
stat_list     --> statm, stat_list.
stat_list     --> scolon.
stat_list     --> [].
statm         --> assign_stat.
assign_stat   --> id, assign_op, expr.
expr          --> term, addi, expr.
expr          --> term.
term          --> factor, mult, term.
term          --> factor.
factor        --> lpar, expr, rpar.
factor        --> operand.
operand       --> id.
operand       --> number.

/*variable part used for Pascal*/
var_part      --> var, var_dec_list.
var_dec_list  --> var_dec, var_dec_list.
var_dec_list  --> [].
var_dec       --> id_list, id, colon, type, scolon.
id_list       --> id, comma, id_list.
id_list       --> [].
type          --> integer.
type          --> real.
type          --> boolean.

/*Terminals used for Pascal*/
lpar          --> [40].
rpar          --> [41].
mult          --> [42].
addi          --> [43].
comma         --> [44].
scolon        --> [59].
colon         --> [58].
equals        --> [68].
point         --> [46].
assign_op     --> [271].
program       --> [256].
input         --> [257].
output        --> [258].
var           --> [259].
integer       --> [260].
begin         --> [261].
end           --> [262].
boolean       --> [263].
real          --> [264].
number        --> [272].
id            --> [270].
