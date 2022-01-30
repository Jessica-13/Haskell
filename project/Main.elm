  --Html.text (Debug.toString (String.toList stringInstruction))


-- CONVERSION
--getIndexedCharacters : String -> List (Instruction)
--getIndexedCharacters =
  --indexedMap (",") << toList




module Main exposing (..)
import Html exposing (text)
import Html
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Debug
import Browser
import Html exposing (Html, Attribute, div, input, text, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput,onClick)

-- PARSER : elm install elm/parser
import Parser exposing (Parser, (|.), (|=), succeed, symbol, float, spaces, getOffset)
import List exposing (indexedMap)
import String exposing (toList)


-- mon type instruction qui a comme arg (forward left right et repeat)
type  Instruction = Forward Float | Left Float | Right Float | Repeat Int (List Instruction)

--la varaible de type instruction que je met en entré dans le programme
my_instruction = [Repeat 8 [Left 45, Repeat 6 [Repeat 90 [Forward 1, Left 2], Left 90]]]

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

{-
--j'affiche dans le main le dessin svg
main = 
  svg
    [ width "500"
    , height "500"
    , viewBox "-250 -250 500 500"
    ] 
  (message_svg (List.reverse(convert_List_Coordline (List.reverse(transformer my_instruction [] 0)) (0.0,0.0) [] )) []) 
-}    


  --Html.text (Debug.toString (List.reverse(convert_List_Coordline (List.reverse(transformer my_instruction [] 0)) (0.0,0.0) [] )))
  --Html.text (Debug.toString (List.reverse(transformer my_instruction [] 0)))




{- This is an input module, which emits messages, when user types anything,
   focuses on it, or when focus leaves the field.
-}





-- MAIN


main =

  Browser.sandbox { init = init, update = update, view = view }
-- MODEL

type alias Model =
  { text_input : String
  , list_instruction : List(Instruction)
  }


init : Model 
init =
  Model "" []





-- UPDATE



type Msg
  = Text_input String
  | Submit


update : Msg -> Model  -> Model 
update msg model =
  case msg of
    Text_input text_input ->
      { model | text_input = text_input }

    Submit ->
      { model | list_instruction = my_instruction }



-- VIEW


view : Model  -> Html Msg
view model =
  div []
    [ viewInput "text" "Inserer des instructions" model.text_input Text_input
    , button [ onClick Submit ] [ Html.text "valider" ]
    , viewSVG model
    --, svg [Html.Attributes.width 300, Html.Attributes.height 300, viewBox "-200 -200 300 300"] (pixels model)
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ Html.Attributes.type_ t, placeholder p, value v, onInput toMsg ] []

        



viewSVG : Model -> Html msg
viewSVG model =
  let
    (message) = (message_svg (List.reverse(convert_List_Coordline (List.reverse(transformer model.list_instruction [] 0)) (0.0,0.0) [] )) [])

  in
  svg [ Svg.Attributes.width "500", Svg.Attributes.height "500", viewBox "-250 -250 500 500"] (message) 



pixels model = message_svg (List.reverse(convert_List_Coordline (List.reverse(transformer my_instruction [] 0)) (0.0,0.0) [] )) []