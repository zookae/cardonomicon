% $ clingo4 domains/predefined.lp engine.lp -c t=2 -c p=2 20 | sed -e 's/\s\+/\n/g' | egrep 'Answer|num_act|bad_order'

% pred_range = discrete values allowed
% abs_range = continuous values allowed
% rel_range = continuous value changes
pred_range(c1;c2,loc,hand;deck;mat).

abs_range(player,health,0..5).
rel_range(player,health,-1;1).

entity(c1;c2;player).
has(player,health).
has(c1;c2,loc).

init((c1,loc,deck)).
init((c2,loc,deck)).
init((player,health,5)).

% pre_p	= require predicate holds discrete value
% post_p = set predicate value

% gte_v = require value is greater than or equal to
% lte_v = require value is less than or equal to
% eq_v = require value is equal to
% post_v = relative change to make to value

% pre_ev = require prior action to have occured (at any time...)

% phase = require action on specific turn phase
% cost = impose costs to scheduling actions


action(draw_card).
pre_p(draw_card,(c1,loc,deck)).
post_p(draw_card,(c1,loc,hand)).
cost(draw_card,2).
phase(draw_card,0).

%*
action(cast_spell).
%gte_v(cast_spell,(player,health,5)).
%lte_v(cast_spell,(player,health,5)).
%eq_v(cast_spell,(player,health,5)).
post_v(cast_spell,(player,health,1)).
cost(cast_spell,1).
phase(cast_spell,1).
*%


action(play_card).
%pre_p(play_card,(c1,loc,hand)).
post_p(play_card,(c1,loc,mat)).
cost(play_card,2).
phase(play_card,0).
%pre_ev(play_card,draw_card).

:- not act(2,play_card).



%*
action(cast_super_spell).
gte_v(cast_super_spell,(player,health,2)).
post_v(cast_super_spell,(player,health,-2)).
cost(cast_super_spell,1).

:- not act(1,cast_super_spell).
*%