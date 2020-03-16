push!(LOAD_PATH, joinpath(homedir(),"GitHub/KenyaCoV/src"))
using Plots,Parameters,Distributions,JLD2,DataFrames,StatsPlots,FileIO,MAT
using Statistics: median, quantile

treatment_rates = [(0.,1),(0.,0.5),(1/7.,1.),(1/7,0.5),(1/3.5,1.),(1/3.5,0.5)]
reducted_treatment_rates = [(0.,1),(1/3.5,0.5)]
reduced_rel_transmission_perc = [10,25]

rel_transmission_perc = [0,10,25,50,100]

"""
Plots ---
1) Early growth for both scenarios
2) Peaks
3) Size and age distribution
"""


@load joinpath(homedir(),"Github/KenyaCoVOutputs/results_1.jld2") results_1
@load joinpath(homedir(),"Github/KenyaCoVOutputs/results_2.jld2") results_2
@load joinpath(homedir(),"Github/KenyaCoVOutputs/results_3.jld2") results_3
@load joinpath(homedir(),"Github/KenyaCoVOutputs/results_4.jld2") results_4
@load joinpath(homedir(),"Github/KenyaCoVOutputs/results_5.jld2") results_5
@load joinpath(homedir(),"Github/KenyaCoVOutputs/results_2S.jld2") results_2S
@load joinpath(homedir(),"Github/KenyaCoVOutputs/results_3S.jld2") results_3S



# gr()
include("plotting_functions.jl");
scenario_group = [results_1,results_2,results_3,results_4,results_5]
plt_no_control = plot_total_incidence_group(scenario_group,treatment_rates,1,rel_transmission_perc)
title!(plt_no_control,"Uncontrolled epidemic: 5 generations of undetected transmission")
plot!(plt_no_control,size = (700,400))
xlims!(0.,30.)
savefig(plt_no_control,"plotting/baseline_scenarios.pdf")
plt_controls = plot_total_incidence_group(scenario_group,treatment_rates,6,rel_transmission_perc)
title!(plt_controls,"Target diseased cases (no social distancing): detection period = 3.5 days")
plot!(plt_controls,size = (700,400))
savefig(plt_controls,"plotting/target_scenarios.pdf")

scenario_group_SD = [results_2S,results_3S]
plt_no_control_SD = plot_total_incidence_group(scenario_group,reducted_treatment_rates,1,reduced_rel_transmission_perc)
title!(plt_no_control_SD,"Social distancing only")
plot!(plt_no_control_SD,size = (700,400))
plot!(plt_no_control_SD,legend = :topleft)
# xlims!(0.,30.)
savefig(plt_no_control_SD,"plotting/baseline_scenarios_with_social_distancing.pdf")


scenario_group_SD = [results_2S,results_3S]
plt_control_SD = plot_total_incidence_group(scenario_group,reducted_treatment_rates,2,reduced_rel_transmission_perc)
title!(plt_control_SD,"Social distancing and direct isolation")
plot!(plt_control_SD,size = (700,400))
plot!(plt_control_SD,legend = :topleft)
# xlims!(0.,30.)
savefig(plt_control_SD,"plotting/direct_control_scenarios_with_social_distancing.pdf")
