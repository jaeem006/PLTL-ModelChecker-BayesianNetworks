import BBN
import Ltl

-- Definición de la Red Bayesiana 

homicida :: Node
homicida = Node {
    label="homicida",
    parents=[],
    proba=[([],0.01)]
}

sangre :: Node
sangre = Node {
    label="sangre",
    parents=["homicida"],
    proba=[([Pos "homicida"], 0.8),
            ([Neg "homicida"], 0.1)]
}

cuchillo :: Node
cuchillo = Node {
    label="cuchillo",
    parents=["homicida"],
    proba=[([Pos "homicida"], 0.85),
            ([Neg "homicida"], 0.25)]
}

trans2 :: Var -> [Node]
trans2 "homicida" = [sangre, cuchillo]
trans2 "sangre" = []
trans2 "cuchillo" = []

bn1 :: BayesianNetwork 
bn1 = BayesianNetwork {
    trans=trans2,
    nodes=[homicida,sangre,cuchillo]
}

-- Definición del modelo de Kripke 

s1::State
s1 = State{lb=0,bayes=bn1}

s2::State
s2 = State{lb=1,bayes=bn1}

t::Int -> [State]
t 1 = [s2]
t 2 = []

m1::Model
m1 = Model{
    next=t
}

-- mcALTL m1 (s1,[P 0 (A (Pos "homicida"))]) valor esperado: 0.01
-- mcALTL m1 (s1, [(P 0 (M [(Pos "cuchillo"),(Neg "sangre"),(Neg "homicida")] []))]) valor esperado: 0.2275