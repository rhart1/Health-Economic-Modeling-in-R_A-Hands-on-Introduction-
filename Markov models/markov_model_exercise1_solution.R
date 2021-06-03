# Solution to Markov models practical

###############################################################################################################
###############################################################################################################
###############################################################################################################

# Exercise 2. Add state costs

# Run the file "markov_smoking_probabilistic.R" 



# Redefine the state costs
# There is one for each PSA sample and each state
# Store in an NA array and then fill in below
state_costs<-array(dim = c(n_samples, n_states), dimnames = list(NULL, state_names))

# Cost associated with 1-year in the smoking state is £100 (no uncertainty)
# Divide by 2 as cycle length is 6 months
state_costs[, "Smoking"] <- 100 /  2

# Cost associated with 1-year in the not smoking state is 0 (no uncertainty)
# So all PSA samples have the same value
# Again divide by 2 as cycle length is 6 months
state_costs[, "Not smoking"] <- 0

#############################################################################
## Simulation ###############################################################
#############################################################################

# Build an array to store the cohort vector at each cycle
# Each cohort vector has 2 ( = n_states) elements: probability of being in smoking state,
# and probability of being in the not smoking state
# There is one cohort vector for each treatment, for each PSA sample, for each cycle_
cohort_vectors <- array(dim = c(n_treatments, n_samples, n_cycles, n_states), 
                        dimnames = list(treatment_names, NULL, NULL, state_names))

# Assume that everyone starts in the smoking state no matter the treatment
cohort_vectors[, , 1, "Smoking"] <- 1 
cohort_vectors[, , 1, "Not smoking"] <- 0


# Build an array to store the costs and QALYs accrued per cycle
# One for each treatment, for each PSA sample, for each cycle
# These will be filled in below in the main model code
# Then discounted and summed to contribute to total costs and total QALYs
cycle_costs <- array(dim = c(n_treatments, n_samples, n_cycles), 
                     dimnames = list(treatment_names, NULL, NULL))
cycle_qalys <- array(dim = c(n_treatments, n_samples, n_cycles), 
                     dimnames = list(treatment_names, NULL, NULL))

# Build arrays to store the total costs and total QALYs
# There is one for each treatment and each PSA sample
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
  # Loop over the PSA samples
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


# Now use the BCEA package to analyse the results___
#Note costs and QALYs need to be transposed in this example for BCEA to run
smoking_bcea <- bcea(e = t(total_qalys), c = t(total_costs), ref = 1, interventions = treatment_names) 
#get summary statistics
summary(smoking_bcea, wtp = 20000)

#You should get:
#                          EIB  CEAC   ICER
#SoC with website vs SoC 258.52 0.715 1571.8

#plot the cost-effectiveness plane
ceplane.plot(smoking_bcea, wtp = 20000)
#plot a CEAC
smoking_multi_ce <- multi.ce(smoking_bcea)
mce.plot(smoking_multi_ce, pos = c(1,0))

###############################################################################################################
###############################################################################################################
###############################################################################################################