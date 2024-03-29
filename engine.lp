% turns are made up of phases; time is indices over 1D version
% NOTE: 2D point -> idx = y * width + x
% time = turn * max_phases + phase
% phase = time \ max_phases
% turn = time / max_phases [need floor but ASP does automagically]
turn(0..t).
phase(0..p).

time(0..t*p-1).



% initialize state
holds(-1,F) :- init(F).
#show holds/2.

%% ACTION SELECTION %%

% scheduling - limit net cost of actions taken
0 #sum{ C,A : act(T,A) : cost(A,C) } 3 :- time(T).
#show act/2.
% note: currently uniform action max across phases
% soln?: rescale per-phase costs by max phase costs
% soln?: choose phase max cost, then generate per-phase cost constraints

% enforce preconditions
:- act(T,A), pre_p(A,F), not holds(T-1,F).
:- act(T,A), eq_v(A,(E,P,Vpre)), holds(T-1,(E,P,V)), Vpre != V.
:- act(T,A), gte_v(A,(E,P,Vpre)), holds(T-1,(E,P,V)), Vpre > V.
:- act(T,A), lte_v(A,(E,P,Vpre)), holds(T-1,(E,P,V)), Vpre < V.

% DEBUG: show number of each action at each time
num_act(T,A,Na) :- Na = #sum{ 1 : act(T,A) }, time(T), action(A).
#show num_act/3.

% enforce previous actions occurring
:- act(T,A), pre_ev(A,Apre), not act(Tpre,Apre) : Tpre<T, time(T;Tpre).

% enforce turn phases
:- act(T,A), phase(A,Tp), T\p != Tp.


%% STATE UPDATES %%

% maintain inertia for unaffected
holds(T,(E,P,V)) :- holds(T-1,(E,P,V)), 
		 { act(T,A): post_p(A,(E,P,_)) } 0, 
		 { act(T,A): post_v(A,(E,P,_)) } 0, 
		 time(T).

% update fluent to new
holds(T,F) :- act(T,A), post_p(A,F). 

% update to new value
% but only if some update posted
update(T,(E,P,Dv)) :- Dv = #sum{ V,A : act(T,A), post_v(A,(E,P,V)) }, 
		   time(T), has(E,P),
		   1 #sum{ 1,A : act(T,A), post_v(A,(E,P,V)) }.
#show update/2.

holds(T,(E,P,V+Dv)) :- act(T,A), 
			update(T,(E,P,Dv)), 
			holds(T-1,(E,P,V)).

