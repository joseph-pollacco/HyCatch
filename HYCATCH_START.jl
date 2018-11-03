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
    
	if option.Dimension == "1D" #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		#= ====================== READING DATA ============================================================================== =#
		# READING TIME SERIES CLIMATE
		# Precipitation
		Pr_Date_Obs, ∑Pr_Obs, Pr_∑T_Obs = reading.d1.CLIMATE(path.d1.Climate, "Pr_mm", "∑")
		
		# Potential evapotranspiration
		PotEvap_Date_Obs, PotEvap_Obs, PotEvap_∑T_Obs = reading.d1.CLIMATE(path.d1.Climate, "PotEvap_mm", "daily")
		
		# Temperature 
		Temperature_Date_Obs, Temperature_Obs, Temperature_∑T_Obs = reading.d1.CLIMATE(path.d1.Climate, "Temp_c", "daily")
		
		# We are in 1D
		X = Y = N_X = N_Y = 1

	elseif option.Dimension == "3D" #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		# Reading the X and Y coordinates which are true
		Catchment_X_True = RawArray.raread(path.fixed.Catchement * "Catchment_X_True.ra")
		Catchment_Y_True = RawArray.raread( path.fixed.Catchement * "Catchment_Y_True.ra")
		Catchment_Information = RawArray.raread(path.fixed.Catchement * "Catchment_Information.ra")
		N_X, N_Y, N_Xy_True = Catchment_Information[:]

		# Dates where there are available spatial 2D data
		Pr_Date_Obs, Pr_∑T_Obs = reading.d3.DATES(path.d3.Pr * "\\ClimateDates.csv")
		PotEvap_Date_Obs, PotEvap_∑T_Obs = reading.d3.DATES(path.d3.Etp * "\\ClimateDates.csv")
		Temperature_Date_Obs, Temperature_∑T_Obs = reading.d3.DATES(path.d3.Temperature * "\\ClimateDates.csv")

	end # option.dimension

	#= =============== INITIAL CONDITIONS =============== =#


	Pr = zeros(Float64, N_X, N_Y)
	∑Pr = zeros(Float64, N_X, N_Y)
	∑T = StorageVeg = ∑snow = PrMelt = 0. # Starting time from 0
	iPr = iPotEvap = iTemperature = 1  # We start from 2	
	∑T_Max = maximum(Pr_∑T_Obs[:]) # Maximum time of simulation which is taken for Pr

	Pr4 = 0


	#********************************************************
	#			LOOPING
	#********************************************************

	# HyCatch can take variable time step so the loop stops when the time of siumations =  ∑T_Max 
	Flag_Break = false
	while !Flag_Break # controles the time loop
		
			ΔT = 60 .* 60 .* 24. * 1. # Daily time step which can change during simulation

			#= ================== MANAGING TIME STEP ================== =#
			# ∑T = cumulative time; ΔT_Adjust for last time step; Flag_Break = determines if we achieved the last time step
			∑T, ΔT_Adjust, Flag_Break = clock.CLOCK(∑T_Max, ∑T, ΔT)

			# Getting the climate data for every ΔT
			if option.Dimension == "1D"
				# ∑Pr [mm/ΔT]
				iPr, ∑Pr, Pr = interpolate.d1.∑χ_2_χ(iPr, ∑T, ∑Pr[1, 1], ∑Pr_Obs[:], Pr_∑T_Obs[:])
				
				# PotEvap for the current ΔT
				iPotEvap, PotEvap = interpolate.d1.STAIRCASE_OBSχ_2_χ(iPotEvap, ∑T, PotEvap_Obs[:], PotEvap_∑T_Obs[:])

				# Temperature for the current ΔT
				iTemperature, Temperature = interpolate.d1.STAIRCASE_OBSχ_2_χ(iTemperature, ∑T, Temperature_Obs[:], Temperature_∑T_Obs[:])

			elseif option.Dimension == "3D"
				# Getting the climate data for every ΔT

				∑Pr_Obs = zeros(Float64, N_X, N_Y)
				
				iPr, ∑Pr, Pr =interpolate.d3.∑χ_2_χ(iPr, ∑T, ∑Pr[1:N_X, 1:N_Y], Pr_∑T_Obs[:], ∑Pr_Obs[:], Pr_Date_Obs[:], Catchment_X_True[:], Catchment_Y_True[:], N_X, N_Y, path.d3.Pr, "Pr" )

					# println("$X , $Y")				
			end
				
			
			#= =============== SNOW =============== =#
			# if modules.Snow == "run"
			# 	Pr2, PrMelt, ∑snow = snow.SNOW(Pr[iX, iY], Temperature,  ∑snow, ΔT_Adjust )
			# end


			# #= =============== RAINFALL_INTERCEPTION =============== =#
			# if modules.Interception == "run"
			# 	IdLcdb = 30
			# 	interceptedPerc = 0.2
			# 	Lai = 4

			# 	# Deriving storageVegMaxLai from LookUpTable_Veg and from IdLcdb
			# 	#  storageVegMaxLai = JuliaDB.select(filter(i -> (i.ID_LCDB == IdLcdb), LookUpTable_Veg), :storageVegMaxLai)[1]
			# 	storageVegMaxLai = 0.5

			# 	Pr3, PotEvap, StorageVeg = interception.rutter_joe.RAINFALL_INTERCEPTION(Pr[1,1], PotEvap, Lai, storageVegMaxLai, StorageVeg)
			# end #  modules.Interception


			# if modules.Snow == "run"
			# 	# Melted snow (if used) is not intercepted by the canopy
			# 	Pr4 += PrMelt
			# end

			# # This is to determine when the loop stops
			# if Flag_Break
			# 	break
			# end 
		

		
	end # while

println(∑Pr)

return

end # HYCATCH

HYCATCH()