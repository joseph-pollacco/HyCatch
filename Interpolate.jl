module interpolate

   export ∑PR_2_PR, OBSstairs, POINTS_2_SlopeIntercept

   """
      ∑PR_2_PR
   Derive Pr from ∑Pr which depends on the time step of the model and the time of collecting the observations

   iPr: index of observed ∑Pr, Pr_∑T
   Pr_∑T: cumulative time of collecting the observations collected at  iPr
   ∑Pr: cumulative Pr of collecting the observations collected at  iPr
   ∑Pr_Past: cumulative Pr of the previous time step
   ∑T: current state of cumulative timedwait
   
   """
   function ∑PR_2_PR(∑T, ∑Pr_Past, iPr, ∑Pr, Pr_∑T)
      # Determening of we should increase iPr
      Flag_Break = false
      while !Flag_Break
         if Pr_∑T[iPr] <= ∑T <= Pr_∑T[iPr+1]
            Flag_Break = true
            break
         else 
            iPr += 1
            Flag_Break = false
         end #if
      end #while

      # Building a regression line which passes from POINT1 [Pr_∑T[iPr], ∑Pr[iPr]] and POINT2: [Pr_∑T[iPr+1], ∑Pr[iPr+1]]
      Slope, Intercept = POINTS_2_SlopeIntercept(Pr_∑T[iPr], ∑Pr[iPr], Pr_∑T[iPr+1], ∑Pr[iPr+1])

      ∑Pr = Slope * ∑T + Intercept

      # Precipitation [mm /  ΔT]
      Pr =  abs(∑Pr -  ∑Pr_Past)

        # Cleaning up
        Flag_Break = Intercept = Slope = ∑Pr_Past = nothing

      return ∑Pr, Pr, iPr 

   end #CUMULPR_2_PR



   function OBSstairs(∑T, iPotEvap, PotEvap, ∑T_PotEvap)
      Flag_Break = false
      while !Flag_Break
         if ∑T_PotEvap[iPotEvap] <= ∑T <= ∑T_PotEvap[iPotEvap+1]
            Flag_Break = true
            break
         else 
            iPotEvap += 1
            Flag_Break = false
         end #if
      end #while

      PotEvap = PotEvap[iPotEvap+1]
    
      return PotEvap, iPotEvap
   end



   """
      POINTS_2_SlopeIntercept
   From Point1 [X1, Y1] and point2 [X2, Y2] compute Y = Slope.X + Intercept
   """
   function POINTS_2_SlopeIntercept(X1, Y1, X2, Y2)
      Slope = (Y2 - Y1) / (X2 - X1)
      
      Intercept = (Y1 * X2 - X1 * Y2) / (X2 - X1)

      return Slope, Intercept
   end # POINTS_2_SlopeIntercept
   
end