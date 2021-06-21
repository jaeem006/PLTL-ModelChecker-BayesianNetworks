import BBN 

burglary :: Node
burglary = Node{
    label="burglary",
    parents=[],
    proba=[([], 0.001)]
}

earthquake :: Node
earthquake = Node{
    label="earthquake",
    parents=[],
    proba=[([], 0.002)]
}

alarm :: Node
alarm = Node{
    label="alarm",
    parents=["burglary", "earthquake"],
    proba=[([Pos "burglary", Pos "earthquake"], 0.95),
            ([Pos "burglary", Neg "earthquake"], 0.94),
            ([Neg "burglary", Pos "earthquake"], 0.29),
            ([Neg "burglary", Neg "earthquake"], 0.001)]
}

john :: Node
john = Node{
    label="john",
    parents=["alarm"],
    proba=[([Pos "alarm"], 0.9),
            ([Neg "alarm"], 0.05)]
}

mary :: Node
mary = Node{
    label="mary",
    parents=["alarm"],
    proba=[([Pos "alarm"], 0.7),
            ([Neg "alarm"], 0.01)]
}

trans1 :: Var -> [Node]
trans1 "burglary" = [alarm]
trans1 "earthquake" = [alarm]
trans1 "alarm" = [john, mary]
trans1 "john" = []
trans1 "mary" = []

bn :: BayesianNetwork 
bn = BayesianNetwork{
    trans=trans1,
    nodes=[burglary,earthquake,alarm,john,mary]
}

prob bn (Right [Pos "john", Pos "mary", Pos "alarm", Pos "burglary", Neg "earthquake"]) []

-- Resultado esperado : 0.000591
