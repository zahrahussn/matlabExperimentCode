# install.packages("rstudioapi")
library(rstudioapi)
# read calibration file:
# calFileName <- "vpixx-428A-pseudogray-Nov-17-2023.csv"
# calFileName <- "NEC-multisync-M16-jan-28-2023.csv"
# calFileName <- "vpixx-3d-jan-9-2023.csv"
# calFileName <- "vpixx-428A-M16-Nov-17-2023.csv"

calFileName <- selectFile(
  caption = "Select File",
  label = "Select",
  path = documentPath(),
  filter = "CSV Files (*.csv)",
  existing = TRUE
)

calData <- read.csv(calFileName)

# extract luminance & pixel values
lumMean <- with(calData,tapply(lum,val,mean))
pixVal <- sort(unique(calData$val))

# normalize values so Luminance ranges from zero to 1
blackLight <- lumMean[1]
lumMean <- lumMean - blackLight
lumNorm <- lumMean/max(lumMean)

gFunc <- function(p,g){p^g}
gFit <- nls(lumNorm ~ gFunc(pixVal,gEst),start=list(gEst=2.2))
gammaEst <- coef(gFit)
plot(x=pixVal,y=lumNorm,type="p")
pix <- seq(0,1,0.01)
fit2 <- (pix^gammaEst)
lines(x=pix,y=fit2,col="red")

lum2 <- lumNorm^(1/gammaEst)
plot(x=pixVal,y=lum2,type="p")
lm.1 <- lm(lum2~pixVal)
abline(lm.1,col="red")
summary(lm.1)

lum3 = lum2*max(lumMean) + blackLight
plot(x=pixVal,y=lum3,type="p")
lm.3 <- lm(lum3~pixVal)
abline(lm.3,col="red")
summary(lm.3)

print(sprintf("Estimated gamma = %f",gammaEst))

# plot(x=pixVal,y=lumNorm,type="p",cex=0.25,xlim=c(0.4,.6),ylim=c(0,0.3))
