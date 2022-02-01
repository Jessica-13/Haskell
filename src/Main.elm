module Main exposing (..)
import Debug
import Browser
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html, Attribute, div, input, text, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput,onClick)
import Parser exposing (..)


-------------------------------------------------------------------------------------------------------------------------
--FONCTIONS QUI TRANSFORMENT LIST INSTRUCTION -> MESSAGE SVG 

-- mon type instruction qui a comme arg (forward left right et repeat)
type  Instruction = Forward Float | Left Float | Right Float | Repeat Int (List Instruction)

--le type Coord_line qui va être utiliser pour transformer 2 tuple(x,y) en une coordonné de ligne 
-- exemple ma ligne va de (xa,ya) jusqu'à (xb,yb)
type alias Coord_line = 
  {
    xa : String,
    ya : String,
    xb : String,
    yb : String
  }
 
-- fonction qui converti les coordoner polaire(r,theta) que j'ai entrée en coordonné cartesienne (x,y)
avancer : Float -> Float -> (Float, Float)
avancer theta r = (
  r * cos(theta *(pi/180)), 
  r * sin (theta *(pi/180))
  )

-- fonction qui change l'angle à chaque instruction Right  
tourner : Float -> Float -> Float
tourner old val = if old+val >= 360 then (old+val-360)
                  else if old+val < 0 then (old+val+360)
                  else (old+val)

-- fonction qui te permet transformer mon instruction Repeat en ajout d'instruction dans ma list instruction
fusion_list : Int -> List Instruction -> List Instruction -> List Instruction
fusion_list iteration inst1 inst2 =
  if iteration == 0 then 
    inst2
  else 
    fusion_list (iteration-1) inst1 (List.append inst1 inst2)

-- fonction qui permet de transformer ma list d'instruction en List de tuple (x,y)
transformer : List Instruction -> List (Float, Float) -> Float -> List (Float, Float)
transformer instruction out s = 
  case instruction of
    [] -> out
    (x::xs) -> case x of
      (Forward i) -> transformer xs ((avancer s i) :: out) s
      (Right i) -> transformer xs out (tourner s (i))
      (Left i) -> transformer xs out (tourner s (-i))
      (Repeat i j) -> transformer (fusion_list i j xs) out s 

-- fonction qui converti mon tuple (x,y) en type Coord_line
convert_Coordline : Float -> Float -> Float -> Float -> Coord_line
convert_Coordline  nx ny cx cy  = {xa=String.fromFloat(cx),ya=String.fromFloat(cy),xb=String.fromFloat(nx+cx),yb=String.fromFloat(ny+cy)}

-- fonction qui converti ma list de tuple (x,y) en List type Coord_line
convert_List_Coordline : List (Float,Float) -> (Float,Float) -> List Coord_line -> List Coord_line
convert_List_Coordline list_float (cx,cy)  out = 
  case list_float of
    [] -> out
    (l::ls) -> case l of 
      (nx,ny) -> convert_List_Coordline ls (nx+cx,ny+cy) ((convert_Coordline nx ny cx cy )::out)


-- fonction qui converti Ma list de Coord_line en List de message Svg ( mes lignes )
message_svg : List Coord_line -> List (Svg msg) -> List (Svg msg)
message_svg  list_coord out =
  case list_coord of 
    [] -> out 
    (l::ls) -> case l of 
      {xa,ya,xb,yb} -> message_svg 
        ls
        ((line
          [ x1 xa
          , y1 ya
          , x2 xb
          , y2 yb
          , stroke "red"
          ][]) :: out)
-------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------
--Parser
-- on créer un parser pour verifier que la donné d'entrer de mon input est conforme au format type Instruction 
inst : Parser Instruction
inst = 
  oneOf
  [ succeed Forward 
    |. token "Forward" 
    |. spaces 
    |= float
  , succeed Left  
    |. token "Left" 
    |. spaces 
    |= float
  , succeed Right  
    |. token "Right" 
    |. spaces 
    |= float
  , succeed Repeat 
    |. token "Repeat" 
    |. spaces
    |= int
    |. spaces
    |= lazy (\_ -> listInst )
  ]

listInst : Parser (List Instruction) 
listInst =
  Parser.sequence
    { start = "["
    , separator = ","
    , end = "]"
    , spaces = spaces
    , item =  inst
    , trailing = Optional
    }

--variable pour tester le parser
--my_test = Parser.run listInst"[Repeat 8 [Left 45, Repeat 6 [Repeat 90 [Forward 1, Left 2], Left 90]]]"



-------------------------------------------------------------------------------------------------------------------------




-------------------------------------------------------------------------------------------------------------------------
--la varaible de type instruction que je met en entré dans le programme pour tester la partie Dessin 
--my_instruction = [Repeat 8 [Left 45, Repeat 6 [Repeat 90 [Forward 1, Left 2], Left 90]]]
-------------------------------------------------------------------------------------------------------------------------





-------------------------------------------------------------------------------------------------------------------------
-- MAIN


main =
  
  --initilise init et update et affiche mes view 
  Browser.sandbox { init = init, update = update, view = view }


-- MODEL

-- on a 2 models text_input qui acceuillera les instructions donné par l'utilisateur
-- et block un parser(List Instruction) qui sera utliser par viewSVG pour traiter et afficher une image SVG des instructions
type alias Model =
  { text_input : String
  , block : Result (List DeadEnd) (List Instruction)
  }

-- initialement mes variable text_input est vide et block affiche une err
init : Model 
init =
    { text_input = ""
    , block = Err []
    }





-- UPDATE

-- la partie update permet d'actualiser les variables  text_input et list_instruction avec l'interaction de l'utilisateur
type Msg
  = Text_input String
  | Submit


update : Msg -> Model  -> Model 
update msg model =
  case msg of
    Text_input text_input ->
      { model | text_input = text_input }

    Submit ->
      { model | block = Parser.run listInst model.text_input }



-- VIEW

-- views est le result qui sera envoyé dans le browsers 
view : Model  -> Html Msg
view model =
  div []
    [ viewInput "text" "Inserer des instructions" model.text_input Text_input
    , button [ onClick Submit ] [ Html.text "valider" ]
    , viewSVG model
--    , div [] [Html.text (Debug.toString (Parser.run listInst model.text_input))]
    ]

-- permet d'afficher l'input et prendre la valeur de l'input et le mettre dans model.text_input
viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ Html.Attributes.type_ t, placeholder p, value v, onInput toMsg ] []



-- permet d'executer toute les fonction pour transformer une instruction en message svg puis affiche le dessin svg
-- on doit d'abord regler tous les cas d'err   
viewSVG : Model -> Html msg
viewSVG model = 
  let
    instruc = 
      case model.block of
        Err [] -> []

        Err deadEnd -> []

        Ok block -> block
  in 

    svg [ Svg.Attributes.width "500", Svg.Attributes.height "500", viewBox "-250 -250 500 500"] (message_svg (List.reverse(convert_List_Coordline (List.reverse(transformer instruc [] 0)) (0.0,0.0) [] )) [])



-------------------------------------------------------------------------------------------------------------------------


-- au besoin  on peut tester la partie dessin SVG
{-viewSVG : Model -> Html msg
viewSVG model =
  let
    (message) = (message_svg (List.reverse(convert_List_Coordline (List.reverse(transformer model.list_instruction [] 0)) (0.0,0.0) [] )) [])

  in
  svg [ Svg.Attributes.width "500", Svg.Attributes.height "500", viewBox "-250 -250 500 500"] (message) -}

