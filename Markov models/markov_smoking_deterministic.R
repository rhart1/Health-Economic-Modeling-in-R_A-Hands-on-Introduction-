# Smoking Cessation Markov model
# Deterministic Model

# Define the number and names of treatments
# These are Standard of Care with website
# and Standard of Care without website
n_treatments <-  2
treatment_names <-  c("SoC with website", "SoC")

# Define the number and names of states of the model
# This is two and they are "Smoking" and "Not smoking"
n_states <-  2
state_names <-  c("Smoking", "Not smoking")

# Define the number of cycles
# This is 10 as the time horizon is 5 years and cycle length is 6 months
n_cycles <-  10

#############################################################################
## Input parameters #########################################################
#############################################################################

# The transition matrix is a 2x2 matrix
# Rows sum to 1
# Top left entry is transition probability from smoking to smoking
# Top right is transition probability from smoking to not smoking
# Bottom left is transition probability from not smoking to smoking
# Bottom right is transition probability from not smoking to not smoking

# There is one transition matrix for each treatment option
# Store them in an array with (before filling in below) NA entries
transition_matrices <-  array(dim = c(n_treatments, n_states, n_states), 
	dimnames = list(treatment_names, state_names, state_names))

# First the transition matrix for Standard of Care with website
# Transitions from smoking 
transition_matrices["SoC with website", "Smoking", ] <-  c(0.85, 0.15)
# Transitions from not smoking
transition_matrices["SoC with website", "Not smoking", ] <-  c(0.08, 0.92)

# Second the transition matrix for Standard of Care
# Transitions from smoking 
transition_matrices["SoC", "Smoking", ] <-  c(0.88, 0.12)
# Transitions from not smoking
# These should be the same as the transition probabilities from not smoking for SoC with website
# as the website has no impact on probability of relapse
transition_matrices["SoC", "Not smoking", ] <-  transition_matrices["SoC with website", "Not smoking", ]

# Now define the QALYS associated with the states per cycle
# There is one for each state
# Store in an NA array and then fill in below
state_qalys <-  array(dim = c(n_states), dimnames = list(state_names))

# QALY associated with 1 - year in the smoking state is Normal(mean = 0.95,  SD = 0.01)
# Divide by 2 as cycle length is 6 months
state_qalys["Smoking"] <-  0.95 / 2

# QALY associated with 1 - year in the not smoking state is 1 (no uncertainty)
# So all PSA samples have the same value
# Again divide by 2 as cycle length is 6 months
state_qalys["Not smoking"] <-  1.0 / 2

# And final define the state costs
# These are all zero as the only cost is a one - off subscription fee of £50
# to the smoking cessation website
state_costs <-  array(0, dim = c(n_states), dimnames = list(state_names))

# Define the treatment costs
# One for each treatment
# Treatment costs are actually fixed but this allows flexibility if we
# want to include uncertainty / randomness in the cost
treatment_costs <-  array(dim = c(n_treatments), dimnames = list(treatment_names))

# Cost of the smoking cessation website is a one - off subscription fee of £50
treatment_costs["SoC with website"] <-  50
# Zero cost for standard of care
treatment_costs["SoC"] <-  0

#############################################################################
## Calculation ###############################################################
#############################################################################

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
# One for each treatment,  for each PSA sample,  for each cycle
# These will be fille din below in the main model code
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
		# total costs for each cycle
		cycle_costs[i_treatment, ] <-  cohort_vectors[i_treatment, , ] %*% state_costs[]
		# And total QALYs for each cycle
		cycle_qalys[i_treatment, ] <-  cohort_vectors[i_treatment, , ] %*% state_qalys[]

		# Combine the cycle_costs and treatment_costs to get total costs
		# Apply the discount factor 
		# (1 in first year,  1.035 in second,  1.035^2 in third,  and so on)
		total_costs[i_treatment] <-  treatment_costs[i_treatment] + 
			cycle_costs[i_treatment, ] %*% 
			(1 / 1.035)^rep(c(0:(n_cycles / 2 - 1)), each = 2)

		# Combine the cycle_qalys to get total qalys
		# Apply the discount factor 
		# (1 in first year,  1.035 in second,  1.035^2 in third,  and so on)
		total_qalys[i_treatment] <-  cycle_qalys[i_treatment, ] %*% 
			(1 / 1.035)^rep(c(0:(n_cycles / 2 - 1)), each = 2)
	
}

#############################################################################
## Analysis of results ######################################################
#############################################################################

# Incremental costs and effects relative to standard of care
# No uncertainty in the costs as the website cost is fixed at £50
incremental_costs <-  total_costs["SoC with website"] - total_costs["SoC"]
incremental_effects <-  total_qalys["SoC with website"] - total_qalys["SoC"]

# The ICER comparing Standard of care with website to standard of care
# This is much lower than the £20, 000 willingness - to - pay threshold indicating
# good value for money
ICER <-  incremental_costs / incremental_effects

# Incremental net benefit at the £20, 000 willingness - to - pay
incremental_net_benefit <-  20000 * incremental_effects - incremental_costs

#Output Results
ICER
incremental_effects
incremental_costs
incremental_net_benefit
