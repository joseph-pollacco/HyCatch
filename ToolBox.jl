module toolbox

	module read # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	export READ_HEADER
	using DelimitedFiles
	
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
		end # READS_HEADER

	end # module read # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	
end # module toolbox