module clock

   export CLOCK

   function CLOCK(∑T_Max, ∑T, ΔT)
      # Adjusting for the last time step and determine when to exit the loop
      if ∑T_Max - ∑T <= ΔT
         ΔT_Adjust =  ∑T_Max - ∑T
         Flag_Break = true

      else
         Flag_Break = false
         ΔT_Adjust = ΔT

      end # if
     
      ∑T += ΔT_Adjust

      # Cleaning up
      ΔT = nothing

      return ∑T, ΔT_Adjust, Flag_Break

   end # CLOCK()

end # clock
