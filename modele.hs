import Prelude hiding (Left, Right)

--Structures de données
data Crayon = Crayon {point::(Float, Float), angle::Float} --format : Crayon(coordonnée x, coordonnée y) angle par rapport à l'horizontale 
data Instruction = Forward Float | Left Float | Right Float | Repeat Float [Instruction] deriving (Show, Read)
type Programme = [Instruction]

-------------------------------------------------------------------------------------------------------------------------------------------

decomposition_instruction :: [Instruction] -> [Instruction]
decomposition_instruction i = case i of
   [] -> i
   (x:[]) -> case x of
       (Forward l) -> (Forward l):[]
       (Left a) -> (Left a_radian):[]
           where a_radian = a*pi/180
       (Right a) -> (Right a_radian):[]
           where a_radian = a*pi/180
       (Repeat n instruction_repeat) -> case n of
           1 -> decomposition_instruction instruction_repeat
           _ -> (decomposition_instruction instruction_repeat) ++ decomposition_instruction ((Repeat (n-1) instruction_repeat):[])--on trasnforme un repeat instruction en [instruction] ++ ... ++ [instruction]
   (x:xs) -> (decomposition_instruction (x:[]))++decomposition_instruction(xs)--on concatène les différentes instructions en une liste contenant que des instructions left, right et forward, récursivement


-------------------------------------------------------------------------------------------------------------------------------------------

logoskell2svg :: Programme -> Crayon -> String -> (Crayon, String)
logoskell2svg programme crayon string = case programme of
   [] -> (crayon, string)
   (x:[]) -> case x of
       (Forward l) -> (crayon2, string ++ (convertCrayonsToSvg crayon crayon2))
           where x1 = fst (point crayon)
                 y1 = snd (point crayon)
                 a = angle crayon
                 x2 = x1 + (l * (cos a))--trigonométrie
                 y2 = y1 + (l * (sin a))--trigonométrie
                 crayon2 = Crayon (x2,y2) a --actualisation du crayon qui se trouve aux nouvelles coordonnées après avoir avancé de l
       Left a -> (crayon2, string)
           where crayon2 = Crayon (point crayon) ((angle crayon) + a) --sens trigonométrique, angle compté positivement à gauche par rapport à l'horizontale
                                                                      --actualisation de l'angle du crayon
       Right a -> (crayon2, string)                                       
           where crayon2 = Crayon (point crayon) ((angle crayon) - a) --sens trigonométrique, angle compté négativement à droite par rapport à l'horizontale
                                                                      --actualisation de l'angle du crayon
   (x:xs) -> logoskell2svg xs crayon2 string2                         --action récursive 
       where crayon2 = fst (logoskell2svg (x:[]) crayon string)
             string2 = snd (logoskell2svg (x:[]) crayon string)

-------------------------------------------------------------------------------------------------------------------------------------------

convertCrayonsToSvg :: Crayon -> Crayon -> String
convertCrayonsToSvg crayon1 crayon2 = "<line x1=\"" ++ x1 ++ "\" y1=\"" ++ y1 ++ "\" x2=\"" ++ x2 ++ "\" y2=\"" ++ y2 ++ "\" stroke=\"red\" />" ++ "\n"--format du texte SVG, x2 et y2 sont les coordonnées du 
                                                                                                                                                       -- crayon après exécution d'une instruction
   where x1 = show(fst (point crayon1))
         y1 = show(snd (point crayon1))
         x2 = show(fst (point crayon2))
         y2 = show(snd (point crayon2))

-------------------------------------------------------------------------------------------------------------------------------------------

main = do
   putStrLn "Entrez une instruction logskell : "
   line <- getLine
   let programme1 = (read line :: Programme)
   let programme2 = decomposition_instruction programme1
   let crayon = Crayon (100,100) 0 --initialisation du crayon 
   putStrLn ("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"200\" height=\"200\">\n<title>Exemple</title>\n" ++ (snd (logoskell2svg programme2 crayon [])) ++ "</svg>")
