BUGS
====

BUG VISUAL: O efeito das linhas fica zuado em determinadas resoluçoes, ele tem que ter a ver com a resolucao da tela, não pode ser reescalado
BUG: particle effects continue after exiting game
BUG: Back key does not work properly
NOREPRO: Backspace on name does not work
PERF: weird perf thing
First ball doesnt show up in next balls
Screen limits are weird (especially in the bottom of the screen)

Crash (Very close to line, thought I had lost but destroyed ball)
Error

game.lua:338: Attempt to use destroyed body.


Traceback

[C]: in function 'getPosition'
game.lua:338: in function 'func'
lib/doubly_linked_list.lua:21: in function 'forEach'
game.lua:337: in function 'update'
main.lua:243: in function 'update'
[C]: in function 'xpcall'



