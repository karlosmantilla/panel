
# Modelo de Efectos Mixtos ¿una alternativa para datos de panel?
## Modelos Mixtos Generalizados Usando R

Hasta el momento, se han visto algunas alternativas para identificar, por separado, los efectos fijos y los efectos aleatorios dentro de un conjunto de datos de panel haciendo uso de las alternativas proporcionadas por R para la estimación de los modelos.

En general, el modelo de la forma:

\begin{equation}
Y_{it} = \beta_{0} + \beta_{1}X_{it} + \beta_{2}K_{it} + e_{it}
\end{equation}

Donde, descomponiento el término $e_{it} = C_{i} + D_{t} + \varepsilon_{it}$ es posible identificar los efectos aleatorios.

Si se observa con detalle, se tiene que el modelo lineal arriba enunciado es descrito por una de un vector de valores aleatorios para la variable respuesta $\mathcal{Y}$ cuyo valor es $y_{obs} \equiv y_{i}$. Algo similar ocurre con un modelo mixto, el cual es descrito por la distribución de dos vectores de variables aleatorias: $\mathcal{Y}$, la respuesta, y $\mathcal{B}$, el vector de efectos aleatorios. Entonces, se tiene una distribución normal multivariada:

\begin{equation}
\mathcal{Y} \sim \mathcal{N} \left( \boldsymbol{X \beta} + \boldsymbol{o}, \sigma^{2} \boldsymbol{W}^{-1} \right)
\end{equation}

donde $n$ es la longitud del vector respuesta $\mathcal{Y}$; $\boldsymbol{W}$ es una matriz diagonal de pesos (conocidos previamente); $\boldsymbol{\beta}$ es un vector de coeficientes de dimensión $p$; $\boldsymbol{X}$ es una matriz de dimensión $n \times p$ y $\boldsymbol{o}$ es un vector de compensación (de términos conocidos apriori) . Así, los parámetros son los coeficientes $\beta$ y  el parámetro de escala $\sigma$.

En un modelo lineal mixto, la distribución de $\mathcal{Y}$ está condicionada a $\mathcal{B} = \boldsymbol{b}$, tal que se tiene la forma:

\begin{equation}
(\mathcal{Y}|\mathcal{B} = \boldsymbol{b}) \sim \mathcal{N} \left( \boldsymbol{X \beta} + \boldsymbol{Zb} + \boldsymbol{o}, \sigma^{2} \boldsymbol{W}^{-1} \right)
\end{equation}

Donde $\boldsymbol{Z}$ es una matriz $n \times q$ para el vector de valores de la variable de efectos aleatorios de dimensión *q*. La distribución incodicional de $\mathcal{B}$ también es normar multivariada con media cero y una mtriz de varianzas y covarianzas $\mathcal{\Sigma}$.

\begin{equation}
\mathcal{B} \sim \mathcal{N} ( \boldsymbol{0}, \boldsymbol{\Sigma})
\end{equation}

Con lo anterior, es necesario identificar de manera adecuada a qué se le va a asignar la función de aportar efectos aleatorios. Para entenderlo veamos un ejemplo; utilizaremos los datos proporcionados por el software provenientes del paquete `Ecdat` llamados `Grunfeld`:


```R
library("plm")
library("Ecdat")
library("lme4")
library("nlme")

data("Grunfeld", package = "Ecdat")
```

Primero, comparemos el modelo de efectos aleatorios:


```R
reGLS <- plm(inv ~ value + capital, data = Grunfeld, model = "random")
reML <- lme(inv ~ value + capital, data = Grunfeld, random = ~1 | firm)
```


```R
summary(reGLS)
```


    Oneway (individual) effect Random Effect Model 
       (Swamy-Arora's transformation)
    
    Call:
    plm(formula = inv ~ value + capital, data = Grunfeld, model = "random")
    
    Balanced Panel: n = 10, T = 20, N = 200
    
    Effects:
                      var std.dev share
    idiosyncratic 2784.46   52.77 0.282
    individual    7089.80   84.20 0.718
    theta: 0.8612
    
    Residuals:
         Min.   1st Qu.    Median   3rd Qu.      Max. 
    -177.6063  -19.7350    4.6851   19.5105  252.8743 
    
    Coefficients:
                  Estimate Std. Error t-value Pr(>|t|)    
    (Intercept) -57.834415  28.898935 -2.0013  0.04674 *  
    value         0.109781   0.010493 10.4627  < 2e-16 ***
    capital       0.308113   0.017180 17.9339  < 2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    
    Total Sum of Squares:    2381400
    Residual Sum of Squares: 548900
    R-Squared:      0.7695
    Adj. R-Squared: 0.76716
    F-statistic: 328.837 on 2 and 197 DF, p-value: < 2.22e-16



```R
summary(reML)
```


    Linear mixed-effects model fit by REML
     Data: Grunfeld 
           AIC      BIC    logLik
      2205.851 2222.267 -1097.926
    
    Random effects:
     Formula: ~1 | firm
            (Intercept) Residual
    StdDev:    85.83119 52.73922
    
    Fixed effects: inv ~ value + capital 
                    Value Std.Error  DF   t-value p-value
    (Intercept) -57.86442 29.377757 188 -1.969668  0.0503
    value         0.10979  0.010527 188 10.429581  0.0000
    capital       0.30819  0.017171 188 17.947893  0.0000
     Correlation: 
            (Intr) value 
    value   -0.328       
    capital -0.019 -0.368
    
    Standardized Within-Group Residuals:
            Min          Q1         Med          Q3         Max 
    -3.43192891 -0.34984287  0.02104578  0.35919156  4.81447454 
    
    Number of Observations: 200
    Number of Groups: 10 


Tenemos dos modelos que son muy similares que nos muestran la afectación de largo plazo. Lógicamente, es posible realizar la comparación con los distintos tipos de modelos (véase: Croissant Y, Millo G (2008). “Panel Data Econometrics in R: The plm
Package.” _Journal of Statistical Software_, 27(2), 1-43. doi:10.18637/jss.v027.i02).

Veamos que pasa con el modelo mixto como tal:


```R
Grunfeld$Ffirm<-factor(Grunfeld$firm)
grun.ref<-lmer(data=Grunfeld,inv~value + capital +  Ffirm + (1|year)-1)
summary(grun.ref)
```

    Warning message:
    "Some predictor variables are on very different scales: consider rescaling"


    Linear mixed model fit by REML ['lmerMod']
    Formula: inv ~ value + capital + Ffirm + (1 | year) - 1
       Data: Grunfeld
    
    REML criterion at convergence: 2087.5
    
    Scaled residuals: 
        Min      1Q  Median      3Q     Max 
    -3.4435 -0.3151  0.0134  0.3373  4.7351 
    
    Random effects:
     Groups   Name        Variance Std.Dev.
     year     (Intercept)   42.37   6.51   
     Residual             2744.09  52.38   
    Number of obs: 200, groups:  year, 20
    
    Fixed effects:
              Estimate Std. Error t value
    value      0.11073    0.01200   9.227
    capital    0.31359    0.01774  17.672
    Ffirm1   -75.22467   50.35138  -1.494
    Ffirm2    99.66429   25.20568   3.954
    Ffirm3  -238.16571   24.70798  -9.639
    Ffirm4   -28.65927   14.14059  -2.027
    Ffirm5  -116.47271   14.28105  -8.156
    Ffirm6   -23.78478   12.69876  -1.873
    Ffirm7   -67.75428   12.89873  -5.253
    Ffirm8   -58.25661   14.05108  -4.146
    Ffirm9   -88.47520   12.94939  -6.832
    Ffirm10   -6.63204   11.83185  -0.561
    
    Correlation of Fixed Effects:
            value  capitl Ffirm1 Ffirm2 Ffirm3 Ffirm4 Ffirm5 Ffirm6 Ffirm7 Ffirm8
    capital -0.369                                                               
    Ffirm1  -0.949  0.152                                                        
    Ffirm2  -0.862  0.139  0.861                                                 
    Ffirm3  -0.837  0.060  0.852  0.777                                          
    Ffirm4  -0.532  0.065  0.538  0.492  0.489                                   
    Ffirm5   0.029 -0.533  0.095  0.090  0.132  0.075                            
    Ffirm6  -0.343  0.001  0.358  0.329  0.330  0.214  0.078                     
    Ffirm7   0.020 -0.382  0.069  0.067  0.097  0.058  0.238  0.060              
    Ffirm8  -0.533  0.103  0.530  0.485  0.479  0.309  0.052  0.208  0.041       
    Ffirm9  -0.159 -0.294  0.234  0.216  0.241  0.150  0.220  0.119  0.162  0.134
    Ffirm10 -0.069  0.018  0.070  0.068  0.067  0.050  0.015  0.039  0.016  0.050
            Ffirm9
    capital       
    Ffirm1        
    Ffirm2        
    Ffirm3        
    Ffirm4        
    Ffirm5        
    Ffirm6        
    Ffirm7        
    Ffirm8        
    Ffirm9        
    Ffirm10  0.028
    fit warnings:
    Some predictor variables are on very different scales: consider rescaling



```R
confint(grun.ref)
```

    Computing profile confidence intervals ...
    Warning message in optwrap(optimizer, par = start, fn = function(x) dd(mkpar(npar1, :
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = start, fn = function(x) dd(mkpar(npar1, :
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"Warning message in optwrap(optimizer, par = thopt, fn = mkdevfun(rho, 0L), lower = fitted@lower):
    "convergence code 3 from bobyqa: bobyqa -- a trust region step failed to reduce q"


<table>
<thead><tr><th></th><th scope=col>2.5 %</th><th scope=col>97.5 %</th></tr></thead>
<tbody>
	<tr><th scope=row>.sig01</th><td>   0.00000000</td><td>  19.8103232 </td></tr>
	<tr><th scope=row>.sigma</th><td>  45.95317451</td><td>  56.5678002 </td></tr>
	<tr><th scope=row>value</th><td>   0.08763995</td><td>   0.1338677 </td></tr>
	<tr><th scope=row>capital</th><td>   0.27719668</td><td>   0.3531610 </td></tr>
	<tr><th scope=row>Ffirm1</th><td>-164.51063957</td><td>  23.8608625 </td></tr>
	<tr><th scope=row>Ffirm2</th><td>  54.64274459</td><td> 149.1451007 </td></tr>
	<tr><th scope=row>Ffirm3</th><td>-281.89266395</td><td>-189.2935928 </td></tr>
	<tr><th scope=row>Ffirm4</th><td> -54.51209576</td><td>  -1.1445515 </td></tr>
	<tr><th scope=row>Ffirm5</th><td>-141.47396393</td><td> -87.7859228 </td></tr>
	<tr><th scope=row>Ffirm6</th><td> -47.16440665</td><td>   0.8379399 </td></tr>
	<tr><th scope=row>Ffirm7</th><td> -90.89414638</td><td> -42.2258450 </td></tr>
	<tr><th scope=row>Ffirm8</th><td> -84.05832910</td><td> -31.0375587 </td></tr>
	<tr><th scope=row>Ffirm9</th><td>-111.65644193</td><td> -62.8021159 </td></tr>
	<tr><th scope=row>Ffirm10</th><td> -28.97194097</td><td>  15.8383470 </td></tr>
</tbody>
</table>




```R
grun.ref.coef<-as.data.frame(coef(grun.ref)[[1]])
grun.ref.coef
```


<table>
<thead><tr><th></th><th scope=col>(Intercept)</th><th scope=col>value</th><th scope=col>capital</th><th scope=col>Ffirm1</th><th scope=col>Ffirm2</th><th scope=col>Ffirm3</th><th scope=col>Ffirm4</th><th scope=col>Ffirm5</th><th scope=col>Ffirm6</th><th scope=col>Ffirm7</th><th scope=col>Ffirm8</th><th scope=col>Ffirm9</th><th scope=col>Ffirm10</th></tr></thead>
<tbody>
	<tr><th scope=row>1935</th><td> 4.71407453</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1936</th><td> 2.56416775</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1937</th><td> 0.11394898</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1938</th><td> 0.05454618</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1939</th><td>-3.67765647</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1940</th><td>-0.23239016</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1941</th><td> 3.23310891</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1942</th><td> 2.88734563</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1943</th><td> 0.13105530</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1944</th><td> 0.13565668</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1945</th><td>-1.39977528</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1946</th><td> 2.02458398</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1947</th><td> 1.10638095</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1948</th><td> 0.74326441</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1949</th><td>-3.01123699</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1950</th><td>-3.15732700</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1951</th><td>-1.01601127</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1952</th><td>-0.91014290</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1953</th><td>-0.64477374</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
	<tr><th scope=row>1954</th><td>-3.65881948</td><td>0.1107338  </td><td>0.313588   </td><td>-75.22467  </td><td>99.66429   </td><td>-238.1657  </td><td>-28.65927  </td><td>-116.4727  </td><td>-23.78478  </td><td>-67.75428  </td><td>-58.25661  </td><td>-88.4752   </td><td>-6.632037  </td></tr>
</tbody>
</table>


