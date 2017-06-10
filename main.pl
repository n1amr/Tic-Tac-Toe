initial_state([[' ', ' ', ' '], [' ', ' ', ' '], [' ', ' ', ' ']]).

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

play_x(S, NS, [X, Y]) :-
    set_cell(S, NS, [X, Y], 'X').

play_o(S, NS, [X, Y]) :-
    set_cell(S, NS, [X, Y], 'O').

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

has_empty_cells(S) :-
    member(Line, S), member(' ', Line).

read_coordinates([X, Y]) :-
    read(X1), X is X1 - 1,
    read(Y1), Y is Y1 - 1.

opposite('X', 'O').
opposite('O', 'X').

start_game(S, _Turn) :-
    not(has_empty_cells(S)).

start_game(S, Turn) :-
    has_empty_cells(S),
    read_coordinates(C),
    empty_cell(S, C),
    set_cell(S, NS, C, Turn),
    print_board(NS),
    opposite(Turn, NTurn),
    start_game(NS, NTurn),
    !.

main :-
    initial_state(S),
    print_board(S),
    start_game(S, 'X'),
    !.
