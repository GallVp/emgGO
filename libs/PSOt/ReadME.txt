-------------------------------------------------------------
-------------------------------------------------------------
PSOt, particle swarm optimization toolbox for matlab.

May be distributed freely as long as none of the files are 
modified. 

Send suggestions to bkbirge@yahoo.com 

Updates will be posted periodically at the Mathworks User 
Contributed Files website (www.mathworks.com) under the 
Optimization category.

To install:
Extract into any directory you want but make sure the matlab 
path points to that directory and the subdirectories 
'hiddenutils' and 'testfunctions'. 

Enjoy! - Brian Birge

-------------------------------------------------------------
-------------------------------------------------------------

INFO
Quick start: just type ... out = pso_Trelea_vectorized('f6',2) 
and watch it work!

This is a PSO toolbox implementing Common, Clerc 1", and 
Trelea types along with an alpha version of tracking changing
environments. It can search for min, max, or 'distance' of 
user developed cost function. Very easy to use and hack with 
reasonably good documentation (type help for any function and
it should tell you what you need) and will take advantage of 
vectorized cost functions. It uses similar syntax to Matlab's
optimization toolbox. Includes a suite of static and dynamic 
test functions. It also includes a dedicated PSO based neural 
network trainer for use with Mathwork's neural network toolbox.

Run 'DemoPSOBehavior' to explore the various functions, options, 
and visualizations. 

Run 'demoPSOnet' to see a neural net trained with PSO 
(requires neural net toolbox).


This toolbox is in constant development and I welcome 
suggestions. The main program 'pso_Trelea_vectorized.m' lists 
various papers you can look at in the comments.

Usage ideas: to find a global min/max, to optimize training of 
neural nets, error topology change tracking, teaching PSO, 
investigate Emergence, tune control systems/filters, paradigm 
for multi-agent interaction, etc.

-------------------------------------------------------------
-------------------------------------------------------------


Files included:


** in main directory:

0) ReadMe.txt - this file, duh
1) A Particle Swarm Optimization (PSO) Primer.pdf  -  powerpoint converted to pdf presentation explaining the very basics of PSO
2) DemoPSOBehavior.m - demo script, useful to see how the pso main function is called
3) goplotpso4demo.m - plotting routine called by the demo script, useful to see how custom plotting can be developed though this routine slows down the PSO a lot
4) goplotpso.m - default plotting routine used by pso algorithm
5) pso_Trelea_vectorized.m - main PSO algorithm function, implements Common, Trelea 1&2, Clerc 1", and an alpha version of tracking environmental changes.



** in 'hiddenutils'

1) forcerow, forcecol.m - utils to force a vector to be a row or column, superseded by Matlab 7 functions I believe but I think they are still called in the main algo
2) normmat.m - takes a matrix and reformats the data to fit between a new range, very flexible
3) linear_dyn, spiral_dyn.m - helpers for the dynamic test functions listed in the 'testfunctions' directory



** in 'testfunctions'

A bunch of useful functions (mostly 2D) for testing. See help for each one for specifics. Here's a list of the names:

Static test functions, minima don't change w.r.t. time/iteration:
 1) Ackley
 2) Alpine
 3) DeJong_f2
 4) DeJong_f3
 5) DeJong_f4
 6) Foxhole
 7) Griewank
 8) NDparabola
 9) Rastrigin
10) Rosenbrock
11) Schaffer f6
12) Schaffer f6 modified (5 f6 functions translated from each other)
13) Tripod
 
Dynamic test functions, minima/environment evolves over time (NOT iteration, though easily modifed to do so):
14) f6_bubbles_dyn
15) f6_linear_dyn
16) f6_spiral_dyn



** in 'nnet' (all these require Matlab's Neural Net toolbox)

 1) demoPSOnet - standalone demo to show neural net training
 2) trainpso   - the neural net toolbox plugin, set net.trainFcn to this
 3) pso_neteval - wrapper used by trainpso to call the main PSO optimizer, this is the cost function that PSO will optimize
 4) goplotpso4net - default graphing plugin for trainpso, shows net architecture, relative weight indications, error, and PSO details on run
