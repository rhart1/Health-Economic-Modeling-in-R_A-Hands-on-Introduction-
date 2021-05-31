#################
# Decision Tree #
#################

# Firstly, let's define the number of treatments we are looking at and their names
n.treatments<-2
t.names<-c("Drug A","Drug B")

# We want to look at the costs, QALYS and probabilities for health states.

# First create some blanks to fill in
c.successful<-c.unsuccessful<-rep(NA,n.treatments)
q.successful<-q.unsuccessful<-rep(NA,n.treatments)
p.successful<-p.unsuccessful<-rep(NA,n.treatments)

# And we can name the vectors to correspond to Drug A and Drug B to keep us calculating correctly
names(c.successful)<-names(c.unsuccessful)<-names(q.successful)<-
  names(q.unsuccessful)<-names(p.successful)<-names(p.unsuccessful)<-t.names


# Now let's start with adding the cost information 

# Cost of treatment 
c.treat<-c(2000,150)

# Cost inputs for each treatment over lifetime horizon
c.successful[1]<-10000
c.unsuccessful[1]<-20000 
c.successful[2]<-5000
c.unsuccessful[2]<-10000

# Let's add in the QALY information 

# QALY inputs for each treatment over lifetime horizon
q.successful[1]<-30
q.unsuccessful[1]<-15
q.successful[2]<-25
q.unsuccessful[2]<-23

# Check and see how the costs and qalys are looking
c.successful
c.unsuccessful
q.successful
q.unsuccessful


# Let's add in the probabilities 

# Probabilities of successful and unsuccessful on new treatment
p.successful[1]<-0.7
p.unsuccessful[1]<-1-(p.successful[1])

# Probabilities of successful and unsuccessful on old treatment
p.successful[2]<-0.95
p.unsuccessful[2]<-1-(p.successful[2])

# Again let's check
p.successful
p.unsuccessful



# Again create some blank cells to fill in for the calculations of costs and QALYs
incremental.costs<-incremental.QALYs<-costs<-QALYs<-rep(NA,n.treatments)

# And we can name the vectors so we again have Drug A and Drug B the right way around
incremental.costs<-incremental.QALYs<-names(costs)<-names(QALYs)<-t.names


# Calculate the total costs and effects so we can calculate the ICER
costs<-c.treat+p.successful*c.successful+p.unsuccessful*c.unsuccessful

QALYs<-p.successful*q.successful+p.unsuccessful*q.unsuccessful

# Do these look right?
costs
QALYs


# Calculate the incremental costs and QALYs
# We use [2] as we are using the old drug as the reference, and want to see the incremental cost per QALY of the new drug
incremental.costs<-costs[1]-costs[2]
incremental.QALYs<-QALYs[1]-QALYs[2]


# Calculate the incremental cost effectiveness ratio
ICER<-incremental.costs/incremental.QALYs

ICER


# Display this in a plot

plot(x = incremental.QALYs, y = incremental.costs,
     
     xlim = c(0,1), ylim = c(0,12000),
     
     pch = 16, cex = 1.5,
     
     xlab = "QALY differential", ylab = "Cost differential (£)")

abline(a = 0, b = 20000)



#################
#  Uncertainty  #
#################

# Firstly let's define the number of simulations to run
n.PSA=1000

# Let's create bigger space for 1000 simulations for different probabilities
p.successful<-p.unsuccessful<-matrix(nrow=n.PSA, ncol=n.treatments)

# Let's calculate the costs and QALYs for each simulation - overwrite the existing information
incremental.costs<-incremental.QALYs<-costs<-QALYs<-matrix(nrow=n.PSA,ncol=n.treatments)
colnames(incremental.costs)<-colnames(incremental.QALYs)<-colnames(p.successful)<-colnames(p.unsuccessful)<-colnames(QALYs)<-colnames(costs)<-t.names


# Probabilities Drug A
p.unsuccessful[,1]<-rbeta(n=n.PSA, shape1=9, shape2=21)
p.successful[,1]<-1-p.unsuccessful[,1]

# Probabilities  Drug B
p.unsuccessful[,2]<-rbeta(n=n.PSA, shape1=2, shape2=40)
p.successful[,2]<-1-p.unsuccessful[,2]

# Is what we have done reasonable?
range(p.successful[,1])
mean(p.successful[,1])

range(p.successful[,2])
mean(p.successful[,2])

# Let's have a look at these on a histogram
hist(p.successful[,1], breaks=20, xlab="Probability of Drug A being successful",main="Histogram")
hist(p.successful[,2], breaks=20, xlab="Probability of Drug B being successful",main="Histogram")


# There are nicer ways to make graphs
library(ggplot2)

# To plot the density function, ggplot likes things as a data frame
data<-as.data.frame(p.successful)

# Look at the different shapes and the x axis values for the types of distributions
ggplot(data, aes(x = p.successful[,1])) +
  geom_density()



# Total cost and effects 
costs[,1]<-c.treat[1]+(p.successful[,1]*c.successful[1])+(p.unsuccessful[,1]*c.unsuccessful[1])
QALYs[,1]<-(p.successful[,1]*q.successful[1])+(p.unsuccessful[,1]*q.unsuccessful[1])

costs[,2]<-c.treat[2]+(p.successful[,2]*c.successful[2])+(p.unsuccessful[,2]*c.unsuccessful[2])
QALYs[,2]<-(p.successful[,2]*q.successful[2])+(p.unsuccessful[,2]*q.unsuccessful[2])

# Does this look reasonable?
head(costs)
head(QALYs)

# Incremental outcomes
incremental.costs<-costs[,1]-costs[,2]
incremental.QALYs<-QALYs[,1]-QALYs[,2]

# Overall summary
# Average costs and effects
colMeans(costs)
colMeans(QALYs)

