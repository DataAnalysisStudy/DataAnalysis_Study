
a <- read.table("P052.txt",header = T)
a
cov(a)
cor(a)


a_inches <- data.frame("Husband_inch" = a$Husband*2.54, "Wife_inch"=a$Wife*2.54) 
a_inches
cov(a)
cov(a_inches)
cor(a)
cor(a_inches)
cov(a_inches) / cov(a)

a_5cent <- data.frame("Husband_5" = a$Husband, "Wife_5" = a$Husband -5)
a_5cent

cor(a)
cor(a_5cent)

fit_H <- lm(Husband ~ Wife, data = a)
summary(fit_H)
fit_W <- lm(Wife ~ Husband, data = a)
summary(fit_W)


