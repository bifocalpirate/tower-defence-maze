# tower-defence-maze
A demo of a procedurally generated maze that solves itself using a Navigation2D.

This is a godot project where I'm trying to develop a tower-defence game. As of this update 
* Every time the game runs it generates a new maze and places the start flag in the top left corner, and the finish flag at a random location.
* It then proceeds to solve the maze using a Navigation2D object, and on the delta the animated sprite moves along the path until it reaches the finish flag.
* The maze is guaranteed to be solvable as it is based on a connected graph.

I developed all the sprites from scratch using aseprite.
