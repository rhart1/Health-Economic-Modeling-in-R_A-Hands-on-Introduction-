# Solution to Markov models practical

###############################################################################################################
###############################################################################################################
###############################################################################################################
# Exercise 2

# Run the file "markov_smoking_probabilistic.R" 

# Reset the seed so this sensitivity analysis is reproducible
set.seed(1002435)

# Exercise 3. Add the 'Death' state

# Redefine the number and names of states of the model
# This is three and they are "Smoking", "Not smoking" and "Death"
n_states <- 3
state_names <- c("Smoking", "Not smoking", "Death")

# There is one transition matrix for each treatment option and each  sample
# Store them in an array with (before filling in below) NA entries
transition_matrices <- array(dim = c(n_treatments, n_samples, n_states, n_states), 
                             dimnames = list(treatment_names, NULL, state_names, state_names))

# First redefine the transition matrix for Standard of Care with website adding transitions to death
#Assume that people have a 2% probability of dying in the smoking state and a 1% probability of dying in the non-smoking state. 
probability_of_death_smoking <- rbeta(n_samples, 2, 98)
probability_of_death_not_smoking <- rbeta(n_samples, 1, 99)

# Transitions from smoking 
temp <- rbeta(n_samples, 85, 15)
transition_matrices["SoC with website", , "Smoking", ] <- 
  matrix(c((1 - probability_of_death_smoking) * c(temp, 1 - temp), 
           probability_of_death_smoking), ncol = 3)

# Transitions from not smoking
temp <- rbeta(n_samples, 8, 92)
transition_matrices["SoC with website", , "Not smoking", ] <- 
  matrix(c((1 - probability_of_death_not_smoking) * c(temp, 1 - temp), 
           probability_of_death_not_smoking), ncol = 3)

# Transitions from death are set to zero and are not uncertain
transition_matrices["SoC with website", , "Death", ] <- c(0,0, 1)


# Second the transition matrix for Standard of Care
# Transitions from smoking 
temp <- rbeta(n_samples, 88, 12)
transition_matrices["SoC", , "Smoking", ] <-
  matrix(c((1 - probability_of_death_smoking) * c(temp, 1 - temp), 
           probability_of_death_smoking), ncol = 3)

# Transitions from not smoking
# These should be the same as the transition probabilities from not smoking for SoC with website
# as the website has no impact on probability of relapse
transition_matrices["SoC", , "Not smoking", ] <- transition_matrices["SoC with website", , "Not smoking", ]
# Transitions from death
transition_matrices["SoC", ,"Death", ] <- c(0, 0, 1)

#Check that you have set up your transition matrix correctly 
transition_matrices["SoC with website", 1, ,]

# Now define the QALYS associated with the states per cycle
# There is one for each sample and each state
# Store in an NA array and then fill in below
state_qalys <- array(dim = c(n_samples, n_states), dimnames = list(NULL, state_names))

# QALY associated with 1-year in the smoking state is Normal(mean = 0_95, SD = 0_01)
# Divide by 2 as cycle length is 6 months
state_qalys[, "Smoking"] <- rnorm(n_samples, mean = 0.95, sd = 0.01) /  2

# QALY associated with 1-year in the not smoking state is 1 (no uncertainty)
# So all  samples have the same value
# Again divide by 2 as cycle length is 6 months
state_qalys[, "Not smoking"] <- 1 /  2

# QALY associated with 1-year in death state is 0 (no uncertainty)
state_qalys[, "Death"] <- 0

# And finally define the state costs
# These are all zero as the only cost is a one-off subscription fee of ?50
# to the smoking cessation website
state_costs <- array(0, dim = c(n_samples, n_states), dimnames = list(NULL, state_names))


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
cohort_vectors[, , 1, "Death"] <- 0

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
      # i_e_ pi_j  =  pi_(j-1)*P
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
      (1 /  1.035)^rep(c(0:(n_cycles /  2-1)), each = 2)
    
    # Combine the cycle_qalys to get total qalys
    # Apply the discount factor 
    # (1 in first year, 1_035 in second, 1_035^2 in third, and so on)
    # Each year acounts for two cycles so need to repeat the discount values
    total_qalys[i_treatment, i_sample] <- cycle_qalys[i_treatment, i_sample, ]%*%
      (1 / 1.035)^rep(c(0:(n_cycles /  2-1)), each = 2)
  }
}

#############################################################################
## Analysis of results ######################################################
#############################################################################

#Note costs and QALYs need to be transposed in this example for BCEA to run
smoking_bcea <- bcea(e = t(total_qalys), c = t(total_costs), ref = 1, interventions = treatment_names) 
#get summary statistics
summary(smoking_bcea, wtp = 20000)

#You should get:
#                         EIB  CEAC   ICER
#SoC with website vs SoC 431.13 0.518 2078.4

#plot the cost-effectiveness plane
ceplane.plot(smoking_bcea, wtp = 20000, ylim = c(-70, 70))
#plot a CEAC
smoking_multi_ce <- multi.ce(smoking_bcea)
ceac.plot(smoking_multi_ce)


