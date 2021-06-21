import Data.List

type Var = String
type Prob = Float

data Event = Pos Var | Neg Var | List [Event] deriving(Show,Eq)

data BayesianNetwork = BayesianNetwork {
    trans :: Var -> [Var],
    prob :: Var -> Prob,
    nodes :: [Var]
}

parents :: BayesianNetwork -> Var -> [Var]
parents b v = [x | x <- nodes b, v `elem` trans b x]

trans1 :: Var -> [Var]
trans1 "burglary" = ["sensor"]
trans1 "lightning" = ["sensor"]
trans1 "sensor" = ["alarm","call"]
trans1 "alarm" = []
trans1 "call" = []

-- trans1 :: Var -> [Var]
-- trans1 "sensor" = ["burglary","lightning"]
-- trans1 "alarm" = ["sensor"]
-- trans1 "call" = ["sensor"]
-- trans1 "lightning" = []
-- trans1 "burglary" = []

prob1 :: Var -> Prob
prob1 "burglary" = 0.001
prob1 "lightning" = 0.02
prob1 "sensor" = 0.9
prob1 "alarm" = 0.95
prob1 "call" = 0.9

b1 :: BayesianNetwork 
b1 = BayesianNetwork{
    trans=trans1,
    prob=prob1,
    nodes=["burglary","lightning","sensor","alarm","call"]
}

event2var :: Event -> Var 
event2var (Pos x) = x
event2var (Neg x) = x

var2event :: Var -> Event
var2event x = Pos x

descendents :: BayesianNetwork -> [Var] -> Var  -> [Var]
descendents bn xs x = case trans bn x of 
    [] ->  xs
    ys ->  nub $ xs ++ concatMap (descendents bn ys) ys

proba :: BayesianNetwork -> Event -> [Event] -> Prob
proba _ (List []) _ = 1
proba bn (List (x:xs)) cond = (proba bn x cond) * (proba bn (List xs) (x:cond))
proba bn (Neg x) cond = 1 - proba bn (Pos x) cond
proba bn p@(Pos x) cond 
 | p `elem` cond = 1
 | (Neg x) `elem` cond = 0
 -- | not (null inter) = 10
 -- | not (null inter) = px * pyGivenX / py
 | py == 0 = 1000
 | not (null inter) = px *  pyGivenX / py
 | null inter && null par  = prob bn x 
 -- | null inter = 1.5 
 | otherwise = sumProb bn par0 cond 
 where par = parents bn x 
       -- par0 = map var2event par
       par0 = findAll bn x
       des = descendents bn [] x --A lo mejor solo es el primero
       des0 = map var2event des --A lo mejor solo es el primero
       condi = map event2var cond
       inter = [z | z <- condi, z `elem` des]
       cond0 = filter (\c -> (event2var c) `notElem` des) cond
       -- cond0 = [c | c <- condi, c `notElem` des] 
       pare = List par0
       -- px = proba bn p cond0 
       des1 = List des0
       px = proba bn p cond0 
       pyGivenX = proba bn des1 (p:cond0)
       py = proba bn des1 cond0


findAll :: BayesianNetwork -> Var -> [Event]
findAll bn x = nub $ concat [ [(Neg y), (Pos y)] | y <- parents bn x]


sumProb:: BayesianNetwork -> [Event] -> [Event] -> Prob
sumProb _ [] _ = 0 
sumProb bn (x:xs) cond = p1 * pc1 / prest
 where pc1 = proba bn x cond
       prest = sumProb bn xs cond
       p1 = prob bn $ event2var x
