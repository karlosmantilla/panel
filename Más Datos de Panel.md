
# Más Aspectos sobre Datos de Panel (Usando R)

En la sesión anterior revisamos algunos aspectos básicos sobre los datos de pánel haciendo uso de **R**. Continuaremos con el uso del software pero revisaremos otro enfoque.

Veamos otra expresión para el modelo general:

<img src="https://github.com/karlosmantilla/panel/blob/master/dpf1.png" alt="Your image title" width="350"/>

Y el modelo con heterogeneidad definida será:

<img src="https://github.com/karlosmantilla/panel/blob/master/dpf2.png" alt="Your image title" width="350"/>

La apropiada estimación del modelo dependerá de las propiedades de los términos del error. Estimamos los modelos de _efectos fijos_ y _efectos aleatorios_ para un conjunto de datos. Sin embargo, recordemos que existe varios tipos de datos y, en ocasiones, se require dar un tratamiento especial antes de proceder a estimar el modelo. Veamos algunos ejemplos:

## Usando variables instrumentales

Una variable instrumental es aquella que nos permite realizar una estimación consistente cuando las covariables están correlacionadas con el error de la regresión. Para ilustrarlo, vamos a usar, nuevamente, los conjuntos de datos de la sesión anterior:


```R
library(plm)
library(Ecdat)
data("EmplUK", package = "plm")
data("Produc", package = "Ecdat")
data("Grunfeld", package = "Ecdat")
data("Wages", package = "Ecdat")
```

El conjunto de datos llamado `EmplUK` nos permitirá construir una variable instrumental para la ecuación del empleo. Usaremos la variable `salarios` rezagada un periodo como variable instrumental. Veamos las formas de introducirla en el algoritmo:


```R
emp.iv1 <- plm(emp ~ wage + capital | lag(wage, 1) + capital, data = EmplUK, model = "random")
emp.iv2 <- plm(emp ~ wage + capital | . - wage + lag(wage, 1), data = EmplUK, model = "random")
emp.iv3<- plm(emp ~ wage + capital, instruments = ~lag(wage, 1) + capital, data = EmplUK, model = "random")
emp.iv4 <- plm(emp ~ wage + capital, instruments = ~ . - wage + lag(wage, 1), data = EmplUK, model = "random")
```

    Warning message in plm(emp ~ wage + capital, instruments = ~lag(wage, 1) + capital, :
    "the use of the instruments argument is deprecated, use two-part formulas instead"Warning message in plm(emp ~ wage + capital, instruments = ~. - wage + lag(wage, :
    "the use of the instruments argument is deprecated, use two-part formulas instead"


```R
summary(emp.iv1)
```


    Oneway (individual) effect Random Effect Model 
       (Swamy-Arora's transformation)
    Instrumental variable estimation
       (Balestra-Varadharajan-Krishnakumar's transformation)
    
    Call:
    plm(formula = emp ~ wage + capital | lag(wage, 1) + capital, 
        data = EmplUK, model = "random")
    
    Unbalanced Panel: n = 140, T = 6-8, N = 891
    
    Effects:
                     var std.dev share
    idiosyncratic  3.644   1.909 0.045
    individual    76.663   8.756 0.955
    theta:
       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
     0.9113  0.9113  0.9113  0.9140  0.9179  0.9231 
    
    Residuals:
        Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
    -12.1270  -0.5637  -0.2738  -0.0121   0.1559  20.8974 
    
    Coefficients:
                 Estimate Std. Error t-value  Pr(>|t|)    
    (Intercept)  9.927065   1.936903  5.1252 3.648e-07 ***
    wage        -0.216500   0.074108 -2.9214  0.003573 ** 
    capital      1.298342   0.059661 21.7620 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    
    Total Sum of Squares:    5547.8
    Residual Sum of Squares: 3453.3
    R-Squared:      0.37776
    Adj. R-Squared: 0.37636
    F-statistic: 269.3 on 2 and 888 DF, p-value: < 2.22e-16



```R
summary(emp.iv3)
```


    Oneway (individual) effect Random Effect Model 
       (Swamy-Arora's transformation)
    Instrumental variable estimation
       (Balestra-Varadharajan-Krishnakumar's transformation)
    
    Call:
    plm(formula = emp ~ wage + capital, data = EmplUK, model = "random", 
        instruments = ~lag(wage, 1) + capital)
    
    Unbalanced Panel: n = 140, T = 6-8, N = 891
    
    Effects:
                     var std.dev share
    idiosyncratic  3.644   1.909 0.045
    individual    76.663   8.756 0.955
    theta:
       Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
     0.9113  0.9113  0.9113  0.9140  0.9179  0.9231 
    
    Residuals:
        Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
    -12.1270  -0.5637  -0.2738  -0.0121   0.1559  20.8974 
    
    Coefficients:
                 Estimate Std. Error t-value  Pr(>|t|)    
    (Intercept)  9.927065   1.936903  5.1252 3.648e-07 ***
    wage        -0.216500   0.074108 -2.9214  0.003573 ** 
    capital      1.298342   0.059661 21.7620 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    
    Total Sum of Squares:    5547.8
    Residual Sum of Squares: 3453.3
    R-Squared:      0.37776
    Adj. R-Squared: 0.37636
    F-statistic: 269.3 on 2 and 888 DF, p-value: < 2.22e-16


Un buen estimador para el uso de variables instrumentales es el estimador de **Hausmann-Taylor** que usa variables instrumentales en un modelo de efectos aleatorios; asume cuatro categorías de regresores: exógena variable en el tiempo, endógena variable en el tiempo, exógena invariante en el tiempo y exógena invariante en el tiempo. Para su estimació, se puede incluir la expresión `"ht"` dentro del argumento `model` de la expresión:


```R
# Recordemos configurar los datos
Wages <- pdata.frame(Wages, index = 595) # pdata.frame puede ser usado en lugar de plm.data
# Simplificamos creando el objeto "form" que contiene la fórmula
form <- lwage ~ wks + south + smsa + married + exp + I(exp^2) + bluecol + ind + union + sex + black + ed | 
sex + black + bluecol + south + smsa + ind
ht <- plm(form, data = Wages, model = "ht")
summary(ht)
```


    Oneway (individual) effect Hausman-Taylor Model
    Call:
    pht(formula = form, data = Wages)
    
    T.V. exo  : NA, sex, black, bluecol, south, smsa, ind
    T.V. endo : wks, married, exp, I(exp^2), union, ed
    T.I. exo  : 
    T.I. endo : 
    
    Balanced Panel: n = 595, T = 7, N = 4165
    
    Effects:
                      var std.dev share
    idiosyncratic 0.02304 0.15180 0.134
    individual    0.14913 0.38618 0.866
    theta: 0.853
    
    Residuals:
         Min.   1st Qu.    Median   3rd Qu.      Max. 
    -2.070475 -0.116106  0.013176  0.125657  2.139104 
    
    Coefficients:
                   Estimate  Std. Error z-value  Pr(>|z|)    
    (Intercept)  2.7919e+00  1.8583e-01 15.0241 < 2.2e-16 ***
    wks          8.3787e-04  7.7790e-04  1.0771 0.2814400    
    southyes     2.9987e-02  3.2519e-02  0.9221 0.3564628    
    smsayes     -3.7427e-02  2.2243e-02 -1.6826 0.0924499 .  
    marriedyes  -3.0798e-02  2.4596e-02 -1.2522 0.2105119    
    exp          1.1284e-01  3.2032e-03 35.2261 < 2.2e-16 ***
    I(exp^2)    -4.2043e-04  7.0808e-05 -5.9376 2.892e-09 ***
    bluecolyes  -1.7773e-02  1.7855e-02 -0.9954 0.3195249    
    ind         -8.9816e-03  1.8608e-02 -0.4827 0.6293372    
    unionyes     3.3535e-02  1.9281e-02  1.7393 0.0819856 .  
    sexmale      1.3980e-01  7.1167e-02  1.9643 0.0494919 *  
    blackyes    -2.9270e-01  8.4004e-02 -3.4844 0.0004932 ***
    ed           1.3698e-01  1.2456e-02 10.9973 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    
    Total Sum of Squares:    886.9
    Residual Sum of Squares: 161.45
    F-statistic: 1554.72 on 12 and 4152 DF, p-value: < 2.22e-16


## Modelo de Coeficientes Variables

Según el tipo de modelo (efectos fijos o efectos aleatorios) es posible estimar un conjunto especial de parámetros donde, si se trata de un modelo de efectos fijos, se obtiene un modelo diferente para cada individuo o periodo de tiempo (según se fije este parámetro) o, si es un modelo de efectos aleatorios, se estima un modelo que emplea los resultados de un modelo previo.

Entonces se tiene:

<img src="https://github.com/karlosmantilla/panel/blob/master/dpf3.png" alt="Your image title" width="100%"/>

Donde <a href="https://www.codecogs.com/eqnedit.php?latex=\widehat{\sigma}_{i}^{2}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\widehat{\sigma}_{i}^{2}" title="\widehat{\sigma}_{i}^{2}" /></a> es un estimador insesgado de la varianza del error para el individuo _i_ obtenido de una estimación preliminar; y:

<a href="https://www.codecogs.com/eqnedit.php?latex=\inline&space;\widehat{\Delta}&space;=\frac{1}{n-1}&space;\sum_{i=1}^{n}&space;\left(&space;\widehat{\beta}_{i}&space;-&space;\frac{1}{n}&space;\sum_{i=1}^{n}&space;\widehat{\beta}_{i}&space;\right)\left(&space;\widehat{\beta}_{i}&space;-&space;\frac{1}{n}&space;\sum_{i=1}^{n}&space;\widehat{\beta}_{i}&space;\right)^{T}&space;-\frac{1}{n}&space;\sum_{i=1}^{n}&space;\widehat{\sigma}_{i}^{2}&space;\left(&space;X_{i}^{T}X_{i}\right)^{-1}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\inline&space;\widehat{\Delta}&space;=\frac{1}{n-1}&space;\sum_{i=1}^{n}&space;\left(&space;\widehat{\beta}_{i}&space;-&space;\frac{1}{n}&space;\sum_{i=1}^{n}&space;\widehat{\beta}_{i}&space;\right)\left(&space;\widehat{\beta}_{i}&space;-&space;\frac{1}{n}&space;\sum_{i=1}^{n}&space;\widehat{\beta}_{i}&space;\right)^{T}&space;-\frac{1}{n}&space;\sum_{i=1}^{n}&space;\widehat{\sigma}_{i}^{2}&space;\left(&space;X_{i}^{T}X_{i}\right)^{-1}" title="\widehat{\Delta} =\frac{1}{n-1} \sum_{i=1}^{n} \left( \widehat{\beta}_{i} - \frac{1}{n} \sum_{i=1}^{n} \widehat{\beta}_{i} \right)\left( \widehat{\beta}_{i} - \frac{1}{n} \sum_{i=1}^{n} \widehat{\beta}_{i} \right)^{T} -\frac{1}{n} \sum_{i=1}^{n} \widehat{\sigma}_{i}^{2} \left( X_{i}^{T}X_{i}\right)^{-1}" /></a>

Veamos cómo funciona esto con los datos `Grunfeld`:


```R
grun.varw <- pvcm(inv ~ value + capital, data = Grunfeld, model = "within")
grun.varr <- pvcm(inv ~ value + capital, data = Grunfeld, model = "random")
```


```R
summary(grun.varr)
```


    Oneway (individual) effect Random coefficients model
    
    Call:
    pvcm(formula = inv ~ value + capital, data = Grunfeld, model = "random")
    
    Balanced Panel: n = 10, T = 20, N = 200
    
    Residuals:
    total sum of squares: 2177914 
            id       time 
    0.67677732 0.02974195 
    
    Estimated mean of the coefficients:
                 Estimate Std. Error z-value  Pr(>|z|)    
    (Intercept) -9.629285  17.035040 -0.5653 0.5718946    
    value        0.084587   0.019956  4.2387 2.248e-05 ***
    capital      0.199418   0.052653  3.7874 0.0001522 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    
    Estimated variance of the coefficients:
                (Intercept)      value    capital
    (Intercept)  2344.24402 -0.6852340 -4.0276612
    value          -0.68523  0.0031182 -0.0011847
    capital        -4.02766 -0.0011847  0.0244824
    
    Total Sum of Squares: 474010000
    Residual Sum of Squares: 2194300
    Multiple R-Squared: 0.99537



```R
summary(grun.varw)
```


    Oneway (individual) effect No-pooling model
    
    Call:
    pvcm(formula = inv ~ value + capital, data = Grunfeld, model = "within")
    
    Balanced Panel: n = 10, T = 20, N = 200
    
    Residuals:
         Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
    -184.4884   -7.1183   -0.3926    0.0000    5.7029  144.0353 
    
    Coefficients:
      (Intercept)           value             capital        
     Min.   :-149.782   Min.   :0.004573   Min.   :0.003102  
     1st Qu.:  -9.639   1st Qu.:0.058518   1st Qu.:0.087132  
     Median :  -6.956   Median :0.082738   Median :0.137738  
     Mean   : -21.368   Mean   :0.091285   Mean   :0.205263  
     3rd Qu.:  -1.507   3rd Qu.:0.128411   3rd Qu.:0.357513  
     Max.   :  22.707   Max.   :0.174856   Max.   :0.437369  
    
    Total Sum of Squares: 474010000
    Residual Sum of Squares: 324730
    Multiple R-Squared: 0.99931



```R
summary(grun.varw)$coeff
```


<table>
<thead><tr><th scope=col>(Intercept)</th><th scope=col>value</th><th scope=col>capital</th></tr></thead>
<tbody>
	<tr><td>-149.7824533</td><td>0.119280833 </td><td>0.371444807 </td></tr>
	<tr><td> -49.1983219</td><td>0.174856015 </td><td>0.389641889 </td></tr>
	<tr><td>  -9.9563065</td><td>0.026551189 </td><td>0.151693870 </td></tr>
	<tr><td>  -6.1899605</td><td>0.077947821 </td><td>0.315718185 </td></tr>
	<tr><td>  22.7071160</td><td>0.162377704 </td><td>0.003101737 </td></tr>
	<tr><td>  -8.6855434</td><td>0.131454842 </td><td>0.085374274 </td></tr>
	<tr><td>  -4.4995344</td><td>0.087527198 </td><td>0.123781407 </td></tr>
	<tr><td>  -0.5093902</td><td>0.052894126 </td><td>0.092406492 </td></tr>
	<tr><td>  -7.7228371</td><td>0.075387943 </td><td>0.082103558 </td></tr>
	<tr><td>   0.1615186</td><td>0.004573432 </td><td>0.437369190 </td></tr>
</tbody>
</table>


