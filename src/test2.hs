import BBN

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

