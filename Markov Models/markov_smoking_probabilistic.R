# Smoking Cessation Markov model - probabilistic analysis
# Howard Thom 2024

# Load necessary libraries
# If not installed use the following line first
# install.packages("BCEA")
library(BCEA)

# Set a random number seed so results are reproducible
set.seed(1002435)


# Define the number and names of treatments
# These are Standard of Care with website
# and Standard of Care without website
n_treatments <- 2
treatment_names <- c("SoC with website", "SoC")

# Define the number and names of states of the model
# This is two and they are "Smoking" and "Not smoking"
n_states <- 2
state_names <- c("Smoking", "Not smoking")

# Define the number of cycles
# This is 10 as the time horizon is 5 years and cycle length is 6 months
# The code will work for any even n_cycles (need to change the discounting code if
# an odd number of cycles is desired)
n_cycles <- 10

# Define simulation parameters
# This is the number of  samples to use
n_samples <- 1000

#############################################################################
## Input parameters #########################################################
#############################################################################

# The transition matrix is a 2x2 matrix
# Rows sum to 1
# Top left entry is transition probability from smoking to smoking
# Top right is transition probability from smoking to not smoking
# Bottom left is transition probability from not smoking to smoking
# Bottom right is transition probability from not smoking to not smoking

# There is one transition matrix for each treatment option and each  sample
# Store them in an array with (before filling in below) NA entries
transition_matrices <- array(dim = c(n_treatments, n_samples, n_states, n_states), 
                             dimnames = list(treatment_names, NULL, state_names, state_names))

# First the transition matrix for Standard of Care with website
# Transitions from smoking 
temp <- rbeta(n_samples, 85, 15)
transition_matrices["SoC with website", , "Smoking", ] <- matrix(c(temp, 1 - temp), ncol = 2)
# Transitions from not smoking
temp <- rbeta(n_samples, 8, 92)
transition_matrices["SoC with website", , "Not smoking", ] <- matrix(c(temp, 1 - temp), ncol = 2)

# Second the transition matrix for Standard of Care
# Transitions from smoking 
temp <- rbeta(n_samples, 88, 12)
transition_matrices["SoC", , "Smoking", ] <- matrix(c(temp, 1 - temp), ncol = 2)
# Transitions from not smoking
# These should be the same as the transition probabilities from not smoking for SoC with website
# as the website has no impact on probability of relapse
transition_matrices["SoC", , "Not smoking", ] <- transition_matrices["SoC with website", , "Not smoking", ]


# Now define the QALYS associated with the states per cycle
# There is one for each  sample and each state
# Store in an NA array and then fill in below
state_qalys <- array(dim = c(n_samples, n_states), dimnames = list(NULL, state_names))

# QALY associated with 1-year in the smoking state is Normal(mean = 0_95, SD = 0_01)
# Divide by 2 as cycle length is 6 months
state_qalys[, "Smoking"] <- rnorm(n_samples, mean = 0.95, sd = 0.01) / 2

# QALY associated with 1-year in the not smoking state is 1 (no uncertainty)
# So all  samples have the same value
# Again divide by 2 as cycle length is 6 months
state_qalys[, "Not smoking"] <- 1 / 2

# And finally define the state costs
# These are all zero as the only cost is a one-off subscription fee of ?50
# to the smoking cessation website
state_costs<-array(0, dim = c(n_samples, n_states), dimnames = list(NULL, state_names))

# Define the treatment costs
# One for each  sample and each treatment
# Treatment costs are actually fixed but this allows flexibility if we
# want to include uncertainty /  randomness in the cost
treatment_costs <- array(dim = c(n_treatments, n_samples), dimnames = list(treatment_names, NULL))

# Cost of the smoking cessation website is a one-off subscription fee of ?50
treatment_costs["SoC with website", ] <- 50
# Zero cost for standard of care
treatment_costs["SoC", ] <- 0

#############################################################################
## Simulation ###############################################################
#############################################################################

# Build an array to store the cohort vector at each cycle
# Each cohort vector has 2 ( = n_states) elements: probability of being in smoking state,
# and probability of being in the not smoking state
# There is one cohort vector for each treatment, for each  sample, for each cycle_
cohort_vectors <- array(dim = c(n_treatments, n_samples, n_cycles, n_states), 
                        dimnames = list(treatment_names, NULL, NULL, state_names))

# Assume that everyone starts in the smoking state no matter the treatment
cohort_vectors[, , 1, "Smoking"] <- 1
cohort_vectors[, , 1, "Not smoking"] <- 0

# Build an array to store the costs and QALYs accrued per cycle
# One for each treatment, for each  sample, for each cycle
# These will be filled in below in the main model code
# Then discounted and summed to contribute to total costs and total QALYs
cycle_costs <- array(dim = c(n_treatments, n_samples, n_cycles), 
                     dimnames = list(treatment_names, NULL, NULL))
cycle_qalys <- array(dim = c(n_treatments, n_samples, n_cycles), 
                     dimnames = list(treatment_names, NULL, NULL))

# Build arrays to store the total costs and total QALYs
# There is one for each treatment and each  sample
# These are filled in below using cycle_costs, 
# treatment_costs, and cycle_qalys
total_costs <- array(dim = c(n_treatments, n_samples), 
                     dimnames = list(treatment_names, NULL))
total_qalys <- array(dim = c(n_treatments, n_samples), 
                     dimnames = list(treatment_names, NULL))


# The remainder of the cohort_vectors will be filled in by Markov updating below

# Main model code
# Loop over the treatment options
for (i_treatment in 1:n_treatments) 
{
  # Loop over the  samples
  for (i_sample in 1:n_samples) 
  {
    # Loop over the cycles
    # Cycle 1 is already defined so only need to update cycles 2:n_cycles
    for (i_cycle in 2:n_cycles) 
    {
      # Markov update
      # Multiply previous cycle's cohort vector by transition matrix
      # i_e_ pi_j = pi_(j-1)*P
      cohort_vectors[i_treatment, i_sample, i_cycle, ] <- 
        cohort_vectors[i_treatment, i_sample, i_cycle-1, ]%*%
        transition_matrices[i_treatment, i_sample, , ]
    }
    
    # Now use the cohort vectors to calculate the 
    # total costs for each cycle
    cycle_costs[i_treatment, i_sample, ] <- 
      cohort_vectors[i_treatment, i_sample, , ] %*% state_costs[i_sample, ]
    # And total QALYs for each cycle
    cycle_qalys[i_treatment, i_sample, ] <- 
      cohort_vectors[i_treatment, i_sample, , ] %*% state_qalys[i_sample, ]
    
    # Combine the cycle_costs and treatment_costs to get total costs
    # Apply the discount factor 
    # (1 in first year, 1_035 in second, 1_035^2 in third, and so on)
    # Each year acounts for two cycles so need to repeat the discount values
    total_costs[i_treatment, i_sample] <- treatment_costs[i_treatment, i_sample] + 
      cycle_costs[i_treatment, i_sample, ] %*%
      (1 / 1.035)^rep(c(0:(n_cycles / 2-1)), each = 2)
    
    # Combine the cycle_qalys to get total qalys
    # Apply the discount factor 
    # (1 in first year, 1_035 in second, 1_035^2 in third, and so on)
    # Each year acounts for two cycles so need to repeat the discount values
    total_qalys[i_treatment, i_sample] <- cycle_qalys[i_treatment, i_sample, ]%*%
      (1 / 1.035)^rep(c(0:(n_cycles / 2-1)), each = 2)
  }
}




#############################################################################
## Analysis of results ######################################################
#############################################################################

# Average costs
# These are £50 on the website and 0 on standard of care as there are no
# costs other than the website subscription cost
average_costs <- rowMeans(total_costs)
# Average effects (in QALY units)
# These are slightly higher on the website as higher probability of 
# quitting smoking
average_effects <- rowMeans(total_qalys)

# Incremental costs and effects relative to standard of care
# No uncertainty in the costs as the website cost is fixed at ?50
incremental_costs <- total_costs["SoC with website", ]-total_costs["SoC", ]
# In some samples the website leads to higher QALYs but in others it is negative
# There is uncertainty as to whether the website is an improvement over SoC
incremental_effects <- total_qalys["SoC with website", ]-total_qalys["SoC", ]

# The ICER comparing Standard of care with website to standard of care
# This is much lower than the ?20,000 willingness-to-pay threshold indicating
# good value for money
ICER <- mean(incremental_costs) / mean(incremental_effects)

# Incremental net benefit at the ?20,000 willingness-to-pay
# Sometimes positive (website more cost-effective) and sometimes negative (SoC more cost-effective)
# Need to look at averages and consider probabilities of cost-effectiveness
incremental_net_benefit <- 20000*incremental_effects-incremental_costs

# Average incremental net benefit
# This is positive indicating cost-effectiveness at the ?20,000 threshold
average_inb <- mean(incremental_net_benefit)

# Probability cost-effective
# This is the proportion of samples for which the incremental net benefit is positive
# It is close to 72%, representing good degree of certainty
# in recommendation to adopt the smoking cessation website
probability_cost_effective <- sum(incremental_net_benefit > 0) / n_samples


# Now use the BCEA package to analyse the results___
#Note costs and QALYs need to be transposed in this example for BCEA to run
smoking_bcea <- bcea(e = t(total_qalys), c = t(total_costs), ref = 1, interventions = treatment_names) 
#get summary statistics
summary(smoking_bcea, wtp = 20000)
#plot the cost-effectiveness plane
ceplane.plot(smoking_bcea, wtp = 20000,
             ylim = c(-70, 70))

#plot a CEAC
smoking_multi_ce <- multi.ce(smoking_bcea)
ceac.plot(smoking_multi_ce)
