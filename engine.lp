
% pred_range = discrete values allowed
% abs_range = continuous values allowed
% rel_range = continuous value changes
pred_range(c1;c2,loc,hand;deck;mat).


entity(c1;c2;player).
has(player,health).
has(c1;c2,loc).

init((c1,loc,deck)).
init((c2,loc,deck)).
init((player,health,5)).

action(draw_card).
pre_p(draw_card,(c1,loc,deck)).
post_p(draw_card,(c1,loc,hand)).
cost(draw_card,2).


action(play_card).
pre_p(play_card,(c1,loc,hand)).
post_p(play_card,(c1,loc,mat)).
cost(play_card,2).

action(cast_spell).
%gte_v(cast_spell,(player,health,5)).
lte_v(cast_spell,(player,health,5)).
%eq_v(cast_spell,(player,health,5)).
post_v(cast_spell,(player,health,1)).
cost(cast_spell,1).





%%% PLANNER %%%
holds(0,F) :- init(F).
#show holds/2.

time(1..t).


% scheduling - limit net cost of actions taken
0 #sum{ C,A : act(T,A) : cost(A,C) } 3 :- time(T).
#show act/2.

:- act(T,A), pre_p(A,F), not holds(T-1,F). % require preconditions
:- act(T,A), eq_v(A,(E,P,Vpre)), holds(T-1,(E,P,V)), Vpre != V.
:- act(T,A), gte_v(A,(E,P,Vpre)), holds(T-1,(E,P,V)), Vpre > V.
:- act(T,A), lte_v(A,(E,P,Vpre)), holds(T-1,(E,P,V)), Vpre < V.

holds(T,(E,P,V)) :- holds(T-1,(E,P,V)), 
		 { act(T,A): post_p(A,(E,P,_)) } 0, 
		 { act(T,A): post_v(A,(E,P,_)) } 0, 
		 time(T). % maintain inertia for unaffected


holds(T,F) :- act(T,A), post_p(A,F). % update fluent to new

% update to new value
% but only if some update posted
update(T,(E,P,Dv)) :- Dv = #sum{ V,A : act(T,A), post_v(A,(E,P,V)) }, 
		   time(T), has(E,P), 
		   1 #sum{ V,A : act(T,A), post_v(A,(E,P,V)) }.
#show update/2.
holds(T,(E,P,V+Dv)) :- act(T,A), update(T,(E,P,Dv)), holds(T-1,(E,P,V)).