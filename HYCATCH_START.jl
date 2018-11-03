#= HyCatch model =#
cd("c:\\JOE\\Main\\MODELS\\HYDRO\\Distributed\\HyCatch\\Julia\\HyCatch")
push!(LOAD_PATH, pwd())

include("Option.jl")
include("Path.jl")
include("Modules.jl")
include("ToolBox.jl")
include("Reading.jl")
include("Clock.jl")
include("Interpolate.jl")
include("Snow.jl")
include("Interception.jl")

using RawArray

function HYCATCH()
	
    #= =============== READING DATA ============== =#

	if option.Dimension == "1D"
		# READING TIME SERIES CLIMATE
		# Precipitation
		Year_Climate, Month_Climate, Day_Climate, Seconds_Climate, ∑Pr_Obs, Pr_∑T_Obs = reading.d1.CLIMATE(path.Climate, "Pr_mm", "∑")
		# Potential evapotranspiration
		Year_Climate, Month_Climate, Day_Climate, Seconds_Climate, PotEvap_Obs, PotEvap_∑T_Obs = reading.d1.CLIMATE(path.Climate, "PotEvap_mm", "daily")
		# Temperature 
		Year_Climate, Month_Climate, Day_Climate, Seconds_Climate, Temperature_Obs, Temperature_∑T_Obs = reading.d1.CLIMATE(path.Climate, "Temp_c", "daily")
		# We are in 1D
		X = 1 
		Y = 1
		N_X = 1
		N_Y = 1

		#= =============== INITIAL CONDITIONS =============== =#
		∑T_Max = maximum(Pr_∑T_Obs[:]) # Maximum time of simulation which is taken for Pr
		∑T = 0.
		∑Pr = 0. 
		StorageVeg = 0. 
		∑snow = 0.
		PrMelt = 0. # Starting time from 0
		iPr = 1 # We start from iPr =2	
		iPotEvap = 1 # We start from iPotEvap =2	
		iTemperature = 1  # We start from iTemperature =2	
	
	elseif option.Dimension == "3D"
		# Reading dates of time series data
		Catchment_X_True = RawArray.raread(path.Home_Input * "\\Catchment\\Catchment_X_True.ra")
		Catchment_Y_True = RawArray.raread( path.Home_Input * "\\Catchment\\Catchment_Y_True.ra")
		Catchment_Information = RawArray.raread( path.Home_Input * "\\Catchment\\Catchment_Information.ra")
		N_X, N_Y, N_Xy_True = Catchment_Information[:]

		Pr_Date, Pr_∑T_Obs = reading.d3.DATES(path.Home_Input * "\\Climate\\Pr\\ClimateDates.csv")

		∑T_Max = Pr_∑T_Obs[length(Pr_∑T_Obs[:])] # Maximum time of simulation which is based on precipitation data
	end

	# HyCatch can take variable time step so the loop stops when the time of siumations =  ∑T_Max 
	Flag_Break = false
   while !Flag_Break # controles the time loop
		for iX = 1:N_X, iY = 1:N_Y # Loops spatially over X and Y

			ΔT = 60 .* 60 .* 24. * 1. # Daily time step which can change during simulation

			#= ================== MANAGING TIME STEP ================== =#
			# ∑T = cumulative time; ΔT_Adjust for last time step; Flag_Break = determines if we achieved the last time step
			∑T, ΔT_Adjust, Flag_Break = clock.CLOCK(∑T_Max, ∑T, ΔT)

			# Getting the climate data with the ΔT
			if option.Dimension == "1D"
				# ∑Pr [mm/ΔT]
				iPr, ∑Pr, Pr = interpolate.d1.∑χ_2_χ(iPr, ∑T, ∑Pr,  ∑Pr_Obs[:], Pr_∑T_Obs[:])
				
				# PotEvap for the current ΔT
				iPotEvap, PotEvap = interpolate.d1.OBSχ_2_χ(iPotEvap, ∑T, PotEvap_Obs[:], PotEvap_∑T_Obs[:])

				# Temperature for the current ΔT
				iTemperature, Temperature = interpolate.d1.OBSχ_2_χ(iTemperature, ∑T, Temperature_Obs[:], Temperature_∑T_Obs[:])

			elseif option.Dimension == "3D"
					println("")
					# interpolate.d1.∑PR_2_PR_3D(Pr_∑T_Obs, Pr_Date)
			end
				
			

			#= =============== SNOW =============== =#
			if modules.Snow == "run"
				Pr, PrMelt, ∑snow = snow.SNOW(Pr, Temperature,  ∑snow, ΔT_Adjust )
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

		end # for every X, Y

	end # while

println(∑Pr)

return

end # HYCATCH

HYCATCH()