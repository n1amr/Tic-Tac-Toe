initial_state([
    [' ', ' ', ' '],
    [' ', ' ', ' '],
    [' ', ' ', ' ']]).

print_board([L1, L2, L3]) :-
    print_line_separator,
    print_board_line(L1),
    print_line_separator,
    print_board_line(L2),
    print_line_separator,
    print_board_line(L3),
    print_line_separator.

print_line_separator :-
    write('-------------'), nl.

print_board_line(Cells) :-
    writef('| %w | %w | %w |\n', Cells).

set_cell(S, NS, [X, Y], Symbol) :-
    append(AL, [Line|BL], S), length(AL, X), % get Xth line
    append(AC, [_|BC], Line), length(AC, Y), % get Yth cell
    append(AC, [Symbol|BC], NLine),
    append(AL, [NLine|BL], NS).

get_cell(S, [X, Y], Symbol) :-
    append(AL, [Line|_], S), length(AL, X), % get Xth line
    append(AC, [Symbol|_], Line), length(AC, Y). % get Yth cell

empty_cell(S, C) :-
    get_cell(S, C, ' ').

coordinate([X, Y]) :-
    member(X, [0, 1, 2]),
    member(Y, [0, 1, 2]).

opposite('X', 'O').
opposite('O', 'X').

player('X').
player('O').

wins(S, Symbol) :-
    member([Symbol, Symbol, Symbol], S).

wins([L1, L2, L3], Symbol) :-
    append(A1, [Symbol|_], L1), length(A1, N),
    append(A2, [Symbol|_], L2), length(A2, N),
    append(A3, [Symbol|_], L3), length(A3, N).

wins(S, Symbol) :-
    get_cell(S, [1, 1], Symbol),
    get_cell(S, [2, 2], Symbol),
    get_cell(S, [3, 3], Symbol).

wins(S, Symbol) :-
    get_cell(S, [1, 3], Symbol),
    get_cell(S, [2, 2], Symbol),
    get_cell(S, [3, 1], Symbol).

has_empty_cells(S) :-
    member(Line, S), member(' ', Line).

game_finished(S) :-
    not(has_empty_cells(S)), !.

game_finished(S) :-
    player(Symbol),
    wins(S, Symbol), !.

score_board(S, 1) :-
    wins(S, 'O'), !.

score_board(S, -1) :-
    wins(S, 'X'), !.

score_board(S, 0).

read_coordinates([X, Y]) :-
    read(X1), X is X1 - 1,
    read(Y1), Y is Y1 - 1.

play(S, 'X', NS) :-
    play_x(S, NS).

play(S, 'O', NS) :-
    play_o(S, NS).

play_x(S, NS) :-
    repeat,
    read_coordinates(C),
    empty_cell(S, C), !,
    set_cell(S, NS, C, 'X').

play_o(S, NS) :-
    coordinate(C),
    empty_cell(S, C),
    set_cell(S, NS, C, 'O').

start_game(S, _Turn) :-
    game_finished(S), !.

start_game(S, Turn) :-
    not(game_finished(S)),
    play(S, Turn, NS), !,
    print_board(NS),
    opposite(Turn, NTurn),
    start_game(NS, NTurn),
    !.

main :-
    initial_state(S),
    print_board(S),
    start_game(S, 'X'),
    !.
