module reading

	module d1 # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	include("ToolBox.jl")
	using Dates, DelimitedFiles
	export CLIMATE

		function CLIMATE(Path, LookUp, Interpolation)
			X = 1 #1D
			Y = 1 #1D
			
			# READING THE CLIMATE DATA		
			Year, Nt, ~ =  toolbox.read.READ_HEADER(Path, "Year") 
			Month, ~, ~ =  toolbox.read.READ_HEADER(Path, "Month")
			Day, ~, ~ =  toolbox.read.READ_HEADER(Path, "Day")
			Seconds, ~, ~ = toolbox.read.READ_HEADER(Path, "Second")
			χ_0, ~, ~ = toolbox.read.READ_HEADER(Path, LookUp) # Variables what to read

			# Reserving memory
			∑T =zeros(Float64, Nt) # Reserving cumulative time
			
			if Interpolation == "∑"
				∑χ = zeros(Float64, Nt, X, Y) # Cumulative X such as Pr

			elseif Interpolation == "daily"
				χ = zeros(Float64, Nt, X, Y) # Eg. temperature of PET
			end

			# Computing ∑X or X in the correct format
			# The first column is 0 just used for Δseconds
			for iT = 2:Nt
				#Computing elapse time between the 2 observations
				Δseconds = Dates.value( Dates.DateTime(Year[iT], Month[iT], Day[iT], Seconds[iT]) - DateTime(Year[iT-1], Month[iT-1], Day[iT-1], Seconds[iT-1])) / 1000

				∑T[iT] = ∑T[iT-1] + Δseconds # Cumulate time [seconds]

				if Interpolation == "∑"
					∑χ[iT,X,Y] = ∑χ[iT-1,X,Y] + χ_0[iT]  # Cumulate X

				elseif Interpolation == "daily"
					χ[iT,X,Y] = χ_0[iT] #  Eg. temperature of PET
				end
			end # for

			if Interpolation == "∑"
				return Year, Month, Day, Seconds, ∑χ, ∑T
			elseif Interpolation == "daily"
				return Year, Month, Day, Seconds, χ, ∑T
			end

		end # CLIMATE

	end # module d1 # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



	module d3 # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	include("ToolBox.jl")

	export DATES

		function DATES(Path)
			Year, Nt, ~ =  toolbox.read.READ_HEADER(Path, "Year")
			Month, ~, ~ =  toolbox.read.READ_HEADER(Path, "Month")
			Day, ~, ~ =  toolbox.read.READ_HEADER(Path, "Day")
			Second, ~, ~ =  toolbox.read.READ_HEADER(Path, "Second")
		
			∑T = zeros(Float64, Nt) # Reserving space
			Date_X = zeros(Float64, Nt, 4)

			# The first column is 0 just used for Δseconds
			for iT = 2:Nt
				#Computing elapse time 
				Δseconds =  Dates.value((Dates.DateTime(Year[iT], Month[iT], Day[iT], Second[iT]) - Dates.DateTime(Year[iT-1], Month[iT-1], Day[iT-1], Second[iT-1])) / 1000.)

				∑T[iT] = ∑T[iT-1] + Δseconds # Cumulate time [seconds]
		
				Date_X[iT,1] = Year[iT]
				Date_X[iT,2] = Month[iT]
				Date_X[iT,3] = Day[iT]
				Date_X[iT,4] = Second[iT]
			end		

			return Date_X, ∑T
		end # Dates


	end # module d3 # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



end # module read
