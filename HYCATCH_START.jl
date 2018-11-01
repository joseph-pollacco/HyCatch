#= HyCatch model =#
cd("c:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch")
push!(LOAD_PATH, pwd())

include("Option.jl")
include("Path.jl")
include("Modules.jl")
include("Readings.jl")
include("Clock.jl")
include("Interpolate.jl")
include("Snow.jl")
include("Interception.jl")

using RawArray

function HYCATCH()
    ΔT = 60 .* 60 .* 24. * 1. # Daily time step

    #= =============== READING DATA ============== =#

	if option.Dimension == "1D"
		# Reading time series of climate data
		Year_Climate, Month_Climate, Day_Climate, Seconds_Climate, ∑Pr_Data, PotEvap_Data, Temp_Data, ∑T_Temp, ∑T_PotEvap, Pr_∑T = readings.d1.CLIMATE(path.Climate)
		
		# We are in 1D
		X = 1 
		Y = 1
		N_X = 1
		N_Y = 1

		#= =============== INITIAL CONDITIONS =============== =#
		∑T = 0.
		∑Pr = 0. 
		StorageVeg = 0. 
		∑snow = 0.
		PrMelt = 0. # Starting time from 0
		∑T_Max = Pr_∑T[length(Pr_∑T[:])] # Maximum time of simulation
		iPr = 1
		iPotEvap = 1
		iTemp = 1  # We start from iPr =2	
	
	elseif option.Dimension == "3D"
		# Reading dates of time series data
		Catchment_X_True = RawArray.raread(path.Home_Input * "\\Catchment\\Catchment_X_True.ra")
		Catchment_Y_True = RawArray.raread( path.Home_Input * "\\Catchment\\Catchment_Y_True.ra")
		Catchment_Information = RawArray.raread( path.Home_Input * "\\Catchment\\Catchment_Information.ra")
		N_X, N_Y, N_Xy_True = Catchment_Information[:]

		Pr_Date, Pr_∑T = readings.d3.DATES(path.Home_Input * "\\Climate\\Pr\\ClimateDates.csv")

		∑T_Max = Pr_∑T[length(Pr_∑T[:])] # Maximum time of simulation which is based on precipitation data
	end

	Flag_Break = false
    while !Flag_Break # his controles the time loop
        for iX = 1:N_X, iY = 1:N_Y
        
				#= =============== MANAGING TIME STEP =============== =#
				# ∑T = cumulative time; ΔT_Adjust for last time step
				∑T, ΔT_Adjust, Flag_Break = clock.CLOCK(∑T_Max, ∑T, ΔT)
				
				# Getting data
				if option.Dimension == "3D"
					println("")
					interpolate.d1.∑PR_2_PR_3D(Pr_∑T, Pr_Date, )
				else
					# Compute Pr [mm/ΔT]
					∑Pr, Pr, iPr = interpolate.d1.∑PR_2_PR(∑T, ∑Pr, iPr, ∑Pr_Data[:], Pr_∑T[:])
				end

            # Compute PotEvap for the current ΔT
            PotEvap, iPotEvap = interpolate.d1.OBSstairs(∑T, iPotEvap, PotEvap_Data[:], ∑T_PotEvap[:])

            # Compute Temperature for the current Δ
				Temp, iTemp = interpolate.d1.OBSstairs(∑T, iTemp, Temp_Data[:], ∑T_Temp[:])

            #= =============== SNOW =============== =#
            if modules.Snow == "run"
                Pr, PrMelt, ∑snow = snow.SNOW(Pr, Temp,  ∑snow, ΔT_Adjust )
            end

    
            #= =============== RAINFALL_INTERCEPTION =============== =#
            if modules.Interception == "run"
                IdLcdb = 30
                interceptedPerc = 0.2
                Lai = 4

                # Deriving storageVegMaxLai from LookUpTable_Veg and from IdLcdb
					#  storageVegMaxLai = JuliaDB.select(filter(i -> (i.ID_LCDB == IdLcdb), LookUpTable_Veg), :storageVegMaxLai)[1]
					 storageVegMaxLai = 0.5

					 Pr, PotEvap, StorageVeg = interception.rutter_joe.RAINFALL_INTERCEPTION(Pr, PotEvap, Lai, storageVegMaxLai, StorageVeg)
					
            end #  modules.Interception

            
            if modules.Snow == "run"
                # Melted snow (if used) is not intercepted by the canopy
                Pr += PrMelt
            end


            # This is to determine when the loop stops
            if Flag_Break
                break
            end 

        end # while

	 end # X, Y

	 println(∑Pr)
	 
	 return
   
end # HYCATCH

HYCATCH()