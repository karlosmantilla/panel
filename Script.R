
packs<-c("plm","Ecdat")
install.packages(packs)

library("plm")
library("Ecdat")
data("EmplUK", package = "plm")
data("Produc", package = "Ecdat")
data("Grunfeld", package = "Ecdat")
data("Wages", package = "Ecdat")

head(Grunfeld)

plot(Grunfeld[,c(3:5)])

coplot(inv ~ year|factor(firm), type="o", data=Grunfeld)  

args(plm)

grun.fe <- plm(inv ~ value + capital, data = Grunfeld, model = "within") # Efectos Fijos
grun.re <- plm(inv ~ value + capital, data = Grunfeld, model = "random") # Efectos Aleatorios

summary(grun.fe)

summary(grun.fe)$coeff

summary(grun.re)

summary(grun.re)$coeff

summary(fixef(grun.fe))

grun.twfe <- plm(inv ~ value + capital, data = Grunfeld, model = "within",
effect = "twoways")
fixef(grun.twfe, effect = "time")

plot(fixef(grun.twfe, effect = "time"), type="l")

plm::pFtest(grun.fe, grun.re)

phtest(grun.fe, grun.re)
