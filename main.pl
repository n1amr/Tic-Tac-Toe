% ======================================== Board ===============================
initial_state(state([[' ', ' ', ' '],
                     [' ', ' ', ' '],
                     [' ', ' ', ' ']], 'X')).

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

set_cell(Board, NewBoard, [X, Y], Player) :-
    append(AL, [Line|BL], Board), length(AL, X), % get Xth line
    append(AC, [_|BC], Line), length(AC, Y), % get Yth cell
    append(AC, [Player|BC], NLine),
    append(AL, [NLine|BL], NewBoard).

get_cell(Board, [X, Y], Player) :-
    append(AL, [Line|_], Board), length(AL, X), % get Xth line
    append(AC, [Player|_], Line), length(AC, Y). % get Yth cell

empty_cell(Board, Point) :-
    get_cell(Board, Point, ' ').

coordinate([X, Y]) :-
    member(X, [0, 1, 2]),
    member(Y, [0, 1, 2]).

opposite('X', 'O').
opposite('O', 'X').

player('X').
player('O').

wins(Board, Player) :-
    member([Player, Player, Player], Board).

wins([L1, L2, L3], Player) :-
    append(A1, [Player|_], L1), length(A1, N),
    append(A2, [Player|_], L2), length(A2, N),
    append(A3, [Player|_], L3), length(A3, N).

wins(Board, Player) :-
    get_cell(Board, [0, 0], Player),
    get_cell(Board, [1, 1], Player),
    get_cell(Board, [2, 2], Player).

wins(Board, Player) :-
    get_cell(Board, [0, 2], Player),
    get_cell(Board, [1, 1], Player),
    get_cell(Board, [2, 0], Player).

has_empty_cells(Board) :-
    member(Line, Board), member(' ', Line).

game_finished(Board) :-
    not(has_empty_cells(Board)), !.

game_finished(Board) :-
    player(Player),
    wins(Board, Player), !.

read_coordinates([X, Y]) :-
    read(X1), X is X1 - 1,
    read(Y1), Y is Y1 - 1.

next(state(Board, Turn), state(NewBoard, NewTurn), Move) :-
    coordinate(Move),
    empty_cell(Board, Move),
    set_cell(Board, NewBoard, Move, Turn),
    opposite(Turn, NewTurn).

score_board(Board, Score) :-
    ( wins(Board, 'O') -> Score = 1
    ; wins(Board, 'X') -> Score = -1
    ; Score = 0).

print_state(state(Board, Turn)) :-
    nl, print_board(Board),
    write('Turn: '), write(Turn), nl.

% ==============================================================================

% ======================================= Minimax ==============================

:- dynamic minimax_mem/2.
:- retractall(minimax_mem(_, _)).

best_move_minimax(State, BestMove) :-
    minimax(State, [_, BestMove]).

minimax(State, [BestScore, BestMove]) :-
    minimax_mem(State, [BestScore, BestMove]), !.

minimax(State, [BestScore, BestMove]) :-
    State = state(Board, Turn),
    ( game_finished(Board) ->
        BestMove = none,
        score_board(Board, BestScore)
    ;
        findall([Score, MyMove],
                (next(State, NewState, MyMove),
                    minimax(NewState, [Score, _OppMove])),
                Choices),
        ( Turn = 'O' -> select_max(Choices, [BestScore, BestMove])
        ; Turn = 'X' -> select_min(Choices, [BestScore, BestMove]))
    ),
    assert(minimax_mem(State, [BestScore, BestMove])).

select_max([H], H) :- !.
select_max([[HK, HV]|T], [K, V]) :-
    select_max(T, [TK, TV]),
    ( TK < HK -> [K, V] = [HK, HV]
    ; TK >= HK -> [K, V] = [TK, TV]).

select_min([H], H) :- !.
select_min([[HK, HV]|T], [K, V]) :-
    select_min(T, [TK, TV]),
    ( TK >= HK -> [K, V] = [HK, HV]
    ; TK < HK -> [K, V] = [TK, TV]).

% ==============================================================================

% ======================= Alpha Beta Pruning ===============================

best_move_alpha_beta(State, BestMove) :-
    alpha_beta(State, -1000, 1000, _BestScore, BestMove).

alpha_beta(State, _Alpha, _Beta, Score, none) :-
    State = state(Board, _Player),
    game_finished(Board), !,
    score_board(Board, Score).

alpha_beta(State, Alpha, Beta, Score, Move) :-
    State = state(Board, _Player),
    findall(Move, empty_cell(Board, Move), Moves),
    alpha_beta_select_best(Moves, State, Alpha, Beta, none, Score, Move).

alpha_beta_select_best([], state(_Board, 'O'), Score, _Beta, Best, Score, Best).
alpha_beta_select_best([], state(_Board, 'X'), _Alpha, Score, Best, Score, Best).

alpha_beta_select_best([Move|Moves], State, Alpha, Beta, DefaultMove, BestScore, BestMove):-
    State = state(_Board, Player),
    next(State, NextState, Move),
    NextState = state(_Board1, _Opponent),
    alpha_beta(NextState, Alpha, Beta, Score, _OppMove),
    ( Player = 'O' -> % maximizer maximizes alpha
        ( Score >= Beta -> % prune
            BestScore = Score,
            BestMove = Move
        ; Score > Alpha ->
            alpha_beta_select_best(Moves, State, Score, Beta, Move, BestScore, BestMove)
        ;
            alpha_beta_select_best(Moves, State, Alpha, Beta, DefaultMove, BestScore, BestMove)
        )
    ; Player = 'X' -> % minimizer minimizes beta
        ( Score =< Alpha -> % prune
            BestScore = Score,
            BestMove = Move
        ; Score < Beta ->
            alpha_beta_select_best(Moves, State, Alpha, Score, Move, BestScore, BestMove)
        ;
            alpha_beta_select_best(Moves, State, Alpha, Beta, DefaultMove, BestScore, BestMove)
        )
    ).

% ==============================================================================

play(state(Board, 'O'), NewState) :-
    % best_move_minimax(state(Board, 'O'), BestMove),
    best_move_alpha_beta(state(Board, 'O'), BestMove),
    empty_cell(Board, BestMove),
    set_cell(Board, NewBoard, BestMove, 'O'),
    NewState = state(NewBoard, 'X').

play(state(Board, 'X'), NewState) :-
    repeat,
    read_coordinates(C),
    empty_cell(Board, C), !,
    set_cell(Board, NewBoard, C, 'X'),
    NewState = state(NewBoard, 'O').

next_turn(state(Board, _Turn)) :-
    game_finished(Board), !,
    ( wins(Board, 'O') ->
        write('Computer wins!!'), nl
    ; wins(Board, 'X') ->
        write('You win!!'), nl
    ;
        write('Draw!!'), nl
    ).

next_turn(State) :-
    State = state(Board, _Turn),
    not(game_finished(Board)),
    play(State, NewState), !,
    NewState = state(NewBoard, _NewTurn),
    print_board(NewBoard),
    next_turn(NewState),
    !.

play :-
    write('========================  New Game  =========================='), nl,
    initial_state(State),
    State = state(Board, _Turn),
    print_board(Board),
    next_turn(State).

main :-
    repeat,
        play,
        write('Play again (y./n.)?'),
        read(Repeat),
        ( Repeat = 'y' -> fail
        ; Repeat = 'n' -> true),
    !.
