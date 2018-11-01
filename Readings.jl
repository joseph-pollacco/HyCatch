module  reading
	export READS_HEADER
	# using DelimitedFiles
	
	
	function READS_HEADER(Path, Name)
		
		# Read data
		Data =  DelimitedFiles.readdlm(Path, ',')
		N_X, N_Y = size(Data) # Size of the array
		
		# Reading header
		Header = fill("", N_Y)
		for i in 1:N_Y
			Header[i] = Data[1,i]
		end

		# Getting the column which matches the name of the header
		Data_Output = Data[2:N_X,findfirst(isequal(Name), Header)]

		N_X -= 1 # To take consideration of the header
		
		return Data_Output, N_X, N_Y
	end # READS_HEADER



		module d1
			using reading
			using  Dates
			export CLIMATE
	

			# Reads the data and put in format and start from step 2
			function CLIMATE(Path)
				X = 1 #1D
				Y = 1 #1D
				
				# READING THE CLIMATE DATA		
				Year_Climate, Nt, ~ =  reading.READS_HEADER(Path, "Year") 
				Month_Climate, ~, ~ =  reading.READS_HEADER(Path, "Month")
				Day_Climate, ~, ~ =  reading.READS_HEADER(Path, "Day")
				Seconds_Climate, ~, ~ =  reading.READS_HEADER(Path, "Second")
				Pr_0, ~, ~ = reading.READS_HEADER(Path, "Pr_mm")
				PotEvap_0, ~, ~ = reading.READS_HEADER(Path, "PotEvap_mm")
				Temp_0, ~, ~ = reading.READS_HEADER(Path, "Temp_c")

				# Reserving memory
				∑Pr = zeros(Float64, Nt, X, Y)
				PotEvap = zeros(Float64, Nt, X, Y)
				Temp = zeros(Float64, Nt, X, Y)
				∑T =zeros(Float64, Nt) # Reserving space

				# Computing \Pr and putting PotEvap, Temp in the correct format
				# The first column is 0 just used for Δseconds
				for iT = 2:Nt
					#Computing elapse time 
					Δseconds = Dates.value( Dates.DateTime(Year_Climate[iT], Month_Climate[iT], Day_Climate[iT], Seconds_Climate[iT]) - DateTime(Year_Climate[iT-1], Month_Climate[iT-1], Day_Climate[iT-1], Seconds_Climate[iT-1])) / 1000

					∑T[iT] = ∑T[iT-1] + Δseconds # Cumulate time [seconds]

					∑Pr[iT, X, Y] = ∑Pr[iT-1,X,Y] + Pr_0[iT]  # Cumulate Pr

					PotEvap[iT,X,Y] = PotEvap_0[iT] # Potential evaporation
					
					Temp[iT,X,Y] = Temp_0[iT] # Temperature
				end # for
				∑T_Temp =  ∑T
				∑T_PotEvap =  ∑T
				Pr_∑T = ∑T # Cumulate time which is used for variable time step

				# Cleaning up
				Pr_0 = nothing
				PotEvap_0 = nothing
				PotEvap_0 = nothing
				∑T = nothing

				return Year_Climate, Month_Climate, Day_Climate, Seconds_Climate, ∑Pr, PotEvap, Temp, ∑T_Temp, ∑T_PotEvap, Pr_∑T
			end # CLIMATE

		end # module d1



		module d3 # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			using reading
			export DATES

			function DATES(Path)
				Year, Nt, ~ =  reading.READS_HEADER(Path, "Year")
				Month, ~, ~ =  reading.READS_HEADER(Path, "Month")
				Day, ~, ~ =  reading.READS_HEADER(Path, "Day")
				Second, ~, ~ =  reading.READS_HEADER(Path, "Second")
			
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

		end # module d3

end # module read
