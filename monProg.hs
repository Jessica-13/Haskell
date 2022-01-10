
import Prelude hiding (Left, Right)
import System.IO

--Creation de differents types pour les instructions, le programme et le crayon

--Type Instruction
data Instruction = Forward Float | Left Float | Right Float | Repeat Int Programme
  deriving (Read, Show)

--Type Crayon défini par trois float : position (x y) et un angle a 
data Crayon  = Crayon Float Float Float deriving(Show, Read)
type Programme = [Instruction]

--Position de depart du crayon 
crayonInit = Crayon 200 200 0


--Création des differentes fonctions qui traitent le programme

--Fonction qui fait avancer le crayon  
updateCrayon :: Crayon -> Float -> Float-> Crayon
updateCrayon (Crayon x y a) dist angle = Crayon (x+dist*cos(a+angle)) (y+dist*sin(a+angle)) (a+angle)

--Pattern Matching des differentes instructions 
pattmatch :: Programme -> Crayon -> Float -> [Crayon]
pattmatch [] c _ = [c] 
pattmatch (x:xs) c alg = case x of
 (Forward i) -> c:pattmatch xs (updateCrayon c i (alg*pi/180)) 0
 (Left i) -> pattmatch xs c (alg+i) 
 (Right i) -> pattmatch xs c (alg-i)
 (Repeat i j) -> c:pattmatch prog c alg 
  where prog = (concat (replicate i j))++xs
    --take (i*length j)  (cycle j)++xs



--Fonction qui convertis les mouvemeents du crayon en string respectant la syntaxe svg 
svgconv ::[Crayon] -> Crayon -> String
svgconv [] c = ""
svgconv (x:xs) c = str ++ svgconv xs x
      where  Crayon xu yu a =  c
             Crayon xv yv b =  x
             str="<line x1=\""++show(xu) ++ "\" y1=\""++show(yu)++"\" x2=\""++ show(xv)++ "\" y2=\""++show(yv)++ "\" stroke=\"blue\" />\n"


--Fonction qui écrit toute la syntaxe finale demandé 
svgfinale :: [Crayon] -> Crayon -> String
svgfinale tabc c = svgsyntaxe
    where svgsyntaxe = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"400\" height=\"400\">\n<title>Exemple</title>\n"++(svgconv tabc c)++"</svg>"        

--Main qui prend le fichier "logoskell.txt" le lit et stocke le resultat dans un fichier svg en sortie 
--Il faut donc que les instructions soient stocké dans ce fichier logoskell.txt
--Exemple de l'instruction sur le terminal : ./monPrg >prog.svg
--Generation automatique du fichier prog.svg qu'on peut ouvrir avec un navigateur 
main = do 
 fichierlogo <- openFile "logoskell.txt" ReadMode 
 stringfichier <- hGetContents fichierlogo
 hPutStr stdout(svgfinale(pattmatch(read stringfichier :: Programme) crayonInit 0) crayonInit) 
 hClose fichierlogo