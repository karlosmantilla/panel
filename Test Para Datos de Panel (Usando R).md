
# Pruebas para Modelos de Datos de Panel (Usando R)

Los test usados para los modelos de datos de panel involucran, principalmente, pruebas para la estabilidad del modelo, para los efectos individuales y/o los no observados en el tiempo y de correlación entre los efectos no observados y los regresores. En esta sessión, veremos algunos de los más comunes.

## Test de Estabilidad del Modelo

Se trata de una prueba _F_ basada en la comparación de un modelo obtenido para la muestra completa y un modelo basado en la estimación de una ecuación para cada individuo. En *R* se emplea la función `pooltest` donde el primer argumento de la función es un objeto tipo `plm` y el segundo argumento corresponde a un objeto tipo `pvcm` que asumen diferentes interceptos (`model=within`).

Emplearemos el ejemplo `Grunfeld` para ilustrar el test:


```R
# Primero, debemos llamar los datos
library("plm")
library("Ecdat")

data("EmplUK", package = "plm")
data("Produc", package = "Ecdat")
data("Grunfeld", package = "Ecdat")
data("Wages", package = "Ecdat")
```

Con los datos importados, procedemos a estimar los modelos y a realizar el test


```R
znp = pvcm(inv ~ value + capital, data = Grunfeld, model = "within")
zplm = plm(inv ~ value + capital, data = Grunfeld)
pooltest(zplm, znp)
```


    
    	F statistic
    
    data:  inv ~ value + capital
    F = 5.7805, df1 = 18, df2 = 170, p-value = 1.219e-10
    alternative hypothesis: unstability
    


Otra alternativa es introducir la fórmula en el primer argumento de la función:


```R
pooltest(inv ~ value + capital, data = Grunfeld, model = "within")
```


    
    	F statistic
    
    data:  inv ~ value + capital
    F = 5.7805, df1 = 18, df2 = 170, p-value = 1.219e-10
    alternative hypothesis: unstability
    


Según nos sugiere la evidencia, el modelo es inestable. Más adelante revisaremos algunas opciones para mejorar la estimación

## Test para efectos individuales y temporales

Este tipo de pruebas involucran Multiplicadores de Lagrange. La función `plmtest` permite implementar varios tipos de test en el argumente `type`:

 * `bp`: Breusch and Pagan (1980),
 * `honda`: Honda (1985), the default value,
 * `kw`: King and Wu (1997),
 * `ghm`: Gourieroux, Holly, and Monfort (1982).
 
Los efectos probados son indicados con el argumento `effect`: `individual`, `time` o `twoways`. Usemos el ejemplo `Grunfeld` para ilustrarlo:


```R
g <- plm(inv ~ value + capital, data = Grunfeld, model = "pooling")
plmtest(g, effect = "twoways", type = "ghm")
```


    
    	Lagrange Multiplier Test - two-ways effects (Gourieroux, Holly and
    	Monfort) for balanced panels
    
    data:  inv ~ value + capital
    chibarsq = 798.16, df0 = 0.00, df1 = 1.00, df2 = 2.00, w0 = 0.25, w1 =
    0.50, w2 = 0.25, p-value < 2.2e-16
    alternative hypothesis: significant effects
    



```R
plmtest(inv ~ value + capital, data = Grunfeld, effect = "twoways", type = "ghm")
```


    
    	Lagrange Multiplier Test - two-ways effects (Gourieroux, Holly and
    	Monfort) for balanced panels
    
    data:  inv ~ value + capital
    chibarsq = 798.16, df0 = 0.00, df1 = 1.00, df2 = 2.00, w0 = 0.25, w1 =
    0.50, w2 = 0.25, p-value < 2.2e-16
    alternative hypothesis: significant effects
    


La función `pFtest` calcula una prueba _F_ basada en la comparación de los modelos `within` y `pooling`:


```R
gw <- plm(inv ~ value + capital, data = Grunfeld, effect = "twoways", model = "within")
gp <- plm(inv ~ value + capital, data = Grunfeld, model = "pooling")
pFtest(gw, gp)
```


    
    	F test for twoways effects
    
    data:  inv ~ value + capital
    F = 17.403, df1 = 28, df2 = 169, p-value < 2.2e-16
    alternative hypothesis: significant effects
    



```R
pFtest(inv ~ value + capital, data = Grunfeld, effect = "twoways")
```


    
    	F test for twoways effects
    
    data:  inv ~ value + capital
    F = 17.403, df1 = 28, df2 = 169, p-value < 2.2e-16
    alternative hypothesis: significant effects
    


## Test de Hausman

La función `phtest` permite realizar esta prueba. Una comparación básica consiste en probar los modelos de efectos fijos y efectos aleatorios:


```R
gw <- plm(inv ~ value + capital, data = Grunfeld, model = "within")
gr <- plm(inv ~ value + capital, data = Grunfeld, model = "random")
phtest(gw, gr)
```


    
    	Hausman Test
    
    data:  inv ~ value + capital
    chisq = 2.3304, df = 2, p-value = 0.3119
    alternative hypothesis: one model is inconsistent
    


## Test de Correlación Serial

Un modelo con efectos individuales tiene errores compuestos que están correlacionados en serie por definición. La presencia del componente de error invariante en el tiempo da lugar a una correlación en serie que no se extingue con el tiempo, por lo que las pruebas estándar aplicadas a los datos agrupados siempre terminan rechazando "el nulo de los residuos esféricos". También puede haber una correlación serial de tipo "más usual" en los términos de error idiosincrásicos, por ejemplo, como un proceso _AR(1)_. Al decir que se va a "probar la correlación serial", nos referimos a las pruebas para este último tipo de dependencia.

Por esta razón, los sujetos de prueba para los componentes de errores individuales y errores idiosincráticos correlacionados en serie están estrechamente ligados. En particular, las pruebas simples unidireccionales (que se alejan de la hipótesis nula) están sesgadas hacia el rechazo. Sin embargo, las pruebas conjuntas tienen un tamaño correcto y su potencia es en ambas direcciones pero no brindan mucha información sobre la causa del rechazo de la hipótesis. Las pruebas condicionales son más potentes pero se presentan sustancialmente dependientes de la normalidad y la homocedasticidad.

En la librería `plm` existen una serie de pruebas conjuntas, marginales y condicionales basadas en Máxima Verosimilitud con algunas alternativas semiparamétricas robustas (frente a la heterocedasticidad) y está exentas de supuestos de distribución.

_Test de Efectos No Observados_

Este test es una prueba tipo Wooldridge, es semiparamétrica para la hipótesis nula $\sigma_{\mu}^{2} = 0$, por lo tanto, (no hay evidencia de efectos no observados en los residuales). El estadístico de prueba se define:

<a href="https://www.codecogs.com/eqnedit.php?latex=W&space;=&space;\frac{\sum_{i=1}^{n}&space;\sum_{t=1}^{T-1}&space;\sum_{s&space;=&space;t&plus;1}^{T}&space;\widehat{u}{it}\widehat{u}{is}}{\left[\sum_{i=1}^{n}&space;\left(\sum_{t=1}^{T-1}&space;\sum_{s&space;=&space;t&plus;1}^{T}&space;\widehat{u}{it}\widehat{u}{is}\right)^{2}&space;\right]^{1/2}}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?W&space;=&space;\frac{\sum_{i=1}^{n}&space;\sum_{t=1}^{T-1}&space;\sum_{s&space;=&space;t&plus;1}^{T}&space;\widehat{u}{it}\widehat{u}{is}}{\left[\sum_{i=1}^{n}&space;\left(\sum_{t=1}^{T-1}&space;\sum_{s&space;=&space;t&plus;1}^{T}&space;\widehat{u}{it}\widehat{u}{is}\right)^{2}&space;\right]^{1/2}}" title="W = \frac{\sum_{i=1}^{n} \sum_{t=1}^{T-1} \sum_{s = t+1}^{T} \widehat{u}{it}\widehat{u}{is}}{\left[\sum_{i=1}^{n} \left(\sum_{t=1}^{T-1} \sum_{s = t+1}^{T} \widehat{u}{it}\widehat{u}{is}\right)^{2} \right]^{1/2}}" /></a>

Esta prueba es asintóticamente normal estándar y no se basa en la homocedasticidad. Porl o tanto, tiene poder tanto contra la especificación de efectos aleatorios estándar, donde los efectos no observados son constantes dentro de cada grupo, como contra cualquier tipo de correlación serial.

Ilustremos lo anterior usando un modelo para `Produc`


```R
pwtest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc)
```


    
    	Wooldridge's test for unobserved individual effects
    
    data:  formula
    z = 3.9383, p-value = 8.207e-05
    alternative hypothesis: unobserved effect
    


_Pruebas localmente robustas para la correlación serial o efectos aleatorios_

La presencia de efectos aleatorios puede afectar las pruebas de correlación serial residual, y al contrario. Una solución es usar una prueba conjunta, que tiene poder contra ambas alternativas provista mediante la función `pbsytest`


```R
pbsytest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc, test = "J")
```


    
    	Baltagi and Li AR-RE joint test - balanced panel
    
    data:  formula
    chisq = 4187.6, df = 2, p-value < 2.2e-16
    alternative hypothesis: AR(1) errors or random effects
    


No importa la prueba que introduzcamos, por defecto, la función realiza el test para correlación serial (de primer orden):


```R
pbsytest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc)
```


    
    	Bera, Sosa-Escudero and Yoon locally robust test - balanced panel
    
    data:  formula
    chisq = 52.636, df = 1, p-value = 4.015e-13
    alternative hypothesis: AR(1) errors sub random effects
    



```R
pbsytest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc, test = "RE")
```


    
    	Bera, Sosa-Escudero and Yoon locally robust test (one-sided) -
    	balanced panel
    
    data:  formula
    z = 57.914, p-value < 2.2e-16
    alternative hypothesis: random effects sub AR(1) errors
    


_Test "por Defecto" para la Correlación Serial_

Es posible implementar un test que permita proceder con cualquier tipo de modelo. La función `pbgtest` provee los elementos para esto. Ilustrémoslo con el ejemplo `Grunfeld`:


```R
grun.fe <- plm(inv ~ value + capital, data = Grunfeld, model = "within")
pbgtest(grun.fe, order = 2)
```


    
    	Breusch-Godfrey/Wooldridge test for serial correlation in panel models
    
    data:  inv ~ value + capital
    chisq = 42.587, df = 2, p-value = 5.655e-10
    alternative hypothesis: serial correlation in idiosyncratic errors
    


## Estimación Robusta (Matriz de Covarianza)

Se busca determinar si el modelo es consistente con la heterocedasticidad. Todos los tipos de estimadores suponen que no hay correlación entre los errores de los diferentes grupos mientras se permite la heterocedasticidad entre los grupos, por lo que la matriz de covarianza completa de los errores es <a href="https://www.codecogs.com/eqnedit.php?latex=V&space;=&space;I_{n}&space;\otimes&space;\Omega_{i}$;&space;$i&space;=&space;1,&space;\dots,&space;n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?V&space;=&space;I_{n}&space;\otimes&space;\Omega_{i}$;&space;$i&space;=&space;1,&space;\dots,&space;n" title="V = I_{n} \otimes \Omega_{i}$; $i = 1, \dots, n" /></a>.

Ilustremos un ejemplo con los datos `Grunfeld`:


```R
library("lmtest")
re <- plm(inv ~ value + capital, data = Grunfeld, model = "random")
coeftest(re, vcov = pvcovHC)
```


    
    t test of coefficients:
    
                  Estimate Std. Error t value  Pr(>|t|)    
    (Intercept) -57.834415  23.449626 -2.4663   0.01451 *  
    value         0.109781   0.012984  8.4551 6.186e-15 ***
    capital       0.308113   0.051889  5.9379 1.284e-08 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    


Sin con las opciones por defecto está bien, entonces, tenemos un modelo donde hemos estimado parámetros consistentes con la heterocedasticidad. De lo contrario, podemos revisar los argumentos en detalle para cambiar las opciones (usando la función `help`)
