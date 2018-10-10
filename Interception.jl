module interception
	
	module rutter_joe  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		export RAINFALL_INTERCEPTION

		using interception

		"""
			RAINFALL_INTERCEPTION

	   Pr = Precipitation which falls on top of canopy [mm / Δtime] 
	   PotEvap =  Potential Evapotranspiration
	   StorageVeg = current storage of water in the vegetation [mm]
	   StorageVeg_Norm = Normalized storage of water in the vegetation [0-1]
	   storageVeg_Max = Maximum storage of water in the vegetation [mm]
	   interceptedPerc = % of Pr which is intercepted by the vegetation at the very beginning [0-1]
		"""
		function RAINFALL_INTERCEPTION(Pr, PotEvap, Lai, storageVegMaxLai, StorageVeg;  interceptedPerc=1., potEvap_Int = 0.666, prTreshold = 1.)
			# Requires initial StorageVeg

			if Pr > prTreshold && StorageVeg == 0.

				storageVeg_Max = interception.lai.LAI_2_storageVeg_Max(Lai, storageVegMaxLai)

				
				# Pr falls on top of the vegetation and Pr_Intercepted is the amount of Pr which is intercepted by the vegetaion which depends on parameter interceptedPerc
				Pr_Intercepted = interceptedPerc * Pr

				# Fast Pr which fall directly on the ground
				Pr_Ground = Pr - Pr_Intercepted
				
				# Normalized water stored in the vegetation
				StorageVeg_Norm = StorageVeg / storageVeg_Max

				# According to Rutter et al. (1971), evaporation from wet canopies is assumed to be proportional to the fraction of the canopy that is wet Fw (0-1) computed following Deardorff (1978):
				PotEvap_Int =  min(PotEvap * StorageVeg_Norm ^ potEvap_Int , StorageVeg)
			
				# Pr that overflows because the vegetation cannot store more water
				Pr_Overflow = max(StorageVeg + Pr_Intercepted - PotEvap_Int -  storageVeg_Max, 0.)

				# Amount of water stored in the vegetaion. StorageVeg =< storageVeg_Max
				StorageVeg += Pr_Intercepted - PotEvap_Int - Pr_Overflow

				# Total amount of throughfall
				Pr_Throughfall = Pr_Ground + Pr_Overflow

				# Remaining potential evapotranspiration
				PotEvap_Remain = PotEvap - PotEvap_Int
			else
				Pr_Throughfall = Pr
				PotEvap_Remain = PotEvap
			end

			return Pr_Throughfall, PotEvap_Remain, StorageVeg

	  	end # RAINFALL_INTERCEPTION

	end # module rutter_joe



	module lai #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		export LAI_2_storageVeg_Max

		"""
		   LAI_2_storageVeg_Max

		Converts LAI to storageVeg_Max
		The general equation based on Menzel’s equation
		"""
		function LAI_2_storageVeg_Max(Lai, storageVegMaxLai)
			return storageVeg_Max = storageVegMaxLai * log(1. + Lai)
		end #LAI_2_storageVeg_Max


	end #lai


end # module interception

