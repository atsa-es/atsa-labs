fils <- dir("data", full.names=TRUE)
sb <- 5.6703e-08
e <- 0.97
res <- c()
for(fil in fils){
  load(fil)
  df[df == -999] <- NA
  df <- subset(df, Year >= 2014 & Year <= 2017)
  Lout <- df$LongwaveRadiationUp.W.m2.
  Lout[Lout>sb*273.15^4] <- sb*273.15^4
  Lin <- df$LongwaveRadiationDown.W.m2.
  surf.T <- ((Lout - (1-e)*Lin)/(e*sb))^(1/4) - 273.15
  val <- cbind(surf.T1 = round(surf.T, digits=2), surf.T2 = df$SurfaceTemperature.C.)
  val <- cbind(val, diff = val[,1]-val[,2])
  val <- cbind(val, df)
  val <- val[!is.na(val[,1])&!is.na(val[,2]),]
  cuts <- cut(val[,1], seq(-40,5,5))
  cat("\n", fil, "\n")
  res <- rbind(res, c(tapply(val[,3], cuts, mean), mean(val[val[,2]!=0,3]), mean(val[val[,2]==0,3])))
}
aa <- unlist(lapply(stringr::str_split(fils, "[.]"), function(x){x[1]}))
rownames(res) <- unlist(lapply(stringr::str_split(aa, "/"), function(x){x[2]}))
colnames(res) <- c(seq(-40,5,5)[-1]+2.5, "negative", "zero")
library(tidyr)
df2 <- pivot_longer(as.data.frame(res), cols=everything(), names_to="name", values_to="value")
df2$name <- factor(df2$name, levels=c(seq(-40,5,5)[-1]+2.5, "negative", "zero"), ordered=TRUE)
df3 <- subset(df2, name %in% c("negative", "zero"))
df3$name <- factor(df3$name)t
boxplot(value~name, data=df3, ylim=c(-0.1,.5), xlab="PROMICE T_s", ylab="mean difference",
        main="Difference between PROMICE T_s\nand T_s from Longwave radiation")
abline(h=0, lty=2, col="blue")
text(2,.5, paste0("mean bias = ", round(mean(df3$value[df3$name=="zero"]), digits=2)))
