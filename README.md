# Round-Robin-Arbiter
Designed and implemented a parameterizable Round Robin Arbiter in SystemVerilog for managing access to shared resources among multiple requesters in a fair and efficient manner.


**Round Robin Arbiter – SystemVerilog RTL Implementation**

**Overview**\
This project implements a parameterizable Round Robin Arbiter in Verilog that fairly arbitrates among multiple requesters (In) and grants access (Grant) to one of them in a rotating manner. The arbiter avoids starvation by rotating the priority based on the last granted agent.\

**Key Features**
* Parameterizable number of agents (NumOfAgents).
* Implements fair arbitration using round-robin logic.
* Uses priority encoder for selecting the next grant.
* Fully synthesizable RTL code without loops inside procedural blocks.
* Handles reset and tracks last granted agent.


**Design Details**\
_Top Module_: RoundRobinArb
* Parameters:NumOfAgents: Number of input requesters (default 4)
* Inputs:
  * clk: Clock signal
  * rstb: Active-low reset
  * In[NumOfAgents-1:0]: Request lines from agents
* Output:
  * Grant[NumOfAgents-1:0]: One-hot grant signal indicating selected agent
* Internal Signals:
  * LastGrant: Stores index of the last granted agent to ensure round-robin fairness.
  * RotIn: Circularly right-shifted In vector based on LastGrant to rotate the priority.
  * RotGrant: Result from the priority encoder, granting to the first '1' in RotIn.

**Functionality:**\
The arbiter rotates the input request vector so that the agent following the last granted agent gets higher priority.\
A priority encoder selects the first active request in the rotated input (RotIn).\
The rotated grant is shifted back to match the original input positions and drive Grant.\
LastGrant is updated with the index of the newly granted agent.
