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

## Demos

- Short demo, showcasing basic usage of the application: https://www.youtube.com/watch?v=sPCqBKYrbK0&ab_channel=NicoleRaveszani

- Longer demo, showcasing not only the app usage, but also explaining how to build the godot project (which is also explained in this file) and implementation details: https://www.youtube.com/watch?v=kRcmfELIPzQ&ab_channel=NicoleRaveszani.

## Proof generation and verification

As previously mentioned, the interaction of the user with our program is not proven itself. When the player 
wins the game, if he thinks his result will put him within the top best scores registered in ethereum (with a 
limit of 10), he will generate a list with all the tiles he has blocked (in order of usage) and feed that 
to our program proven, which is a verion of the game's logic not blocked by human interaction. The game's logic 
will then proceed to recreate the session with the provided inputs (this is possible since everything in our game is deterministic, it does not depend on random or pseudorandom numbers generation), and generate a proof
of the trapped bug, exposing the steps until the bug was trapped (the number of blocked tiles) as the public 
input. After the proof generation, it is sent to aligned for verification and, after confirmation, the program's 
smart contract will be called, which will check that the program is correctly verified and, if done properly 
will update the list of record holders if necessary. The less amount of tiles used to trap the bug, the better. 
This way, the user has proven that he knows how to win the game in n steps, without showing the choice and order of the tiles he has blocked to get to that score, and persisted this in ethereum in a way that is 
cheaper (and more private) than running the entire logic in the blockchain.

## Code structure

### Smart contract

Our smart contract receives the data necessary for corroboration of proof verification inclusion in aligned, 
and if that is successul it updates the record holders list. The deployed contract code can be found in 
`contract/verifier_v2.sol`.

### Shared

Here goes the code for both the proof generation and game backend. Since the code for proof generation must 
be in rust, we decided to create this library to evade the duplication of logic. It can be found in 
`risc_zero/methods/guest/src/shared`

### Game's code

The files for the godot project and not shared rust code go into the `game` folder. In the path 
`game/godot` we store all the files related to the godot program, and `game/rust` the files that 
create the interface for usage of rust functions in godot.

### Risc zero

Here goes the code used to trigger the proof generation, and the code itself that will get proven. In the 
main of the host folder we execute the proof generation (with an execution defined by the the contents of 
the methods folder), interaction with user wallets, with aligned, and with ethereum.

## Installation

The following sections explain how to install the programs necessary to run the game in linux.

### Foundry

The keystores we use for proof verification in ethereum are generated using Foundry. You can install it 
by following the instructions [here](https://getfoundry.sh/).

### Docker

Since built images for programs depend on the underlying architecture of the computed that generates them,
the same proof will get different program ids for the same program. Because of this, a deterministic build 
must be made, and docker helps us by providing an architecture that will be the same in every machine that 
runs it. If you do not have docker installed, you can follow the instructions in [this link](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04). Make sure that 
you have not installed docker using snap, since the determininstic build will fail if you do so.

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


![Godot's page](/imgs/godot_page.png)


This will download a zip file


![Downloaded godot file](/imgs/downloaded_godot.png)


Which will look like this when extracted


![Extracted godot zip](/imgs/extracted_godot.png)


To start running godot, you can double click the file or run `./Godot_v4.3-stable_linux.x86_64` in the 
directory where the file is stored (take into account that depending on when you are following these
instructions, the program's version might have changed, and therefore also the file's name).

## Execution

### Executable

If you decide to use the executable provided in the 1.0.1 release files, then it should suffice with the command

```
./'CatchTheBug!.x86_64'
```

in the directory that has both the `CatchTheBug!.x86_64` and `librust_project.so` files. If the execution is
forbidden, running the command `chmod +x ./'CatchTheBug!.x86_64'` might help.

### Godot project

If you want to make sure you are running the code contained in the repository then you must follow 
these steps:

- Go to `aligned-hackathon-oct-2024/game/rust` and run `cargo build`
- Run the Godot program executed downloaded previously and import the file at 
`aligned-hackathon-oct-2024/game/godot/project.godot`

![Running godot exec](/imgs/run_godot.png)

![Importing godot project](/imgs/import_project.png)

![Choosing the game's godot project](/imgs/choose_godot_project.png)

![Opening the imported project](/imgs/import_and_edit.png)

- Click run

![Starting the game's execution](/imgs/run_the_game.png)

## Program usage

After running the game, press the start button. This will take you to the following screen

![Game start](/imgs/game_start.png)

Our objective is to completely trap the bug, preventing him from moving to another tile. If he reaches 
the limits of the map, the player loses. The player plays this game so that he can get his best result 
into the game's leaderboard, which is stored in a smart contract in ethereum. Since it does not make 
sense to upload a failure, we do not provide that option. Here we can see an example of a player victory

![Game start](/imgs/game_won.png)

When the player wins, he is gets the option to serialize in a file the list of tiles he chose to block, in 
the order that he blocked them. In the image provided, we can see the button hightlighted. When pressed, the 
user will choose a path where to store the serialized inputs, with the following pop up getting revealed

![Game start](/imgs/inputs_serialization_path.png)

After choosing a folder, the program will write into it the file `player_input.json`, which contains the 
mentioned serialization of player inpus.

Until this point, we have not interacted with ethereum, aligned, or any proof generation program. However, 
now that we have the inputs serialization, we can start the process of proof and verification. We should 
open a console in the path `aligned-hackathon-oct-2024/risc_zero` and run the command 

```
cargo run -- --keystore-path <PATH_TO_WALLET_FOUNDRY_KEYSTORE> --inputs-path <PATH_TO_USER_INPUTS_FILE>
```

Then, the user will be prompted for his keystore file password and asked if he wants to add some ethers in 
aligned (as a requirement of the hackathon, we are using the Holesky network). After choosing our answer, 
the proof generationg will start.

![Proof generation start](/imgs/proof_generation_start.png)

This will take a while, and the amount of time it takes will depend on the amount of steps you took to 
trap the bug and your hardware capabilities, but in general you should expect this to take around 20 
minutes. After the proof generation finishes we can see the proof's public input (which is the amount of 
steps the player took to win the game), and the user will be asked for confirmation for verification in 
aligned

![Upload to aligned](/imgs/upload_to_aligned_prompt.png)

Once aligned reports a successful proof verification, our program will call the verification smart contract, 
which queries the aligned contract for inclusion verification, alongside some verifications for validation of 
commited public inputs and image id. If this is successful, the contract proceeds to check if the received 
steps amount deserves to replace a current record, and finishes the transaction's execution.

![aligned success](/imgs/aligned_verification.png)

After the smart contract finishes it's execution, if we have uploaded a record, worthy score, we can 
check it out in the leaderboard, which queries the public variables of our smart contract. Note that 
the record list has a limit of 10 members, so the first 10 people to upload a score will get theirs 
stored. Also, the order in which the record was uploaded is taken into account, so if two players 
have the same score, the one who got it first will have a better position in the record holders storage. 
Here we can see how the leaderboard looks like after our uploaded result:

![Leaderboard](/imgs/leaderboard.png)

An example of a more populated leaderboard would look like this

![Populated leaderboard](/imgs/populated_leaderboard.png)

Take into account that for the final deployment we will not have this leaderboard, but a new one with 
fewer uploaded records used for testing.

## Team members

- Drasungor

Software engineering student, finishing his final project about a computing power donation system 
that makes use of Risc0 for execution integrity check. Working in backend web development, but interested 
mainly in complex algorithms. In charge of the proof generation and verification, and part of the godot
development.

- nravesz

Software engineer, working in the game development industry. Hobby artist. In charge of assets creation 
(Aligned themed) and part of godot development.


## Possible improvements

- Addition of levels: the project currently presents a single level.
- Addition of varied blocking tiles: more type of tiles could be added for the user, with varying cost 
of usage to affect the final score.
- Addition of community levels: by adding the hash of the played level to the public inputs, we can allow 
for users to prove the completion in n steps of a level designed by another player.
- Allowing more players in the record holders lists.
- Addition of map shapes: more shapes other than a rectangle could be added, maybe even maps with free style.
- Addition of tile types: different types of map tiles with different abilities could be added.
- Possible improvements in bug movement logic: right now the bug uses dijkstra each turn to look for the 
current best path, which pumps up the proof generation time, we could try some modifications to check if 
we can get a shorter proof generation while not heavily affecting the logic of the bug's movement.

## Development issues

- The project started with 3 members, which distributed the tasks of assets creation, game engine logic and 
proof generation and verification logic. Due to Lack of time, one of the members left the team, which made 
the rest of us reorganize our tasks and take responsibilities outside of our expertise.
- Unexpected error with risczero's deterministic build caused by snap installation of docker instead of 
the usual.
- Doubts about good coding practices regarding zkp: 

```
Should we redeploy our smart contract if we change our program's implementation due to bug fixing, 
new features or dependencies updates?

Any modification in the proven code will cause a modification in the program's id. We could set a public 
contract function callable only by an owner to update the program id we compare the uploaded proof's to, 
but that would allow our users to be cheated by the owner, who could update the id for his own benefit, 
therefore reducing the trust in the contract.
```

```
Should we aim to reduce more the execution time of proof generation?

Our program's proof generation time is arount 20 minutes, depending on the use cases, this could be pretty 
good, or horrendous. However, the case could be that the user generally finds that execution time pretty tame, 
and using resources for intensive optimization could then be considered a waste of time. This should be 
answered as proof generation and verification on ethereum gains more track.
```

