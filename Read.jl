module read
   export CLIMATE_1D, READ_HEADER, DATES_3D

	# using JuliaDB
	
	using DelimitedFiles, Dates


   # Read csv file amd 
   function READ_HEADER(Path, Name)
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
	end
	


	function DATES_3D(Path)
		Year, Nt, ~ =  READ_HEADER(Path, "Year")
		Month, ~, ~ =  READ_HEADER(Path, "Month")
		Day, ~, ~ =  READ_HEADER(Path, "Day")
		Second, ~, ~ =  READ_HEADER(Path, "Second")
	
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
	end # Dates 3D



   # Reads the data and put in format and start from step 2
    function CLIMATE_1D(Path)
        X = Y = 1 #1D
        
        # READING THE CLIMATE DATA
		#   Data = JuliaDB.loadtable(Path)
		
			Year_Climate, Nt, ~ =  READ_HEADER(Path, "Year") 
			Month_Climate, ~, ~ =  READ_HEADER(Path, "Month")
			Day_Climate, ~, ~ =  READ_HEADER(Path, "Day")
			Seconds_Climate, ~, ~ =  READ_HEADER(Path, "Second")
			Pr_0, ~, ~ = READ_HEADER(Path, "Pr_mm")
			PotEvap_0, ~, ~ = READ_HEADER(Path, "PotEvap_mm")
			Temp_0, ~, ~ = READ_HEADER(Path, "Temp_c")

      #   Year_Climate =  JuliaDB.select(Data, :Year)
      #   Month_Climate =  JuliaDB.select(Data, :Month)
      #   Day_Climate =  JuliaDB.select(Data, :Day)
      #   Seconds_Climate =  JuliaDB.select(Data, :Seconds)
      #   Pr_0 = JuliaDB.select(Data, :Pr_mm)
      #   PotEvap_0 = JuliaDB.select(Data, :PotEvap_mm)
      #   Temp_0 = JuliaDB.select(Data, :Temp_c)

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
        end


        ∑T_Temp =  ∑T
        ∑T_PotEvap =  ∑T
        Pr_∑T = ∑T # Cumulate time which is used for variable time step

        # Cleaning up
        Pr_0 = PotEvap_0 = PotEvap_0 = ∑T = nothing
       

       return Year_Climate, Month_Climate, Day_Climate, Seconds_Climate, ∑Pr, PotEvap, Temp, ∑T_Temp, ∑T_PotEvap, Pr_∑T
   end # CLIMATE_1D(Path)



   function READING_TIME(Path)

      # READING THE CLIMATE DATA
      Data = JuliaDB.loadtable(Path)

      Year_Climate =  JuliaDB.select(Data, :Year)
      Month_Climate =  JuliaDB.select(Data, :Month)
      Day_Climate =  JuliaDB.select(Data, :Day)
      Seconds_Climate =  JuliaDB.select(Data, :Seconds)

      Nt = length(Year_Climate) # Number of data

      ∑T =zeros(Float64, Nt) # Reserving space

      # The first column is 0 just used for Δseconds
      for iT in 2:Nt
         #Computing elapse time 
         Δseconds = convert(Float64, Dates.DateTime(Year_Climate[iT], Month_Climate[iT], Day_Climate[iT], Seconds_Climate[iT]) - DateTime(Year_Climate[iT-1], Month_Climate[iT-1],  Day_Climate[iT-1], Seconds_Climate[iT-1])) / 1000.

         ∑T[iT] = ∑T[iT-1] + Δseconds # Cumulate time [seconds]
      end

   return ∑T

   end

end # reading