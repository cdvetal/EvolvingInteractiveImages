# EvolvingInteractiveImages

Repository dedicated to Master's Dissertation in Design and Multimedia @ FCTUC.

Objective of disseration is the creation of a tool capable of evolving interactive expression-based imagery.

## Watch the videos

[<img src="GitMedia/demo_cover.png" width="50%">]()

[<img src="GitMedia/visual_performance_cover.png" width="50%">](https://www.youtube.com/watch?v=_cYH_BOW8f8)

[<img src="GitMedia/evaluation_compilation_cover.png" width="50%">](https://youtu.be/OE8MPBrM1KE?si=NDAiZZutvx5NqRxL)

## Prerequisites

**[Processing 4.2](https://github.com/benfry/processing4/releases/tag/processing-1292-4.2) installed**

**Processing's Audio and Video Libraries:**
- Open Processing 4.2
- Go to Tools > Manage Tools
- Select Libraries Tab
- Search and install "Video Library for Processing 4" by the Processing Foundation
- Search "Sound" by the Processing Foundation

## Usage

There are two main programs: Evolver and Viewer.

### Evolver

Evolver is the program where you evolve imagery.  

#### GUI

<img src="GitMedia/setup.png" width="100%">
<img src="GitMedia/population.png" width="100%">
<img src="GitMedia/img_tree.png" width="100%">

#### Location

<pre>
├── src
│   ├── Evolver
│   │   ├── Evolver.pde
</pre>

### Viewer

Viewer is the program where you can visualize evolved imagery.

#### Location

<pre>
├── src
│   ├── Viewer
│   │   ├── Viewer.pde
</pre>

## Known Errors

**Visual Bugs**  
May happen when using latest Processing Version (4.3 at the time of writing). For that reason we recommend using [Processing 4.2](https://github.com/benfry/processing4/releases/tag/processing-1292-4.2)

**Windows - Could not run the sketch (Target VM failed to initialize)**  
To fix this error you must change the dedicated graphics card when running Processing programs.  
To do so on Windows follow [this guide](https://pureinfotech.com/set-gpu-app-windows-10/). Apply the highest performance setting on the file *java.exe* found at *processing\processing-4.2-windows-x64\processing-4.2\java\bin\java.exe* in your machine.

**MacOS - Could not run the sketch (Target VM failed to initialize)**  
Unknown fix. Disabling camera as input may stop the issue (in *Evolver* by disabling bri in the function set).

**MacOS - Could not compile shaders**  
Mac operating system can only handle older versions of OpenGL. However, mewly created shaders using this system should work.

## Examples of static outputs

<img src="GitMedia/img (1).png" width="50%">
<img src="GitMedia/img (2).png" width="50%">
<img src="GitMedia/img (3).png" width="50%">
<img src="GitMedia/img (4).png" width="50%">
<img src="GitMedia/img (5).png" width="50%">
<img src="GitMedia/img (6).png" width="50%">

## Contributors

*Author:*  
João Maria Santos

*Supervisers:*  
Tiago Martins  
Penousal Machado
