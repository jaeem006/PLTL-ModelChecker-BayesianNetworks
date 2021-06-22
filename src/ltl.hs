import Data.List
import BBN

data State = State { lb::Int, bayes::BayesianNetwork }
instance Show State where
    show = show.lb 
instance Ord State where
    compare x y = compare (lb x) (lb y)
instance Eq State where
    x == y = (lb x) == (lb y)

-- type Atomic = Char

data Pexp = A Atom | C Atom Atom | M [Atom] [Atom]deriving(Show,Eq)
instance Ord Pexp where
    compare (A x) (A y) = compare x y
    compare (A _) _ = LT 
    compare _ (A _) = GT 
    compare (C x y) (C w z) = compare x w
    compare (C _ _) _ = LT 
    compare _ (C _ _) = GT 
    compare (M xs ys) (M ws zs) = compare xs ws

data Form = 
          --   Var Atomic
          -- | Neg Atomic
            P Proba Pexp -- Que la proba sea mayor o igual a
          | Conj Form Form
          | Disy Form Form
          | X Form 
          | F Form 
          | G Form
          | U Form Form
          | R Form Form 
         deriving(Show,Eq,Ord)

top :: Form
top = P 0 $ A (Pos "")

bot :: Form
bot = P 1.1 $ A (Pos "")

data Model = Model {
  next :: State -> [State]
  -- atomic :: State -> Atomic -> Bool
 }

type Assertion = (State,[Form])

nnf :: Form -> Form
-- nnf (Var a) = Neg a
-- nnf (Neg a) = Var a
nnf (Conj p q) = Disy (nnf p) (nnf q)
nnf (Disy p q) = Conj (nnf p) (nnf q)
nnf (X p) = X (nnf p)
nnf (F p) = G (nnf p)
nnf (G p) = F (nnf p)
nnf (U p q) = R (nnf p) (nnf q)
nnf (R p q) = U (nnf p) (nnf q)
nnf x = x

suc :: [Assertion] -> Bool
suc as = let ps = (nub . concat) [p | (_,p) <- as] in
    (not . null) [R s q | R s q <- ps, q `notElem` ps]

data Goals = T | Goal [Assertion]

foo :: Form -> Form
foo (X x) = x
foo x = x

goals :: Model -> Assertion -> Goals
goals _ (s,[]) = Goal []
goals m (s,P pr (A e):fs) = if prob (bayes s) (Left e) [] >= pr then T else Goal [(s,fs)]
goals m (s,P pr (C e c):fs) = if prob (bayes s) (Left e) [c] >= pr then T else Goal [(s,fs)]
goals m (s,P pr (M e c):fs) = if prob (bayes s) (Right e) c >= pr then T else Goal [(s,fs)]
-- goals m (s,Var x:fs) = if atomic m s x then T else Goal [(s,fs)]
-- goals m (s,Neg x:fs) = if not (atomic m s x) then T else goals m (s,fs)
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

