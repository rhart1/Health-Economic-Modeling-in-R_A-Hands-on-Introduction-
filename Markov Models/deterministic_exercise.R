# Solution

###############################################################################################################
###############################################################################################################
###############################################################################################################

# Add state costs

# Run the file "markov_smoking_deterministic.R" 


# Redefine the state costs
# Store in an NA array and then fill in below
state_costs<-array(dim = c(n_states), dimnames = list(state_names))

# Cost associated with 1-year in the smoking state is £100
state_costs["Smoking"] <- 100 

# Cost associated with 1-year in the not smoking state is 0
state_costs["Not smoking"] <- 0

#############################################################################
## Calculation ##############################################################
#############################################################################

# Same code as before from here on below. Look at the difference in the results and compare ICER values.

# Build an array to store the cohort vector at each cycle
# Each cohort vector has 2 ( = n_states) elements: probability of being in smoking state, 
# and probability of being in the not smoking state
# There is one cohort vector for each treatment,  for each cycle_
cohort_vectors <-  array(dim = c(n_treatments, n_cycles, n_states), 
                         dimnames = list(treatment_names, NULL, state_names))

# Assume that everyone starts in the smoking state no matter the treatment
cohort_vectors[, 1, "Smoking"] <-  1
cohort_vectors[, 1, "Not smoking"] <-  0

# Build an array to store the costs and QALYs accrued per cycle
# One for each treatment, for each cycle
# These will be filled in below in the main model code
# Then discounted and summed to contribute to total costs and total QALYs
cycle_costs <-  array(dim = c(n_treatments, n_cycles), 
                      dimnames = list(treatment_names, NULL))
cycle_qalys <-  array(dim = c(n_treatments, n_cycles), 
                      dimnames = list(treatment_names, NULL))

# Build arrays to store the total costs and total QALYs
# There is one for each treatment
# These are filled in below using cycle_costs,  treatment_costs,  and cycle_qalys
total_costs <-  array(dim = c(n_treatments), 
                      dimnames = list(treatment_names))
total_qalys <-  array(dim = c(n_treatments), 
                      dimnames = list(treatment_names))


# The remainder of the cohort_vectors will be filled in by Markov updating below

# Main model code
# Loop over the treatment options
for(i_treatment in 1:n_treatments)
{
  # Loop over the cycles
  # Cycle 1 is already defined so only need to update cycles 2:n_cycles
  for(i_cycle in 2:n_cycles)
  {
    # Markov update
    # Multiply previous cycle's cohort vector by transition matrix
    # i_e_ pi_j  =  pi_(j - 1) * P
    cohort_vectors[i_treatment, i_cycle, ] <-  
      cohort_vectors[i_treatment, i_cycle - 1, ] %*% 
      transition_matrices[i_treatment, , ]
  }
  
  
  
  # Now use the cohort vectors to calculate the 
  # Total costs for each cycle
  cycle_costs[i_treatment, ] <-  cohort_vectors[i_treatment, , ] %*% state_costs[]
  # And total QALYs for each cycle
  cycle_qalys[i_treatment, ] <-  cohort_vectors[i_treatment, , ] %*% state_qalys[]
  
  # Combine the cycle_costs and treatment_costs to get total costs
  # Apply the discount factor 
  total_costs[i_treatment] <-  treatment_costs[i_treatment] + 
    cycle_costs[i_treatment, ] %*% 
    (1 / 1.035)^c(0:(n_cycles - 1))
  
  # Combine the cycle_qalys to get total qalys
  # Apply the discount factor 
  total_qalys[i_treatment] <-  cycle_qalys[i_treatment, ] %*% 
    (1 / 1.035)^c(0:(n_cycles - 1))
  
}

#############################################################################
## Analysis of results ######################################################
#############################################################################

# Incremental costs and effects relative to standard of care
# No uncertainty in the costs as the website cost is fixed at £50
incremental_costs <-  total_costs["SoC with website"] - total_costs["SoC"]
incremental_effects <-  total_qalys["SoC with website"] - total_qalys["SoC"]

# The ICER comparing Standard of care with website to standard of care
# This is much lower than the £20,000 willingness - to - pay threshold indicating
# good value for money
ICER <-  incremental_costs / incremental_effects

# Incremental net benefit at the £20,000 willingness - to - pay
incremental_net_benefit <-  20000 * incremental_effects - incremental_costs

#Output Results
ICER
incremental_effects
incremental_costs
incremental_net_benefit