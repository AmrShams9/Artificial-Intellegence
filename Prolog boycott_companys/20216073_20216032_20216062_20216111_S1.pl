
:-consult(data).

%Task:1
list_orders(Customer, Orders) :-
    customer(CustomerId, Customer) ,% Find the customer ID based on the name
    list_orders_helper(CustomerId, [], Orders).  % Call the helper predicate with the customer ID and an empty list as accumulator

% Helper predicate to list orders for a given CustomerId
list_orders_helper(CustomerId, List, Orders) :-

  order(CID, Oid, Items),
  CustomerId = CID,
  not(member(order(CID, Oid, Items),List)),
  append(List, [order(CID, Oid, Items)], NewTempSolutions),
  list_orders_helper(CustomerId,  NewTempSolutions, Orders).
% Base case: When there are no more orders, unify Orders with the accumulated list
list_orders_helper(_, Orders, Orders).

    %Member Function
	member(X, [X|_]).
member(X, [_|Tail]):-
member(X, Tail).

%append Function
append([], L, L).
append([H|T], L2, [H|NT]):-
append(T, L2, NT).

% Task:2
	countOrdersOfCustomer(Customer,Count):-
    list_orders(Customer,Orders),
    len(Orders,Count).


    %helperFunction for Task 2
    len([],0).
	len([_|Tail], N):-
	len(Tail, TmpN),
	N is TmpN+1.

% Task:3
getItemsInOrderById(Customer,OrderId,Items):-
    customer(CID,Customer),
   order(CID, OrderId, Items).

% Task:4
getNumOfItems(Customer,OrderId,Count):-
   getItemsInOrderById(Customer,OrderId,Items),
    count_items(Items,Count).

% Predicate to count the number of items in a list
count_items([], 0). % Base case: an empty list has 0 items
count_items([_ | Tail], Count) :-
    count_items(Tail, TailCount), % Recursively count the number of items in the tail of the list
    Count is TailCount + 1. % Increment the count for each item in the list

% Task:5
% Predicate to calculate the price of an order
calcPriceOfOrder(CustomerName, OrderId, TotalPrice) :-
    customer(CustomerId, CustomerName), % Find the customer ID based on the name
    order(CustomerId, OrderId, Items), % Retrieve the items for the given customer and order ID
    sumPrices(Items, 0, TotalPrice). % Sum up the prices of the items in the order

% Helper predicate to sum up the prices of the items in the order
sumPrices([], Acc, Acc). % Base case: when there are no more items, unify Acc with TotalPrice
sumPrices([Item|Rest], Acc, TotalPrice) :-
    item(Item, _, Price), % Retrieve the price of the current item
    NewAcc is Acc + Price, % Add the price of the current item to the accumulator
    sumPrices(Rest, NewAcc, TotalPrice). % Recursively process the rest of the items


%Task:6
% Predicate to determine whether an item or company needs to be boycotted
isBoycott(ItemOrCompany) :-
    alternative(ItemOrCompany , _).



% Task:7
% finds the justification for boycotting a company/item
whyToBoycott(Item_name, Justification) :-
    item(Item_name,Company_Name, _ ),
    boycott_company(Company_Name, Justification ).



% Task:8
% specifies the customer's order
customer_order(Customer, Order_ID, Items) :-
    order(Customer_ID, Order_ID, Items),
    customer(Customer_ID, Customer).

% checks if a company is boycotted
is_boycotted(Company) :-
    boycott_company(Company, _).

% checks if the item is boycotted
item_is_boycotted(Item) :-
    item(Item, Company, _),
    is_boycotted(Company).

% finds an alternative for a boycotted item
find_alternative(Item, Alternative) :-
    alternative(Item, Alternative).

% removes the boycotted items from the customer's order
removes_boycotted_items([], _, []).
removes_boycotted_items([Item|Rest_of_items], Customer, [Item|Filtered_items]) :-
    \+ item_is_boycotted(Item), % checks if the goal fails
    removes_boycotted_items(Rest_of_items, Customer, Filtered_items).
removes_boycotted_items([Item|Rest_of_items], Customer, Filtered_items) :-
    item_is_boycotted(Item),
    removes_boycotted_items(Rest_of_items, Customer, Filtered_items).

% removes the boycotted items from an order for a specific customer
removeBoycottItemsFromAnOrder(Customer, Order_ID, New_List) :-
    customer_order(Customer, Order_ID, Items),
    removes_boycotted_items(Items, Customer, New_List).


% Task:9
% replaces boycotted items with alternatives in the customer's order
replace_boycotted_items([], _, []).
replace_boycotted_items([Item|Rest_of_items], Customer, [New_Item|Filtered_items]) :-
    \+ item_is_boycotted(Item),
    New_Item = Item,
    replace_boycotted_items(Rest_of_items, Customer, Filtered_items).
replace_boycotted_items([Item|Rest_of_items], Customer, [Alternative|Filtered_items]) :-
    item_is_boycotted(Item),
    find_alternative(Item, Alternative),
    replace_boycotted_items(Rest_of_items, Customer, Filtered_items).

% replaces boycotted items with alternatives from an order for a specific customer
replaceBoycottItemsFromAnOrder(Customer, Order_ID, New_List) :-
    customer_order(Customer, Order_ID, Items),
    replace_boycotted_items(Items, Customer, New_List).



% Task:10
calcPriceAfterReplacingBoycottItemsFromAnOrder(Customer, OrderId, NewList, TotalPrice) :-
    customer(CustomerId, Customer),  % Find the customer ID based on the name
    order(CustomerId, OrderId, Items),  % Get the items associated with the given order ID
    calcPriceAfterReplacingBoycottItems(Items, NewItems, 0, TotalPrice),  % Replace boycott items with alternatives and calculate total price
    removeDuplicates(NewItems, NewList).  % Remove duplicates from the resulting list

% Predicate to calculate the price after replacing boycott items with alternatives
calcPriceAfterReplacingBoycottItems([], [], TotalPrice, TotalPrice).  % Base case: when there are no more items, unify TotalPrice with the accumulated total
calcPriceAfterReplacingBoycottItems([Item|RestItems], [NewItem|RestNewItems], AccPrice, TotalPrice) :-
    % Check if the item is boycotted and replace with alternative if available
    ( boycotted_item(Item, Alternative) ->
        ( item(Alternative, _, Price) ->  % If there's an alternative available
            NewItem = Alternative,  % Replace with alternative
            NewAccPrice is AccPrice + Price,  % Update the accumulated total price
            calcPriceAfterReplacingBoycottItems(RestItems, RestNewItems, NewAccPrice, TotalPrice)  % Recur with the rest of the items
        ;
            NewItem = Item,  % Keep the original item if no alternative available
            item(Item, _, ItemPrice),  % Get the price of the original item
            NewAccPrice is AccPrice + ItemPrice,  % Update the accumulated total price
            calcPriceAfterReplacingBoycottItems(RestItems, RestNewItems, NewAccPrice, TotalPrice)  % Recur with the rest of the items
        )
    ;
        NewItem = Item,  % If not boycotted, keep the original item
        item(Item, _, Price),  % Get the price of the original item
        NewAccPrice is AccPrice + Price,  % Update the accumulated total price
        calcPriceAfterReplacingBoycottItems(RestItems, RestNewItems, NewAccPrice, TotalPrice)  % Recur with the rest of the items
    ).
% Definition of boycotted items and their alternatives
boycotted_item(Item, Alternative) :-
    alternative(Item, Alternative).

boycotted_item(Item, Item) :-
    \+ alternative(Item, _).

% Remove duplicates from the list
removeDuplicates([], []).
removeDuplicates([X|Xs], [X|Ys]) :-
    removeDuplicates(Xs, X, Ys).

removeDuplicates([], _, []).
removeDuplicates([X|Xs], X, Ys) :-
    removeDuplicates(Xs, X, Ys).
removeDuplicates([X|Xs], Prev, [X|Ys]) :-
    X \= Prev,
    removeDuplicates(Xs, X, Ys).


% Task:11
getTheDifferenceInPriceBetweenItemAndAlternative(Item, Alternative, DiffPrice) :-
    boycotted_item(Item, Alternative),  % Find the alternative for the boycotted item
    item(Item, _, ItemPrice),  % Get the price of the boycotted item
    item(Alternative, _, AltPrice),  % Get the price of the alternative
    DiffPrice is AltPrice - ItemPrice.  % Calculate the price difference



% Task:12

% Insert an item
:- dynamic item/3.
add_item(Item_Name, Brand_Name, Price) :-
    assert(item(Item_Name, Brand_Name, Price)).

% Remove an item
remove_item(Item_Name, Brand_Name, Price) :-
    retract(item(Item_Name, Brand_Name, Price)),
    \+ item(Item_Name, Brand_Name, Price). % Ensure the item no longer exists


% Insert an alternative
add_alternative(Item1, Item2) :-
    assert(alternative(Item1, Item2)).

% Remove an alternative
remove_alternative(Item1, Item2) :-
    retract(alternative(Item1, Item2)).

% Insert a new boycott company
add_boycott_company(Company_Name, Reason) :-
    assert(boycott_company(Company_Name, Reason)).

% Remove a boycott company
remove_boycott_company(Company_Name, _) :-
    retract(boycott_company(Company_Name, _)).
