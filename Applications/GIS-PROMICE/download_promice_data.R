station_list <- c("KAN_U", "KAN_L", "KAN_M", "KPC_L", "KPC_U", "NUK_L", "NUK_U", "QAS_L", "QAS_U", "UPE_L", "UPE_U", "THU_L", "THU_U", "SCO_L", "SCO_U", "TAS_L", "TAS_A")

vals <- c("Year", "MonthOfYear", "DayOfMonth", "HourOfDay.UTC.",  "AirPressure.hPa.", "AirTemperature.C.", "AirTemperatureHygroClip.C." , "RelativeHumidity...", "SpecificHumidity.g.kg.", "ShortwaveRadiationDown.W.m2.", "ShortwaveRadiationDown_Cor.W.m2.", "ShortwaveRadiationUp.W.m2.", "ShortwaveRadiationUp_Cor.W.m2.", "Albedo_theta.70d", "LongwaveRadiationDown.W.m2.", "LongwaveRadiationUp.W.m2.", "CloudCover", "SurfaceTemperature.C.", "HeightSensorBoom.m.",   "HeightStakes.m.",  "IceTemperature1.C.", "IceTemperature2.C.", "IceTemperature3.C.", "IceTemperature4.C.", "IceTemperature5.C.", "TiltToEast.d.", "TiltToNorth.d.", "LoggerTemperature.C.")

for(i in station_list){   
  cat(i, "\n")
 df=read.table(paste0("http://promice.org/PromiceDataPortal/api/download/f24019f7-d586-4465-8181-d4965421e6eb/v03/hourly/csv/", i, "_hour_v03.txt"), header=TRUE)

df <- df[,vals]

save(df, file=paste0("data/",i,".RData"))

}

