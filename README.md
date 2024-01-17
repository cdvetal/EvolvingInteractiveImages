# EvolvingInteractiveImages
 
Repository dedicated to Master's Dissertation in Design and Multimedia @ FCTUC.

Objective of disseration is the creation of a tool capable of evolving interactive expression-based imagery.

## Prerequisites

Lastest version of [Processing](https://processing.org/download) installed.

## Usage

There are two main programs: Evolver and Viewer.

### Evolver

Evolver is the program where you evolve imagery. Several iterations exist, they are numbered from earliest to newest in an ascending order. 

#### Controls

Controls depend on the used prototype's version; they can be found in the code inside **mousePressed** and **keyPressed** functions. Following buttons concern version 18 (sketch_230921a_18). 

<ins>LMB</ins>      — increase an individual's fitness. 

<ins>RMB</ins>      — set an individual's fitness to 0. 

<ins>Spacebar</ins> — progress to next generation. 

<ins>E</ins>        — toggle externalMode (if <em>externalVal</em> sways with time or is controlled by mouse movement). 

<ins>S</ins>        — export hovered individual's shader and image. 

<ins>A</ins>        — mute or unmute song. 

<ins>M</ins>        — change song. 

The program can be found at:

<pre>
├── ProcessingPrototype
│   ├── MainIterations
│   │   ├── sketch_xxxxxxx_version
|   │   │   ├── sketch_xxxxxxx_version.pde
</pre>

### Viewer

Viewer is the program where you can visualize evolved imagery.

#### Controls

Controls might be different than the presented ones; they can be found in the code inside **mousePressed** and **keyPressed** functions.

<ins>LMB</ins>      — show next individual. 

<ins>RMB</ins>      — show previous individual. 

<ins>Mouse position horizontally</ins> — speed at which <em>externalVal</em> changes (left is 0) . 

<ins>E</ins>        — export current individual's image. 

<ins>A</ins>        — mute or unmute song. 

<ins>M</ins>        — change song. 

The program can be found at:

<pre>
├── Shader Viewer
│   ├── sketch_231014a
│   │   ├── sketch_231014a.pde
</pre>

## Contributors

João Maria Santos

Tiago Martins

Penousal Machado
