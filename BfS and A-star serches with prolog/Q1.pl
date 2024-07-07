cell(Row, Col, Color). 

verify_cycle(StartX, StartY, EndX, EndY, N, M) :-
    move1(EndX, EndY,StartX, StartY, N, M), !.

board1(N, M, R1) :- 
    create_board(N, M, B,1),
    reverse_inner_lists(B,R1),
    fill_colors(R1,1),
    between(1, N, X),
    between(1, M, Y),
	dfss(R1,X,Y,[[X, Y]],Path,N,M),
    length(Path, Len),
    Len >= 4,
    last(Path, [StartX, StartY]),  % Extract start coordinates 
    nth0(0, Path, [EndX, EndY]), % Extract end coordinates 
    verify_cycle(StartX, StartY, EndX, EndY, N, M),
    write('cycle Exist: '), writeln(Path),
    fail.


fill_colors([], _).
fill_colors([Row|Rows], RowNum) :-
    fill_row(Row, RowNum),
    RowNum1 is RowNum + 1,
    fill_colors(Rows, RowNum1).

% Predicate to fill the colors of cells in a single row
fill_row([], _).
fill_row([cell(RowNum, _, Color)|Cols], RowNum) :-
    get_color(Color), % Call your get_color predicate here
    fill_row(Cols, RowNum).


reverse_inner_lists(Board, ReversedBoard) :-
    maplist(reverse, Board, ReversedBoard).
reverse([], []).
reverse([Head|Tail], Reversed) :-
    reverse(Tail, ReversedTail),
    append(ReversedTail, [Head], Reversed). 

create_board(0, _, [],_). 
create_board(N, M,[Row|Rows],Acc1) :- 
 N > 0,
 create_row(M,Acc1, Row), 
 N1 is N - 1,
 Ac1 is Acc1 + 1,
 create_board(N1, M, Rows,Ac1). 


 % Cell representation
create_row(0, _, []). % No changes needed here
create_row(M, RowNum, [cell(RowNum, Col, _)|Cols]) :- 
 M > 0,
 Col is M,  % Calculate the column number
 Col1 is M - 1,
 create_row(Col1, RowNum, Cols). 


get_color(Color) :-
    write('Enter color (red, yellow, or blue): '),
    read(InputColor), 
    atom_string(InputColor, ColorString), % Ensure it's a string like "red"
    ( 
        ColorString = "red" -> Color = red ;
        ColorString = "yellow" -> Color = yellow ;
        ColorString = "blue" -> Color = blue ;
        write('Invalid color. Please try again.'), nl,
        get_color(Color) % Get the input again if invalid
    ).


move1(Row, Col, NewRow, NewCol, N, M) :- 
    ( 
       NewRow is Row - 1, 
       between(1, N, NewRow), 
       NewCol = Col 
    ;  
       NewRow is Row + 1, 
       between(1, N, NewRow), 
       NewCol = Col 
    ;  
       NewCol is Col - 1, 
       between(1, M, NewCol), 
       NewRow = Row 
    ;  
       NewCol is Col + 1, 
       between(1, M, NewCol), 
       NewRow = Row 
    ; 
       fail % Failure if direction is invalid
    ).

    

dfss(Board,Row, Col, Visited, Path, N, M) :-
    move1(Row, Col, NewRow, NewCol, N, M),
    not(member([NewRow, NewCol], Visited)),
    nth1(Row, Board, RowCells), % Extract the row of the board
    nth1(NewRow, Board, NewRowCells), % Extract the neighboring row of the board
    nth1(Col, RowCells, cell(_, _, Color)), % Extract the color of the current cell
    nth1(NewCol, NewRowCells, cell(_, _, NewColor)), % Extract the color of the neighboring cell
    Color = NewColor, % Check if the colors match
    dfss(Board,NewRow, NewCol, [[NewRow, NewCol] | Visited], Path, N, M).

dfss(_, _, _,Visited, Visited, _, _).

    
     
