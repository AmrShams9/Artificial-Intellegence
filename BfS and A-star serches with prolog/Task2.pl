arc(1,5,10).
arc(1,2,1).

arc(2,1,1).
arc(2,3,1).
arc(2,6,1).

arc(3,4,1).
arc(3,7,1).
arc(3,2,1).

arc(4,3,1).
arc(4,8,1).

arc(5,1,1).
arc(5,6,1).
arc(5,9,1).

arc(6,7,1).
arc(6,10,1).
arc(6,5,1).
arc(6,2,1).

arc(7,8,1).
arc(7,11,1).
arc(7,6,1).
arc(7,3,1).

arc(8,12,1).
arc(8,7,1).
arc(8,4,1).

arc(9,10,1).
arc(9,13,1).
arc(9,5,1).

arc(10,11,1).
arc(10,14,1).
arc(10,9,1).
arc(10,6,1).

arc(11,12,1).
arc(11,15,1).
arc(11,10,1).
arc(11,7,1).

arc(12,16,1).
arc(12,11,1).
arc(12,8,1).

arc(13,9,1).
arc(13,14,1).

arc(14,13,1).
arc(14,10,1).
arc(14,15,1).

arc(15,14,1).
arc(15,11,1).
arc(15,16,1).

arc(16,15,1).
arc(16,12,1).

color(1,red).
color(2,red).
color(3,yellow).
color(4,yellow).
color(5,red).
color(6,red).
color(7,red).
color(8,red).
color(9,red).
color(10,red).
color(11,red).
color(12,yellow).
color(13,blue).
color(14,red).
color(15,blue).
color(16,yellow).

h(Node, Value) :-
    hdist(Node, Value).
h(_,1).

hdist(1  ,1).
hdist(16,0).
hdist(2 ,1).
hdist(3,1).
hdist(4 ,1).
hdist(5 ,1).
hdist(6  , 1).
hdist(7  ,1).
hdist(8 ,1).
hdist(9  ,1).
hdist(10 , 1).
hdist(11  ,1).
hdist(12 , 1).
hdist(13, 1).
hdist(14 ,1).

a_star([[Goal|Path]|_],Goal,[Goal|Path],0).
a_star([Path|Queue],Goal,FinalPath,N) :-
    extend(Path,NewPaths),
    append(Queue,NewPaths,Queue1),
    sort_queue1(Queue1,NewQueue),
    a_star(NewQueue,Goal,FinalPath,M),
    N is M+1.

extend([Node|Path], NewPaths) :-
    findall([NewNode,Node|Path],
            (arc(Node, NewNode, _),
            \+ member(NewNode, Path), % Avoid loops
            color(NewNode, Color),     % Get color of the new node
            path_has_same_color([Node|Path], Color)), % Check if the path has the same color
            NewPaths).

% Check if all nodes in the path have the same color
path_has_same_color([], _).
path_has_same_color([Node|Path], Color) :-
    color(Node, Color), % Check if the current node has the same color
    path_has_same_color(Path, Color). % Check the rest of the path

sort_queue1(L,L2) :-
    swap1(L,L1), !,
    sort_queue1(L1,L2).
sort_queue1(L,L).

swap1([[A1|B1],[A2|B2]|T],[[A2|B2],[A1|B1]|T]) :-
    heuristic(A1,W1),
    heuristic(A2,W2),
    W1>W2.
swap1([X|T],[X|V]) :-
    swap1(T,V).

% check if the heuristic function is ok.
heuristic(State, Value) :-
    h(State,Value),
    number(Value), !.
heuristic(State, Value) :-
   write('Incorrect heuristic functionh: '),
   write(h(State, Value)), nl,
   abort.
