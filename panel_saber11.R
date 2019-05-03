### Importamos los datos

datos.p<-read.delim('clipboard', header = T, dec = ',')


### Calculamos algunos valores (proporciones):

datos.p$p_mujeres<-datos.p$F/(datos.p$F + datos.p$M)
datos.p$p_E123<-(datos.p$E1 + datos.p$E2 + datos.p$E3)/(datos.p$E1 + datos.p$E2 + datos.p$E3 +
datos.p$E4 + datos.p$E5 + datos.p$E6)
datos.p$p_basica<-(datos.p$Primaria + datos.p$Secundaria)/(datos.p$Postgrado + datos.p$Profesional +
datos.p$Tec.o.Tecno + datos.p$Secundaria + datos.p$Primaria + datos.p$NSNR)
datos.p$p_compu<-datos.p$Si/(datos.p$Si + datos.p$No)
datos.p$p_rural<-datos.p$RURAL/(datos.p$RURAL + datos.p$URBANO)

### Seleccionamos los datos:

datos.pan<-datos.p[,c(1:5,24:28)]
head(datos.pan)

### vamos a empezar con los modelos de efectos fijos y efectos aleatorios:
#### Traemos la librería plm para calcular los modelos:

library('plm')

# Si requerimos instalarla usamos install.packages('plm')

### Debemos indicar cuáles columnas son los índices:

datos.pan <- pdata.frame(datos.pan, index = c("depto", "periodo"))

plot(datos.pan[,4:10])

coplot(punt_ingles ~ periodo|depto, type="b", data=datos.pan, rows = 3)
# Se lee en el orden de los grupos y desde la esquina inferior izquierda

coplot(punt_matematicas ~ periodo|depto, type="b", data=datos.pan, rows = 3)

### Vamos a mirar inglés en función de las proporciones

mod.fe <- plm(punt_ingles ~ p_mujeres + p_E123 + p_basica + p_compu + p_rural,
data = datos.pan, model = "within") # Efectos Fijos

mod.re <- plm(punt_ingles ~ p_mujeres + p_E123 + p_basica + p_compu + p_rural,
data = datos.pan, model = "random") # Efectos Aleatorios

summary(mod.fe)

summary(mod.re)

## Veamos las diferencias entre los grupos
summary(fixef(mod.fe))

Y el efecto del tiempo

mod.twfe <- plm(punt_ingles ~ p_mujeres + p_E123 + p_basica + p_compu + p_rural,
data = datos.pan, model = "within", effect = "twoways")

fixef(mod.twfe, effect = "time")

ef.per<-data.frame(efect=fixef(mod.twfe, effect = "time"))
ef.per$periodo<-rownames(ef.per)

plot(fixef(mod.twfe, effect = "time"), type="b", ylab = 'Efecto', xlab = 'Periodo')

library(ggplot2)

ggplot(ef.per, aes(x=periodo, y = efect, group = 1)) + geom_line(size = 1, linetype = "dashed") +
geom_point(size = 3) + theme_light()

plm::pFtest(mod.fe, mod.re) # H0: ambos modelos son iguales