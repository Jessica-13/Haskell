# Haskell Projet      (TC - LOGO)


## Design

The design is quite simple. On the page it is possible to find an indication "Type in your code below:", a section in which to insert the desired instruction, a button to submit the instruction and a box to observe the final result.


### Files :

The folder contains the `elm.js` file, the `elm.json` file and the `style.css` file used for communicating with the `Main.elm` file and for shaping the `index.html` file.

HTML describes the content of a web page, while CSS describes its appearance. SVG describes vector drawings, which can be directly included in a web page. 

The `elm-stuff` folder was used to obtain the tools needed to develop the main file in the ELM language.

<hr />

### STEPS:

To run the program just run the `index.html` document on any web browser. 
Then it is possible to write an instruction that must respect the TcTurtle language, a language invented at the department and inspired by Turtle graphics. (Find out more - https://en.wikipedia.org/wiki/Turtle_graphics).

Some test instructions : 
   - [Repeat 360 [ Right 1, Forward 1]] <br/>
   - [Forward 100, Repeat 4 [Forward 50, Left 90], Forward 100] <br/>
   - [Repeat 36 [Right 10, Repeat 8 [Forward 25, Left 45]]] <br/>
   - [Repeat 8 [Left 45, Repeat 6 [Repeat 90 [Forward 1, Left 2], Left 90]]] <br/>


![visualisation](https://user-images.githubusercontent.com/80853919/152233863-501e37e6-e8be-4614-bb0f-0e3524cc5b1a.png)


<hr />

## Implementation

The ELM code is based on the input of a string that is verified through the use of a specific PARSER and then converted into a list of instructions that are executed one after the other thanks to recursive functions.
The result is processed and displayed through a progressively updated Browser.sandbox.

For more details, refer to the comments throughout the `Main.elm` code.


## Requirements

Tested on
```
node v16.13.2
elm 0.19.1
```
<hr />

## Credits

<p align="center">
  <img src="http://www.insa-lyon.fr/sites/www.insa-lyon.fr/files/logo-coul.jpg" width="350" alt="logo INSA">
</p>

<strong>INSA Lyon</strong>, Lyon Institute of Applied Sciences <br/> 
Department of Telecommunications, Services and Uses, 3TC, Group 1

Project related to the ELP module (Ecosystème des langages de programmation) - Haskell -> ELM. <br/>
Link for the bjectives of the projet - https://perso.liris.cnrs.fr/tristan.roussillon/ens/elm/project.md.html

### Referent Professor

ROUSSILLON Tristan

### Authors

SPERA Jessica <br/>
TEYS Louis <br/>
LEE Chanbin <br/>
AJAMI BOUSTAJI Wissam <br/>
BELLAGNECH Hiba <br/>
HOUDA Touil <br/>



