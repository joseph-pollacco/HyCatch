module interpolate
	export POINTS_2_SlopeIntercept

   """
      ∑PR_2_PR
   Derive Pr from ∑Pr which depends on the time step of the model and the time of collecting the observations

   iPr: index of observed ∑Pr, Pr_∑T
   Pr_∑T: cumulative time of collecting the observations collected at  iPr
   ∑Pr: cumulative Pr of collecting the observations collected at  iPr
   ∑Pr_Past: cumulative Pr of the previous time step
   ∑T: current state of cumulative timedwait
   
	"""

	"""
	POINTS_2_SlopeIntercept
	From Point1 [X1, Y1] and point2 [X2, Y2] compute Y = Slope.X + Intercept
	"""
	function POINTS_2_SlopeIntercept(X1, Y1, X2, Y2)
		Slope = (Y2 - Y1) / (X2 - X1)
		
		Intercept = (Y1 * X2 - X1 * Y2) / (X2 - X1)
		return Slope, Intercept
	end # POINTS_2_SlopeIntercept

	
	module d1
		using interpolate
		export  ∑χ_2_χ, STAIRCASE_OBSχ_2_χ

		# ******************************************************
		# ∑χ_2_χ
		# ******************************************************
		function ∑χ_2_χ(iχ, ∑T, ∑χ, ∑χ_Obs, χ_∑T_Obs)
			∑χ_F = zeros(Float64,2)
			χ = zeros(Float64,2)
			
 			# Determening of we should increase iPr
			Flag_Break = false
			while !Flag_Break
				if χ_∑T_Obs[iχ] <= ∑T <= χ_∑T_Obs[iχ+1]
					Flag_Break = true
					break
				else 
					iχ += 1
					Flag_Break = false
				end
			end #while

			# Building a regression line which passes from POINT1 [Pr_∑T[iPr], ∑Pr[iPr]] and POINT2: [Pr_∑T[iPr+1], ∑Pr[iPr+1]]
			Slope, Intercept = interpolate.POINTS_2_SlopeIntercept(χ_∑T_Obs[iχ], ∑χ_Obs[iχ], χ_∑T_Obs[iχ+1], ∑χ_Obs[iχ+1])

			∑χ_F[1,1] = Slope * ∑T + Intercept
			
			# Precipitation [mm /  ΔT]
			χ[1,1] = abs(∑χ_F[1,1] - ∑χ)

			return iχ, ∑χ_F, χ  
		end # ∑χ_2_χ


		# ******************************************************
		# STAIRCASE_OBSχ_2_χ
		# ******************************************************
		function STAIRCASE_OBSχ_2_χ(iχ, ∑T,  χ_Obs, χ_∑T)
			χ_F = zeros(Float64,2)
			Flag_Break = false
			while !Flag_Break
				if χ_∑T[iχ] <= ∑T <= χ_∑T[iχ+1]
					Flag_Break = true
					break
				else 
					iχ += 1
					Flag_Break = false
				end #if
			end #while
	
			χ_F[1,1] = χ_Obs[iχ+1]
		
			return  iχ, χ_F
		end
	end # module 1D 



	module d3 #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	using interpolate
	using RawArray
	export  ∑χ_2_χ,  STAIRCASE_OBSχ_2_χ

		# ******************************************************
		# ∑χ_2_χ
		# ******************************************************
		function ∑χ_2_χ(iχ, ∑T, ∑χ,  χ_∑T_Obs, ∑χ_Obs,χ_Date_Obs, Catchment_X_True, Catchment_Y_True, N_X, N_Y, Path, NameObs)
			
			∑χ_Obs_F = zeros(Float64, N_X, N_Y) 
			∑χ_F = zeros(Float64, N_X, N_Y) # Cumaltive Pr in time + 1
			χ = zeros(Float64, N_X, N_Y) # Actual value of Pr for every cell

			# Reading the map for time step iχ
			# Year = χ_Date_Obs[iχ,1] 
			# Month = χ_Date_Obs[iχ,2] 
			# Day= χ_Date_Obs[iχ,3] 
			# Second = χ_Date_Obs[iχ,4]
			# Path_χ = Path * NameObs * "_" * string(Year) * "_" * string(Month) *  "_" * string(Day) * "_" * string(Second) * ".ra" 
			# χ_Obs = RawArray.raread(Path_χ)
			
 			# Determening if we should increase iPr which depends on ΔT
			Flag_Break = false
			while !Flag_Break
				if χ_∑T_Obs[iχ] <= ∑T <= χ_∑T_Obs[iχ+1] # do not need to increase iχ
					Flag_Break = true
					break
				else 
					iχ += 1
					Flag_Break = false
				end
			end #while

			# Reading the map for forward time step iχ+1
			Year = χ_Date_Obs[iχ+1,1] 
			Month = χ_Date_Obs[iχ+1,2] 
			Day= χ_Date_Obs[iχ+1,3] 
			Second = χ_Date_Obs[iχ+1,4]
			Path_χ = Path *  NameObs * "_" * string(Year) * "_" * string(Month) *  "_" * string(Day) * "_" * string(Second) * ".ra" 
			χ_Obs_F = RawArray.raread(Path_χ) # Forward in time

			for iX = 1:N_X, iY = 1:N_Y # Loops spatially over X and Y
				X = Catchment_X_True[iX]
				Y = Catchment_Y_True[iY]

				∑χ_Obs_F[X,Y] = ∑χ_Obs[X,Y] + χ_Obs_F[X,Y]

				# Building a regression line which passes from POINT1 [Pr_∑T[iPr], ∑Pr[iPr]] and POINT2: [Pr_∑T[iPr+1], ∑Pr[iPr+1]]
				Slope, Intercept = interpolate.POINTS_2_SlopeIntercept(χ_∑T_Obs[iχ], ∑χ_Obs[X,Y], χ_∑T_Obs[iχ+1], ∑χ_Obs_F[X,Y])

				∑χ_F[X,Y] = Slope * ∑T + Intercept
				
				# Precipitation [mm /  ΔT]
				χ[X,Y] = abs(∑χ_F[X,Y] - ∑χ[X,Y])
			end # for every X, Y

			return iχ, ∑χ_F, χ, ∑χ_Obs_F  
		end # ∑χ_2_χ


		# ******************************************************
		# STAIRCASE_OBSχ_2_χ
		# ******************************************************
		function STAIRCASE_OBSχ_2_χ(iχ, ∑T,  χ_Obs, χ_∑T)
			χ_F = zeros(Float64,2)
			Flag_Break = false
			while !Flag_Break
				if χ_∑T[iχ] <= ∑T <= χ_∑T[iχ+1]
					Flag_Break = true
					break
				else 
					iχ += 1
					Flag_Break = false
				end #if
			end #while
	
			χ_F[1,1] = χ_Obs[iχ+1]
		
			return  iχ, χ_F
		end
		
	end # module 3D #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
end # module interpolate