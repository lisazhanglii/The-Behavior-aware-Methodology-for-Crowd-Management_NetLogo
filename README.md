# The-Behavior-aware-Methodology-for-Crowd-Management_NetLogo
This is the assistant code for thesis The-Behavior-aware-Methodology-for-Crowd-Management.
DEMO URL LINK:https://youtu.be/jApC8Nh8fM0


## How to Run the Model and Get the Best Switch-index

1. Set the desired parameters of environment and swich-index (10, 20, 30, 40 separately)in the "setup" procedure.
2. Click the "setup" button to initialize the model.
3. Click the "go" button to start the simulation.
4. The simulation will run for a specified number of ticks, and you can observe the movement and behavior of the crowd.
5. Right-click the panel of "frequency of changing stages" and "panic&surge average" and then click export separately.
6. Open the results excel sheets and get the frequency and average panic&surge value at B1018, store the value.
7. Fill the y1 array of visualization.py with the result of "frequency of changing stages" in switch-index 10, 20, 30 40 separately. Change the figure title in line 34 as well.
8. Fill the y2 array of visualization.py with the result of "panic&surge average" in switch-index 10, 20, 30 40 separately.
9. Run the visualization.py and get the visualization result to get the best switch-index under this environment setting.



## Model Components
Persons
The crowd is composed of individual persons.
Each person has various attributes such as their current state (start, walk, wait, surge, panic, end), current stage, speed, comfort zone, and rationality.
Persons can move, change their direction, and interact with other persons and the environment.

Environment
The environment is represented by a grid of patches.
Patches can have different properties such as structure type (floor, stage, wall, obstacle), density, and potential values for different stages.
Persons move on the floor patches and try to reach the stages.

Potential Map
The potential map is used to guide persons towards the stages.
It assigns potential values to patches based on their distance and direction from the stages.
The potential map is updated during the simulation based on the movement of persons.

## Model Behavior
The model follows the following general behavior:

Initialization: The model initializes the global variables and sets up the environment, stages, and persons.

Simulation Loop: The model enters a loop where it repeatedly executes the following steps:
1. Person Movement: Each person determines its current direction and moves towards the next patch.
2. Stage Selection: Persons may change their stage choice based on their rationality and the current environment conditions.
3. State Transitions: Persons may transition between different states (start, walk, wait, surge, panic, end) based on their current situation.
4. Update Globals: The model updates global variables to track and record relevant information.
5. Tick: The model advances the simulation time by one tick.



## Brief Explanation of Functions
globals:
global variables

InitializeGlobals:
initialize global variables

patches-own:
set the attributes of patches

persons-own:
set the attributes of persons

to setup:
set up the basis settings. It will be triggered by the set-up button in the interface;

create-env:
set up stages and potential-map

setup-areas:
divide the patches into 10x10 areas; each area is consisted by 5x5 patches

to go:
run the experiment. It will be triggered by the go button in the interface;

to str4:
ask the individual to go left stage;

to str5:
ask the individual to go right stage;

to str6:
ask the individual to go bar/restroom;

to move-now:
set up the states of persons

to move-forward:
get the target from attribute and decide move or not

to setup-agents:
set up persons' attributes

to setup-potential-map:
set up potential field
