# The-Behavior-aware-Methodology-for-Crowd-Management_NetLogo
This is the assistant code for thesis The-Behavior-aware-Methodology-for-Crowd-Management.
DEMO URL LINK:https://youtu.be/jApC8Nh8fM0

## Running this project(example in the thesis)



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
set up exits and potential-map

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
