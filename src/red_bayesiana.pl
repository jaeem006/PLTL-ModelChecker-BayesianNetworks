%here is the rule for reasoning in bayesian network from the book :
prob([X|Xs],Cond,P) :- !,
	prob(X, Cond, Px),
	prob(Xs, [X|Cond], PRest),
	P is Px * PRest.

prob([],_,1):- !.

prob(X, Cond, 1) :-
    member(X, Cond),!.

prob(X, Cond, 0) :-
    member(\+ X, Cond), !.

prob(\+ X, Cond, P) :- !,
    prob(X, Cond, P0),
    P is 1-P0.

%Use Bayes rule if condition involves a descendant of X
prob(X, Cond0, P):-
    delete(Y, Cond0, Cond),
    predecessor(X,Y),!,             %Y is a descendant of X
    prob(X, Cond, Px),
    prob(Y, [X|Cond], PyGivenX),
    prob(Y, Cond, Py),
    P is Px * PyGivenX / Py.        %Assuming Py > 0

%Cases when condition does not involves a descendant

prob(X, _, P) :-
    p(X, P),!.                      % X a root cause - its probability given

prob(X, Cond, P) :- !,
    findall((CONDi, Pi), p(X,CONDi,Pi), CPlist),        %Condition on parents
    sum_probs(CPlist, Cond, P).

sum_probs([],_,0).
sum_probs([(COND1,P1) | CondsProbs], COND, P) :-
    prob(COND1, COND, PC1),
    sum_probs(CondsProbs, COND, PRest),
    P is P1 * PC1 + PRest.


predecessor(X, \+ Y) :- !,          %Negated variable Y
    predecessor(X,Y).

predecessor(X,Y) :-
    parent(X,Y).

predecessor(X,Z) :-
    parent(X,Y),
    predecessor(Y,Z).

member(X, [X|_]).
member(X, [_|L]) :-
    member(X,L).

delete(X, [X|L], L).
delete(X, [Y|L], [Y|L2]) :-
    delete(X, L, L2). 

% Base de conocimientos.
parent(burglary,sensor).
parent(lightning,sensor).
parent(sensor,alarm).
parent(sensor,call).

p(burglary,0.001).
p(lightning,0.02).
p(sensor,[burglary,lightning],0.9).
p(sensor,[burglary,\+lightning],0.9).
p(sensor,[\+burglary,lightning],0.1).
p(sensor,[\+burglary,\+lightning],0.001).
p(alarm,[sensor],0.95).
p(alarm,[\+sensor],0.001).
p(call,[sensor],0.9).
p(call,[\+sensor],0.0).
