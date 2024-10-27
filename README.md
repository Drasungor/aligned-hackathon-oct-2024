# Trap the bug

This is a submission for the [Aligned](https://alignedlayer.com/) Hackathon. We have implemented 
a Zero Knowledge version of the game commonly known as "Trap the cat", in which users can generate
a proof of their resolution and, if they desire it verify that proof in Aligned and persist the
result of the gaming session in ethereum as a record.

Our project consists of a Godot program with rust components, which uses a rust library we implemented to
run the game logic. When a user boots up the game, it does not execute any ZK related operations, since we 
are not interested in proving menues usage, a paused game, nor frontend assets. He then proceeds to play 
the level provided by us and, if he successfully completes it, the list of user inputs is serialized and stored 
in a file. The user can then run the proving and verifying script, which receives the list of user inputs and 
recreates the gaming session for proof generation. After the proof is generated, it is sent to Aligned for 
 verification and the smart contract for updating the records is called. 

## Proof generation and verification

As previously mentioned, the interaction of the user with our program is not proven itself. When the player 
wins the game, if he thinks his result will put him within the top best scores registered in ethereum (with a 
limit of 10), he will generate a list with all the tiles he has blocked (in order of usage) and feed that 
to our program proven, which is a verion of the game's logic not blocked by human interaction. The game's logic 
will then proceed to recreate the session with the provided inputs (this is possible since everything in our game is deterministic, it does not depend on random or pseudorandom numbers generation), and generate a proof
of the trapped bug, exposing the steps until the bug was trapped (the number of blocked tiles) as the public 
input. After the proof generation, it is sent to aligned for verification and, after confirmation, the program's 
smart contract will be called, which will check that the program is correctly verified and, if done properly 
will update the list of record holders if necessary. The least amount of tiles used to trap the bug, the better.


## Installation

### Risc0

This program uses [Risc0](https://risczero.com/) for proof generation, to install it you must execute the 
following commands:

```
curl -L https://risczero.com/install | bash
```  
```
rzup install cargo-risczero v1.0.1
```

### Godot

We provide in our releases an executable file to easily run the game on linux. However, if you do not trust us,
you can load the project, compile it and run it yourself. To do this, you must download the 
[Godot game engine](https://godotengine.org/download/linux/)

## Execution

### Executable

If you decide to use the executable provided in the release files, then it should suffice with the command

```
./CatchTheBug!.x86_64
```

in the directory that has both the `CatchTheBug!.x86_64` and `librust_project.so` files. If the execution is
forbidden, running the command `chmod +x ./CatchTheBug!.x86_64` might help.

### Godot project

If you want to make sure you are running the code contained in the repository then you must follow 
these steps:

- Go to `aligned-hackathon-oct-2024/game/rust` and run `cargo build`
- Run the Godot program executed downloaded previously and import the file at 
`aligned-hackathon-oct-2024/game/godot/project.godot`
- Click run

## Team members

```

COMPLETAR SECCION CON DATA DE CADA UNO

BORRAR BORRAR BORRAR BORRAR BORRAR BORRAR A README.md that describes the project and rationale, provides backgrounds/biographies of team members, and notes on challenges you faced when building the project.

```

## Possible improvements

- Addition of levels: the project currently presents a single level.
- Addition of varied blocking tiles: more type of tiles could be added for the user, with varying cost 
of usage to affect the final score.
- Addition of community levels: by adding the hash of the played level to the public inputs, we can allow 
for users to prove the completion in n steps of a level designed by another player.
- Allowing more players in the record holders lists.
- Addition of map shapes: more shapes other than a rectangle could be added, maybe even maps with free style.
- Addition of tile types: different types of map tiles with different abilities could be added.