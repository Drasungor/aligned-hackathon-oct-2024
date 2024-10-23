# Trap the bug

This is a submission for the [Aligned](https://alignedlayer.com/) Hackathon. We have implemented 
a Zero Knowledge version of the game commonly known as "Trap the cat", in which users can generate
a proof of their resolution and, if they desire it verify that proof in Aligned and persist the
result of the gaming session in ethereum as a record.

Our project consists of a godot project with rust components, which uses a rust library we implemented to
run the game logic. When a user boots up the game, it does not execute any ZK related operations, since we 
are not interested in proving menues usage, a paused game, nor frontend assets. He then proceeds to play 
the level provided by us and, if he successfully completes it, the list of user inputs is serialized and stored 
in a file. The user can then run the proving and verifying script, which receives the list of user inputs and 
recreates the gaming session for proof generation.