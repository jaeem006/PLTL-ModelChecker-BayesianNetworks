module BayesianNetwork where

type Prob = Float
data Pvar = Pos String | Neg String deriving(Eq, Show)
-- type Pvar = String
type Pvalue = (Pvar, Prob)

data Node = Node {
 label :: Pvalue,
 parents :: [Node],
 next :: [Node]
}

type BayesianNetwork =  [Node]

dependant :: Node -> [Node]
dependant = parents 


chain :: [Node] -> [Pvalue] -> Prob
chain [] _ = 1
-- chain [n] cond = case label n of 
--     x@(Pos p, _) -> if x `elem` cond then 1 else 0
--     x@(Neg p, pr) -> if x `elem` cond then 0 else 1 - pr
chain (x:xs) cond = (proba x cond) * (chain xs (label x:cond))
 -- where cond0 = [z | z <- cond, z `notElem` (map label (next x))]

proba :: Node -> [Pvalue] -> Prob
proba n cond 
    | l `elem` cond = case v of 
        Pos r -> 1
        Neg r -> 1 - p 
    | null inter = if null par then snd (label n) else sumProb par cond 
    | otherwise = (proba n cond0) * (chain suc (l:cond0)) / (chain suc cond0)
    where 
        suc = next n
        l@(v,p) = label n
        inter = [z | z <- cond, z `elem` (map label (next n))]
        cond0 = [z | z <- cond, z `notElem` (map label (next n))]
        par = parents n

sumProb :: [Node] -> [Pvalue] -> Prob
sumProb [] _ = 0
sumProb (x:xs) cond = p * pc1 + prest
 where 
    (_,p) = label x
    pc1 = proba x cond
    prest = sumProb xs cond

bul :: Node 
bul = Node {label=((Pos "burglary"), 0.001),parents=[],next=[sen]}

lig :: Node 
lig = Node {label=((Pos "lightning"), 0.02),parents=[],next=[sen]}

sen :: Node 
sen = Node {label=((Pos "sensor"), 0.9),parents=[bul],next=[ala,call]}

ala :: Node 
ala = Node {label=((Pos "alarm"), 0.95),parents=[sen],next=[]}

call :: Node 
call = Node {label=((Pos "call"), 0.9),parents=[sen],next=[]}

b :: BayesianNetwork
b = [bul,lig,sen,ala,call]