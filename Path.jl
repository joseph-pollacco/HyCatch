push!(LOAD_PATH, pwd())


module path

	include(pwd() * "\\Option.jl")

	# using option
	Home = "C:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch_Model\\"
	Home_Input = Home * "Input\\"  * option.Dimension 

   # LOOK UP TABLES
   LookUpTable_Veg =   Home *  "\\Input\\LookUpTable\\LookUpTable_Veg.csv"

   # 2D FIXED DATA

   # 1D TIME SERIES DATA
   Climate =  Home_Input * "\\Climate\\Climate.csv"

	# 2D TIME SERIES DATA
	Pr_2D = Home * "\\Input\\Climate\\1D\\Climate\\Climate.csv"

end # path