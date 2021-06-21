module BBN where 

import Data.List

type Proba = Float
type Var = String

data Atom = Neg Var | Pos Var deriving(Show, Eq)
type Event = Either Atom [Atom] 
type Cond = [Atom]

data Node = Node {
    label :: Var,
    parents :: [Var],
    proba :: [([Atom],Proba)]
} deriving(Show,Eq)

data BayesianNetwork = BayesianNetwork {
    trans :: Var -> [Node],
    nodes :: [Node]
}

-- Tan solo esta función es cuadratica,así que necesitamos una heuristica
equal :: (Eq a) => [a] -> [a] -> Bool
equal xs ys = null $ filter (\x -> x `notElem` ys) xs  

atom2var :: Atom -> Var
atom2var (Pos x) = x 
atom2var (Neg x) = x 

atoms2vars :: [Atom] -> [Var]
atoms2vars = map atom2var

inter :: (Eq a) => [a] -> [a] -> [a]
inter xs ys = [z | z <- xs, z `elem` ys]

-- función que genera las condiciones para buscar en la tabla 
genCond :: Cond -> [Var] -> [Atom]
genCond as vs = nub (int0 ++ dat) -- Aplico nub aunque por construcción no deberia haber repetidos
 where vas = atoms2vars as
       int = inter vs vas
       dif = vs \\ vas 
       dat = map Neg dif 
       int0 = getAtom as int

getAtom :: Cond -> [Var] -> Cond
getAtom cs vs = [c | c <- cs, (atom2var c) `elem` vs]

getByFst :: (Eq a) => [([a],b)] -> [a] -> b -> b
getByFst [] e v = v
getByFst ((x,p):xs) e v 
 | equal e x = p
 | otherwise = getByFst xs e v

srchP :: Node -> Cond -> Proba
srchP n c = getByFst (proba n) c 0

srchNode :: [Node] -> Var -> Node
srchNode (n:ns) v
 | label n == v = n
 | otherwise = srchNode ns v 

getNode :: BayesianNetwork -> Var -> Node
getNode bn v = srchNode ns v
 where ns = nodes bn

chain :: BayesianNetwork -> [Atom] -> Proba
chain _ [] = 1
chain bn (x:xs) = (prob bn (Left x) xs) * (chain bn xs)

prob :: BayesianNetwork -> Event -> Cond -> Proba
prob bn (Left (Neg p)) cond = 1 - prob bn (Left (Pos p)) cond
prob bn (Left (Pos p)) cond = let n = getNode bn p in srchP n (genCond cond (parents n))
prob bn (Right ps) cond
 | null cond = chain bn ps 
 | otherwise = chain bn (ps++cond) / chain bn cond 
