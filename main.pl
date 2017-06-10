initial_state([[' ', ' ', ' '], [' ', ' ', ' '], [' ', ' ', ' ']]).

print_board([L1, L2, L3]) :-
    print_line_separator, print_board_line(L1),
    print_line_separator, print_board_line(L2),
    print_line_separator, print_board_line(L3),
    print_line_separator.

print_line_separator :- write('-------------'), nl.

print_board_line(Cells) :- writef('| %w | %w | %w |\n', Cells).

set_cell(S, NS, [X, Y], Symbol) :-
    append(AL, [Line|BL], S), length(AL, X), % get Xth line
    append(AC, [_|BC], Line), length(AC, Y), % get Yth cell
    append(AC, [Symbol|BC], NLine),
    append(AL, [NLine|BL], NS).

main :-
    initial_state(S),
    print_board(S),
    set_cell(S, NS, [2, 2], 'x'),
    print_board(NS),
    !.
