module snow
    export SNOW

"""
   SNOW
 based on: He M, Hogue TS, Franz KJ, Margulis SA, Vrugt JA. 2011. Characterizing parameter sensitivity and uncertainty for a snow model across hydroclimatic regimes. Advances in Water Resources, 34: 114-127.

Pr = precipitation [mm / Δtime]
Temp = temperature [C]
tempSnow = temperature for which rain always turns into snow [-2, 2]
tempMelt = temperature for which rain always turns into rain [0, 1]
snowCorrFactor = Snowfall correction factor [0.7, 1.4]
meltCoeff = melting coefficient mm/6h/ C [0.05, 2.0] = [0.00000231, 0.00009259]
ΔT = time step [seconds]
"""

   function SNOW(Pr, Temp, ∑snow, ΔT; snowCorrFactor=0.8, tempSnow=-1.0, tempMelt=1., meltCoeff=0.00004630 )

    PrMelt = PrWater = PrSnow = 0.
    meltCoeff = ΔT * meltCoeff # put meltCoeff in units of ΔT

    # Requires initial ∑snow

      # Partition between precipitation and water
      if Temp < tempSnow
         PrSnow = snowCorrFactor * Pr

      elseif Temp > tempMelt
         PrWater = Pr

    # Needs some snow for the rainwater to fix on the ground which occures when temp is close to 0
      elseif tempSnow <= Temp <= tempMelt 
         if ∑snow > 1. # [mm]
            PrSnow =  snowCorrFactor * Pr
               # PrSnow(t) =  sCF * Pr(t) * tempMelt - Temp(t)) / tempMelt - tempSnow) 
         else
              PrWater = Pr
            #   PrWater(t) = Pr(t) * (Temp(t) - tempSnow) / tempMelt - tempSnow) 
         end           
      end

      #  SNOW MELT
      if  (Temp >= tempMelt) && (Pr <=  ∑snow)
         PrMelt = min(meltCoeff * ( Temp - tempMelt ) , ∑snow)

      elseif (Temp >= tempMelt) && (Pr >  ∑snow) #Cumulate the snow melt
         PrMelt = min( (meltCoeff * (1. + Pr / ∑snow) ) * ( Temp - tempMelt ) , ∑snow)  
      end

      # CUMULATING THE SNOW DEPTH
      ∑snow = max(∑snow +  PrSnow - PrMelt , 0.)

      return PrWater, PrMelt, ∑snow

   end #SNOW


end #snow


# function [ PrWater PrMelt] = SNOW_SIMPmodule(Pr, Temp, sCF, tempSnow,tempMelt,  meltCoeff, meltCoeffPr, tempMaxPr, OPTIONSnow)
    

# %Putting to zero
#    PrSnow= zeros(tempMaxPr,1);
#    PrWater= zeros(tempMaxPr,1);
#    PrMelt= zeros(tempMaxPr,1);
#    ∑snow=zeros(tempMaxPr,1);


#    for t=2:tempMaxPr

#        %% PARTITION BETWEEN SNOW & RAIN
#            if (Temp(t) < tempSnow)
#                PrSnow(t) = sCF * Pr(t);

#            elseif (Temp(t) > tempMelt)
#                PrWater(t) = Pr(t);

#            elseif (Temp(t) >= tempSnow) &&  (Temp(t) <= tempMelt) %needs some snow for the snow to fix on the ground if Temp is not too cold

#                if ∑snow(t-1) > 0
#                    PrSnow(t) =  sCF * Pr(t);
#                     %PrSnow(t) =  sCF * Pr(t) * tempMelt - Temp(t)) / tempMelt - tempSnow) ;
#                else
#                    PrWater(t) = Pr(t);
#                    %PrWater(t) = Pr(t) * (Temp(t) - tempSnow) / tempMelt - tempSnow) ;
#                end           
#            end

#        %% SNOW MELT
#            if (Temp(t) >=tempMelt) && Pr(t) <= 0.01
#                PrMelt(t) = min ( meltCoeff * ( Temp(t) -tempMelt ) , ∑snow(t-1));

#            elseif  (Temp(t) >=tempMelt) && Pr(t) <=  ∑snow(t-1)
#               PrMelt(t) = min ( meltCoeffPr * ( Temp(t) -tempMelt ) , ∑snow(t-1) );

#            elseif (Temp(t) >=tempMelt) && Pr(t) >  ∑snow(t-1) % Cumulate the snow melt
#               PrMelt(t) = min ( (meltCoeffPr * (1 + Pr(t) / ∑snow(t-1)) ) * ( Temp(t) -tempMelt ) , ∑snow(t-1));  
#            end

#        %% CUMULATING THE SNOW DEPTH
#             ∑snow(t) = max ( ∑snow(t-1) +  PrSnow(t) - PrMelt(t) , 0);

#    end    
# end