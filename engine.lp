
% pred_range = discrete values allowed
% abs_range = continuous values allowed
% rel_range = continuous value changes
pred_range(c1;c2,loc,hand;deck;mat).


init((c1,loc,deck)).
init((c2,loc,hand)).

action(draw_card).
pre_p(draw_card,(c1,loc,deck)).
post_p(draw_card,(c1,loc,hand)).
cost(draw_card,2).


action(play_card).
pre_p(play_card,(c1,loc,hand)).
post_p(play_card,(c1,loc,mat)).
cost(play_card,2).



%%% PLANNER %%%
holds(0,F) :- init(F).
#show holds/2.

time(1..t).


% scheduling - limit net cost of actions taken
0 #sum{ C,A : act(T,A) : cost(A,C) } 3 :- time(T).
#show act/2.

:- act(T,A), pre_p(A,F), not holds(T-1,F). % require preconditions

holds(T,F) :- act(T,A), post_p(A,F). % update fluent to new
holds(T,(E,P,V)) :- holds(T-1,(E,P,V)), { act(T,A): post_p(A,(E,P,_)) } 0, time(T). % maintain inertia for unaffected