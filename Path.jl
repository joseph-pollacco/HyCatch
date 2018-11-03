push!(LOAD_PATH, pwd())

module path
include(pwd() * "\\Option.jl")

	Home = "C:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch\\"		
	# Using option to determine if 1D or 3D
	Home_Input = Home * "Input\\"  * option.Dimension 


	
	module fixed
	include(pwd() * "\\Option.jl")	
		Home = "C:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch\\"		
		# Using option to determine if 1D or 3D
		Home_Input = Home * "Input\\"  * option.Dimension 
		
		Catchement = Home_Input * "\\Catchment\\"  
	end #fixed


	# LOOK UP TABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	module lookuptable
	include(pwd() * "\\Option.jl")
		Home = "C:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch\\"		
		# Using option to determine if 1D or 3D
		Home_Input = Home * "Input\\"  * option.Dimension 

		Vegtable =  Home_Input *  "\\Input\\LookUpTable\\LookUpTable_Veg.csv"
	end # Loouptable



	# 1D TIME SERIES DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	module d1
	include(pwd() * "\\Option.jl")
		Home = "C:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch\\"		
		# Using option to determine if 1D or 3D
		Home_Input = Home * "Input\\"  * option.Dimension 

		Climate =  Home_Input * "\\Climate\\Climate.csv"
	end # d1



	# 3D TIME SERIES DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	module d3
	include(pwd() * "\\Option.jl")
		Home = "C:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch\\"		
		# Using option to determine if 1D or 3D
		Home_Input = Home * "Input\\"  * option.Dimension 

		Pr = Home_Input * "\\Climate\\Pr\\"

		Etp = Home_Input * "\\Climate\\Etp\\"

		Temperature = Home_Input * "\\Climate\\Temperature\\"
	end # d3



end # path