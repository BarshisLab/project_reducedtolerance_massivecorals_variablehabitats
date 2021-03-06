# Ofu Island ch1 CBASS - written by Courtney Klepac
# Physiological measurements - Total chlorophyll retention and incl. of treatment##

setwd("~/Documents/Dissertation/Writing/manuscripts/Ch1/data/chl")
library(Hmisc)
library(MASS)
library(ggplot2)
library(lme4)
library(FSA)
library(qqplotr)
library(rcompanion)
require(multcomp)
require(nlme)
require(graphics)
library(stats)
library(dplyr)
library(qqplotr)
library(cowplot)
library(car)
library(psych)
library(PerformanceAnalytics)
library(tidyverse)


#read in file
chl<-read.csv("AS_chl_edited.csv", header=T)
#set factor levels
chl$origin=factor(chl$origin,levels=unique(chl$origin))
chl$tank=factor(chl$tank,levels=unique(chl$tank))
chl$dest=factor(chl$dest,levels=unique(chl$dest))
chl$origin_dest=factor(chl$origin_dest,levels(chl$origin_dest)[c(1,4,2,5,3)])
summary(chl)
#interaction term for post hoc pairwise comparisons
chl$grtime<-interaction(chl$time,chl$origin_dest)
chl$colony=factor(chl$colony,levels=unique(chl$colony))
chl$grtrt<-interaction(chl$origin_dest,chl$trt)
chl$timetrt<-interaction(chl$time,chl$trt)
chl$colony<-paste0(chl$colony,chl$origin)
chl$ortime<-interaction(chl$time,chl$origin)
summary(chl)

####Porites####
#making two data frames for ea species
por<-chl[chl$species=='por',]
porheat<-por[por$trt=="heat",]
porcont<-por[por$trt=="cont",]
#calculate total chl retained after heat stress
porheat$chlrat<-(1-(porcont$totalchl-porheat$totalchl)/porcont$totalchl)
summary(porheat)

###chlratio###
#looking for outliers
boxplot(chlrat ~ origin + dest + time, data=porheat, las=2)
#shapiro
aggregate(chlrat ~ time + origin_dest, data=porheat, FUN=function(x) shapiro.test(x)$p.value)
#bartlett HOV
for(i in c("16-Jan","16-Jul")){
	print(paste0("time",i))
	print(bartlett.test(chlrat ~ origin_dest, data=porheat[porheat$time==i,]))
}
##check homoscedascitity by plotting residuals against fitted values
resid<-lm(chlrat~origin*dest*time, data=porheat)
plot(resid,which=1) #want random scatter; no apparent trendline
summary(resid)
qqPlot(resid,data=por,na.action=na.exclude,envelope=0.95) #try a transform if data are non-normal
plotNormalHistogram(porheat$chlrat)


###repeated measures aov -> this is the same syntax for including colony as a source of error, would replace with time if running rm
chlrat.aov<-aov(chlrat ~ time*origin*dest + Error(colony), data=porheat)
summary(chlrat.aov)
#Tukeys
#testing origin effect
model <- lme(totalchl ~ origin, random = ~ 1 | colony, porheat, na.action=na.exclude)
summary(glht(model, linfct=mcp(origin="Tukey")), test = adjusted(type = "bonferroni"))
#time*origin
model <- lme(chlrat ~ ortime, random = ~ 1 | colony, porheat, na.action=na.exclude)
summary(glht(model, linfct=mcp(ortime="Tukey")), test = adjusted(type = "bonferroni"))

#testing grouped origin_dest effect
chlrat.aov<-aov(chlrat ~ time*origin_dest + Error(colony), data=porheat)
summary(chlrat.aov)
#Tukeys
#origin_dest
model <- lme(chlrat ~ origin_dest, random = ~ 1 | colony, porheat, na.action=na.exclude)
summary(glht(model, linfct=mcp(origin_dest="Tukey")), test = adjusted(type = "bonferroni"))
#origin_dest*time
model <- lme(chlrat ~ grtime, random = ~ 1 | colony, porheat, na.action=na.exclude)
summary(glht(model, linfct=mcp(grtime="Tukey")), test = adjusted(type = "bonferroni"))


###total chl including trt effect###
boxplot(totalchl ~ origin + dest + time +trt, data=por, las=2)
#shapiro
aggregate(totalchl ~ time + origin_dest +trt, data=por, FUN=function(x) shapiro.test(x)$p.value)
#bartlett HOV
for(i in c("16-Jan","16-Jul")){
  print(paste0("time",i))
  print(bartlett.test(totalchl ~ grtrt, data=por[por$time==i,]))
}
##check homoscedascitity by plotting residuals against fitted values
resid<-lm(totalchl~origin*dest*time, data=por)
plot(resid,which=1) #want random scatter; no apparent trendline
summary(resid)
qqPlot(resid,data=por,na.action=na.exclude,envelope=0.95) #try a transform if data are non-normal
plotNormalHistogram(por$totalchl)

#aov
totchl.aov<-aov(totalchl ~ time*origin*dest*trt + Error(tank), data=por)
summary(totchl.aov)
#Tukeys
#origin
model <- lme(totalchl ~ origin, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(origin="Tukey")), test = adjusted(type = "bonferroni"))
#testing time effect
model <- lme(totalchl ~ time, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(time="Tukey")), test = adjusted(type = "bonferroni"))
#testing trt effect
model <- lme(totalchl ~ trt, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(trt="Tukey")), test = adjusted(type = "bonferroni"))
#testing dest effect
model <- lme(totalchl ~ dest, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(dest="Tukey")), test = adjusted(type = "bonferroni"))

#testing grouped origin_dest effect
totchl.aov<-aov(totalchl ~ time*origin_dest*trt + Error(colony), data=por)
summary(totchl.aov)
#grtime
model <- lme(totalchl ~ grtime, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(grtime="Tukey")), test = adjusted(type = "bonferroni"))
model <- lme(totalchl ~ timetrt, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(timetrt="Tukey")), test = adjusted(type = "bonferroni"))
#dest
model <- lme(totalchl ~ origin_dest, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(origin_dest="Tukey")), test = adjusted(type = "bonferroni"))
model <- lme(totalchl ~ time, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(time="Tukey")), test = adjusted(type = "bonferroni"))
#grtime
model <- lme(totalchl ~ all, random = ~ 1 | colony, por, na.action=na.exclude)
summary(glht(model, linfct=mcp(all="Tukey")), test = adjusted(type = "bonferroni"))

####Goniastrea####
gon<-chl[chl$species=='gon',]
gonheat<-gon[gon$trt=="heat",]
goncont<-gon[gon$trt=="cont",]
#calculate total chl retained
gonheat$chlrat<-(1-(goncont$totalchl-gonheat$totalchl)/goncont$totalchl)
head(gonheat)

#looking for outliers
boxplot(chlrat ~ origin + dest + time, data=gonheat, las=2)
#shapiro
aggregate(chlrat ~ time + origin_dest, data=gonheat, FUN=function(x) shapiro.test(x)$p.value)
#bartlett HOV
for(i in c("16-Jan","16-Jul")){
  print(paste0("time",i))
  print(bartlett.test(chlrat ~ origin_dest, data=gonheat[gonheat$time==i,]))
}
##check homoscedascitity by plotting residuals against fitted values
resid<-lm(chlrat~origin*dest*time, data=gonheat)
plot(resid,which=1) #want random scatter; no apparent trendline
summary(resid)
qqPlot(resid,data=gonheat,na.action=na.exclude,envelope=0.95) #try a transform if data are non-normal
plotNormalHistogram(gonheat$chlrat)

###repeated measures aov 
###FIRST KEEP ORI AND DEST SEPARATE###
chlrat.aov<-aov(chlrat ~ time*origin*dest + Error(colony), data=gonheat)
summary(chlrat.aov)

#grouped origin_dest
chlrat.aov<-aov(chlrat ~ time*origin_dest + Error(colony), data=gonheat)
summary(chlrat.aov)
#Tukeys
#time 
model <- lme(chlrat ~ time, random = ~ 1 | colony, gonheat, na.action=na.exclude)
summary(glht(model, linfct=mcp(time="Tukey")), test = adjusted(type = "bonferroni"))
#origin_dest*time
##To generate a priori contrasts in an unbalanced random mixed model
miss1_mod<-lmer(chlrat ~ time_origin_dest_trt  + (1 | colony), gonheat, na.action=na.exclude)
anova(miss1_mod)
summary(glht(miss1_mod,linfct=mcp(time_origin_dest_trt ="Tukey")), test = adjusted(type = "bonferroni"))


###total chl###
boxplot(totalchl ~ origin + dest + time +trt, data=gon, las=2)
#shapiro
aggregate(totalchl ~ time + origin_dest +trt, data=gon, FUN=function(x) shapiro.test(x)$p.value)
#bartlett HOV
for(i in c("16-Jan","16-Jul")){
  print(paste0("time",i))
  print(bartlett.test(totalchl ~ grtrt, data=gon[gon$time==i,]))
}
##check homoscedascitity by plotting residuals against fitted values
resid<-lm(totalchl~origin*dest*time, data=gon)
plot(resid,which=1) #want random scatter; no apparent trendline
summary(resid)
qqPlot(resid,data=gon,na.action=na.exclude,envelope=0.95) #try a transform if data are non-normal
plotNormalHistogram(gon$totalchl)

#repeated measures aov with grouped origin_dest
totchl.aov<-aov(totalchl ~ time*origin_dest*trt + Error(colony), data=gon)
summary(totchl.aov)
#Tukeys
#time 
model <- lme(totalchl ~ time, random = ~ 1 | colony, gon, na.action=na.exclude)
summary(glht(model, linfct=mcp(time="Tukey")), test = adjusted(type = "bonferroni"))
#time*trt
model <- lme(totalchl ~ timetrt, random = ~ 1 | colony, gon, na.action=na.exclude)
summary(glht(model, linfct=mcp(timetrt="Tukey")), test = adjusted(type = "bonferroni"))
#grouped
model <- lme(totalchl ~ all, random = ~ 1 | colony, gon, na.action=na.exclude)
summary(glht(model, linfct=mcp(all="Tukey")), test = adjusted(type = "bonferroni"))
#trt
model <- lme(totalchl ~ trt, random = ~ 1 | colony, gon, na.action=na.exclude)
summary(glht(model, linfct=mcp(trt="Tukey")), test = adjusted(type = "bonferroni"))

##To generate a priori contrasts in an unbalanced random mixed model
miss1_mod<-lmer(totalchl ~ time_origin_dest_trt  + (1 | colony), gon, na.action=na.exclude)
anova(miss1_mod)
summary(glht(miss1_mod,linfct=mcp(time_origin_dest_trt="Tukey")), test = adjusted(type = "bonferroni"))

###total chl with heat treated samples only###
summary(gonheat)
#shapiro
aggregate(totalchl ~ time + origin + dest, data=gonheat, FUN=function(x) shapiro.test(x)$p.value)
#bartletts HOV
for(i in c("Jan-16","Jul-16")){
	print(paste0("time",i))
	print(bartlett.test(totalchl ~ origin_dest, data=gonheat[gonheat$time==i,]))
}

#aov of grouped origin_dest
totchl.aov<-aov(totalchl ~ time*origin_dest + Error(colony), data=gonheat)
summary(totchl.aov)
#time 
model <- lme(chl ~ time, random = ~ 1 | colony, gonheat, na.action=na.exclude)
summary(glht(model, linfct=mcp(time="Tukey")), test = adjusted(type = "bonferroni"))
#origin_dest*time
model <- lme(totalchl ~ grtime, random = ~ 1 | colony, gonheat, na.action=na.exclude)
summary(glht(model, linfct=mcp(grtime="Tukey")), test = adjusted(type = "bonferroni"))


##############plotting################## 
#Interaction plot using ggplot
#POR#
sum=Summarize(chlrat~grtrt+time, data=porheat, digits=3)
sum$se = sum$sd / sqrt(sum$n)
sum$se = signif(sum$se, digits=3)
sum$Origin<-factor(c("HV","MV","LV","MV","LV","HV","MV","LV","MV","LV","HV","MV","LV","MV","LV","HV","MV","LV","MV","LV"))
sum$dest<-factor(c("HV","HV","HV","MV","LV","HV","HV","HV","MV","LV","HV","HV","HV","MV","LV","HV","HV","HV","MV","LV"))
sum$Origin=factor(sum$Origin,levels=unique(sum$Origin))
sum$dest=factor(sum$dest,levels=unique(sum$dest))
sum$time=factor(sum$time,levels=unique(sum$time))
sum$trt=factor(c("cont","cont","cont","cont","cont","heat","heat","heat","heat","heat","cont","cont","cont","cont","cont","heat","heat","heat","heat","heat"))
sum$trt=factor(sum$trt,levels=unique(sum$trt))
sum


#poster figure
pd=position_dodge(.75)
plot.chl<-ggplot(sum,aes(x=dest,y=mean,color=trt)) + 
  geom_point(aes(shape=Origin),size=4,position=pd) + 
  geom_errorbar(aes(ymin=mean - se,ymax=mean + se), width=.2,position=pd) + 
  facet_wrap(~time) +
  theme_bw() + 																		
  theme(plot.margin=margin(0.5,0.5,0.5,0.5,'cm'), panel.grid.minor=element_blank()) + 
  scale_color_manual(values = c('gray','black'), name = "Treatment") +
  coord_cartesian(xlim=c(0.5,3.25), ylim=c(0,14), expand=F) + 
  ylab("Total Chlorophyll (pg cm-2)\n after Acute Heat Stress") + 
  xlab("Transplant Site")
save_plot("20200209_por_chlse.pdf", plot.chl,
          base_aspect_ratio = 1.3)


#GON#
sum=Summarize(totalchl~grtrt+time, data=gon, digits=3)
sum$se = sum$sd / sqrt(sum$n)
sum$se = signif(sum$se, digits=3)
sum$Origin<-factor(c("HV","MV","LV","MV","HV","MV","LV","MV","HV","MV","LV","MV","LV","HV","MV","LV","MV","LV"))
sum$dest<-factor(c("HV","HV","HV","MV","HV","HV","HV","MV","HV","HV","HV","MV","LV","HV","HV","HV","MV","LV"))
sum$Origin=factor(sum$Origin,levels=unique(sum$Origin))
sum$dest=factor(sum$dest,levels=unique(sum$dest))
sum$time=factor(sum$time,levels=unique(sum$time))
sum$trt=factor(c("cont","cont","cont","cont","heat","heat","heat","heat","cont","cont","cont","cont","cont","heat","heat","heat","heat","heat"))
sum$trt=factor(sum$trt,levels=unique(sum$trt))
sum

plot.chl<-ggplot(sum,aes(x=dest,y=mean,fill=Origin,color=trt)) + 
  geom_point(aes(shape=Origin),size=3,position=pd) + 
  geom_errorbar(aes(ymin=mean - se,ymax=mean + se), width=.2,position=pd) + 
  facet_wrap(~time) +
  theme_bw() + 																		
  theme(plot.margin=margin(0.5,0.5,0.5,0.5,'cm'), panel.grid.minor=element_blank()) + 
  scale_color_manual(values = c('gray','black'), name = "Treatment") +
  coord_cartesian(xlim=c(0.5,3.4), ylim=c(0,9), expand=F) + 
  ylab("Total Chlorophyll (pg cm-2)\n after Acute Heat Stress") + 
  xlab("Transplant Site")
save_plot("20200209_gon_chlse.pdf", plot.chl,
          base_aspect_ratio = 1.3)
