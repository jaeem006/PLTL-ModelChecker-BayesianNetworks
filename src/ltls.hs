import Data.List

type State = Int
type Atom = Char

data Form = Var Atom
          | Neg Atom
          | Conj Form Form
          | Disy Form Form
          | X Form 
          | F Form 
          | G Form
          | U Form Form
          | R Form Form
         deriving(Show,Eq,Ord)

top :: Form
top = Disy (Var 'p') (Neg 'p')

bot :: Form
bot = Conj (Var 'p') (Neg 'p')

data Model = Model {
  next :: State -> [State],
  atom :: State -> Atom -> Bool
 }

type Assertion = (State,[Form])

nnf :: Form -> Form
nnf (Var a) = Neg a
nnf (Neg a) = Var a
nnf (Conj p q) = Disy (nnf p) (nnf q)
nnf (Disy p q) = Conj (nnf p) (nnf q)
nnf (X p) = X (nnf p)
nnf (F p) = G (nnf p)
nnf (G p) = F (nnf p)
nnf (U p q) = R (nnf p) (nnf q)
nnf (R p q) = U (nnf p) (nnf q)

suc :: [Assertion] -> Bool
suc as = let ps = (nub . concat) [p | (_,p) <- as] in
    (not . null) [R s q | R s q <- ps, q `notElem` ps]

data Goals = T | Goal [Assertion]

foo :: Form -> Form
foo (X x) = x
foo x = x

goals :: Model -> Assertion -> Goals
goals _ (s,[]) = Goal []
goals m (s,Var x:fs) = if atom m s x then T else Goal [(s,fs)]
goals m (s,Neg x:fs) = if not (atom m s x) then T else goals m (s,fs)
goals m (s,Disy p q:fs) = Goal [(s,p:q:fs)]
goals m (s,Conj p q:fs) =  Goal $ (nub.sort) [(s,p:fs),(s,q:fs)]
goals m (s,X p:fs) = let ps = map foo (p:fs) in Goal [(s',ps) | s' <- next m s ]
goals m (s,F p:fs) = goals m (s,U top p:fs)
goals m (s,G p:fs) = goals m (s,R bot p:fs)
goals m (s,U p q:fs) = if p == q then Goal [(s,p:fs)] else Goal [(s,p:q:fs),(s,q:X (U p q):fs)]
goals m (s,R p q:fs) = if p == q then Goal [(s,p:fs)] else Goal [(s,q:fs),(s,p:X (U p q):fs)]

dfs :: Model -> Assertion -> [Assertion] -> Bool
dfs m a l = if a `elem` l 
            then suc (a: takeWhile (a /=) l)
            else case goals m a of 
                T -> True
                Goal as -> case as of 
                    [] -> False
                    _ -> and [dfs m a' (a:l) | a' <- as]

mcALTL :: Model -> Assertion -> Bool
mcALTL m as = dfs m as []

-- EJEMPLO

n1 :: State -> [State]
n1 0 = [1,2]
n1 1 = [0,2]
n1 2 = [2]

a1 :: State -> Atom -> Bool
a1 0 'p' = True
a1 0 'q' = True
a1 1 'q' = True
a1 1 'r' = True
a1 2 'r' = True
a1 _ _ = False

m1 :: Model
m1 = Model {next=n1, atom=a1}
