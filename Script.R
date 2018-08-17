R> library("plm")
R> library("Ecdat")

R> data("EmplUK", package = "plm")
R> data("Produc", package = "Ecdat")
R> data("Grunfeld", package = "Ecdat")
R> data("Wages", package = "Ecdat")

R> Wages <- plm.data(Wages, index = 595)
EmplUK <- plm.data(EmplUK, index = c("firm", "year"))

R> log(emp) ~ lag(log(emp), 1) + lag(log(emp), 2) + lag(log(wage), 2) + lag(log(wage), 3) + diff(capital, 2) + diff(capital, 3)
R> dynformula(emp ~ wage + capital, log = list(capital = FALSE, TRUE), lag = list(emp = 2, c(2, 3)), diff = list(FALSE, capital = TRUE))

R> grun.fe <- plm(inv ~ value + capital, data = Grunfeld, model = "within")
R> grun.re <- plm(inv ~ value + capital, data = Grunfeld, model = "random")
R> summary(grun.re)

R> fixef(grun.fe)
R> summary(fixef(grun.fe))
R> grun.twfe <- plm(inv ~ value + capital, data = Grunfeld, model = "within", effect = "twoways")
R> fixef(grun.twfe, effect = "time")

R> emp.amem <- plm(log(emp) ~ log(wage) + log(capital), data = EmplUK, model = "random", random.method = "amemiya")

R> grun.tways <- plm(inv ~ value + capital, data = Grunfeld, effect = "twoways", model = "random", random.method = "amemiya")
R> summary(grun.tways)

R> emp.iv <- plm(emp ~ wage + capital | lag(wage, 1) + capital, data = EmplUK, model = "random")
R> emp.iv <- plm(emp ~ wage + capital | . - wage + lag(wage, 1), data = EmplUK, model = "random")
R> emp.iv <- plm(emp ~ wage + capital, instruments = ~lag(wage, 1) + capital, data = EmplUK, model = "random")
R> emp.iv <- plm(emp ~ wage + capital, instruments = ~ . - wage + lag(wage, 1), data = EmplUK, model = "random")
R> form <- lwage ~ wks + south + smsa + married + exp + I(exp^2) + bluecol + ind + union + sex + black + ed | sex + black + bluecol + south + smsa + ind
R> ht <- plm(form, data = Wages, model = "ht")
R> summary(ht)

R> grun.varw <- pvcm(inv ~ value + capital, data = Grunfeld, model = "within")
R> grun.varr <- pvcm(inv ~ value + capital, data = Grunfeld, model = "random")
R> summary(grun.varr)

## Métodos de Momentos
R> emp.gmm <- pgmm(dynformula(emp ~ wage + capital + output, lag = list(2, 1, 0, 1), log = TRUE), EmplUK, effect = "twoways", model = "twosteps", gmm.inst = ~log(emp), lag.gmm = list(c(2, 99)))
R> summary(emp.gmm)

R> zz <- pggls(log(emp) ~ log(wage) + log(capital), data = EmplUK, model = "random")
R> summary(zz)
R> zz <- pggls(log(emp) ~ log(wage) + log(capital), data = EmplUK, model = "within")

## Test
R> znp = pvcm(inv ~ value + capital, data = Grunfeld, model = "within")
R> zplm = plm(inv ~ value + capital, data = Grunfeld)
R> pooltest(zplm, znp)
R> pooltest(inv ~ value + capital, data = Grunfeld, model = "within")

R> g <- plm(inv ~ value + capital, data = Grunfeld, model = "pooling")
R> plmtest(g, effect = "twoways", type = "ghm")

R> plmtest(inv ~ value + capital, data = Grunfeld, effect = "twoways", type = "ghm")


R> gw <- plm(inv ~ value + capital, data = Grunfeld, effect = "twoways", model = "within")
R> gp <- plm(inv ~ value + capital, data = Grunfeld, model = "pooling")
R> pFtest(gw, gp)

R> pFtest(inv ~ value + capital, data = Grunfeld, effect = "twoways")

R> gw <- plm(inv ~ value + capital, data = Grunfeld, model = "within")
R> gr <- plm(inv ~ value + capital, data = Grunfeld, model = "random")
R> phtest(gw, gr)

R> pwtest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc)
R> pbsytest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc, test = "J")
R> pbsytest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc)
R> pbsytest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc, test = "RE")
R> pbltest(log(gsp) ~ log(pcap) + log(pc) + log(emp) + unemp, data = Produc, alternative = "onesided")
R> grun.fe <- plm(inv ~ value + capital, data = Grunfeld, model = "within")
R> pbgtest(grun.fe, order = 2)

R> pwartest(log(emp) ~ log(wage) + log(capital), data = EmplUK)
R> pwfdtest(log(emp) ~ log(wage) + log(capital), data = EmplUK, h0 = "fe")
R> pcdtest(inv ~ value + capital, data = Grunfeld)
R> pcdtest(inv ~ value + capital, data = Grunfeld, model = "within")

R> library("lmtest")
R> re <- plm(inv ~ value + capital, data = Grunfeld, model = "random")
R> coeftest(re, vcov = pvcovHC)

R> coeftest(re, vcov = pvcovHC(re, method = "white2", type = "HC3"))
R> waldtest(re, update(re, . ~ . - capital), vcov = function(x) pvcovHC(x, method = "white2", type = "HC3"))

R> library("car")
R> linear.hypothesis(re, "2 * value = capital", vcov = pvcovHC)


