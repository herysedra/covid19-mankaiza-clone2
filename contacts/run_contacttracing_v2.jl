push!(LOAD_PATH, "./src")
push!(LOAD_PATH, "./contacts")
using Plots,Parameters,Distributions,DifferentialEquations,JLD2,DataFrames,StatsPlots,FileIO,MAT,RecursiveArrayTools
import KenyaCoV_contacts
using LinearAlgebra:eigen
using Statistics: median, quantile

"""
Define uncertainty of parameter estimates
"""
d_incubation = LogNormal(log(4.8),0.25) #Liu et al
mean(d_incubation)
(quantile(d_incubation,0.025),median(d_incubation),quantile(d_incubation,0.975))
d_R₀ = Gamma(100,2.92/100) ##Liu et al
mean(d_R₀)
(quantile(d_R₀,0.025),median(d_R₀),quantile(d_R₀,0.975))

"""
Load age structured data
"""
u0,P,P_dest = KenyaCoV_contacts.model_ingredients_from_data("data/data_for_age_structuredmodel.jld2", "data/flight_numbers.csv", "data/projected_global_prevelance.csv")
u0[KenyaCoV_contacts.ind_nairobi_as,5,4] = 5#Five initial infecteds in Nairobi in the 20-24 age group

"""
SCENARIO I:  PLOTTING ONE PROBLEM
"""
u0,P,P_dest = KenyaCoV_contacts.model_ingredients_from_data("data/data_for_age_structuredmodel.jld2","data/flight_numbers.csv","data/projected_global_prevelance.csv")
u0[KenyaCoV_contacts.ind_nairobi_as,5,4] = 5#Five initial infecteds in Nairobi in the 20-24 age group
P.dt = 0.5;
P.ext_inf_rate = 0.;
P.ϵ = rand(Uniform(0.,0.5))
P.δ = 0.2
P.γ = 1/2.5
P.σ = 1/rand(d_incubation)
P.β = rand(d_R₀)*P.γ/(P.δ + P.ϵ*(1-P.δ))
P.τ=1/3.
P.τₚ=0.05
P.κ=5
P.κₘ=3
P.Δₜ=3
P.κ_per_event4=30
P.Κ_max_capacity=1e4

for wa=1:KenyaCoV_contacts.n_a, a=1:KenyaCoV_contacts.n_a   #**** #Calculate P.Mₚ = Age mixing pobabilities matrix
    P.Mₚ[wa,a]=P.M[wa,a]/sum(P.M[wa,:])
end

prob = KenyaCoV_contacts.create_KenyaCoV_non_neg_prob(u0,(0.,365.),P)


function run_simulations2(P::KenyaCoV_contacts.CoVParameters_AS,prob,n_traj,τₚ)
    P.τₚ = τₚ
    ensemble_prob = EnsembleProblem(prob,prob_func = randomise_params)
    return solve(ensemble_prob,FunctionMap(),dt = P.dt,trajectories = n_traj)
end
function randomise_params(prob,i,repeat)
    _P = deepcopy(prob.p)
    _P.σ = 1/rand(d_incubation)
    _P.β = rand(d_R₀)*_P.γ/(_P.δ + _P.ϵ*(1-_P.δ))
    return remake(prob,p=_P)
end
function run_scenario2(P::KenyaCoV_contacts.CoVParameters_AS,prob,n_traj,τₚ_list)
    results = []
    for τₚ in τₚ_list
        println("Running ",n_traj," sims for τₚ=",τₚ)
        sims = run_simulations2(P,prob,n_traj,τₚ)
        push!(results,sims)
    end
    return results
end
function run_scenario_andMAT(P::KenyaCoV_contacts.CoVParameters_AS,prob,n_traj,τₚ_list)
    #results = []
    for τₚ in τₚ_list
        println("Running ",n_traj," sims for τₚ=",τₚ, " and Κ_max_capacity=",P.Κ_max_capacity)
        @time sims = run_simulations2(P,prob,n_traj,τₚ)

        finalCumINairobiSum=[sum(sims[sim_i].u[end][4,:,8])   for sim_i=1:n_traj]
        file = matopen("./contacts/finalCumIData_sims"*string(n_traj)*"_taup"*string(τₚ)*"_1e4.mat", "w")
        write(file, "finalCumINairobiSum", finalCumINairobiSum)
        close(file)
        #push!(results,sims)
    end
    return results
end
function run_scenario_andJLD2sims(P::KenyaCoV_contacts.CoVParameters_AS,prob,n_traj,τₚ_list)
    for τₚ in τₚ_list
        println("Running ",n_traj," sims for τₚ=",τₚ, " and Κ_max_capacity=",P.Κ_max_capacity)
        P.τₚ = τₚ
        @time sims = solve(EnsembleProblem(prob,prob_func = randomise_params),FunctionMap(),dt = P.dt,trajectories = n_traj)
        #file = matopen("./contacts/sims"*string(n_traj)*"_taup"*string(τₚ)*"_1e4.mat", "w")
        #write(file, "sims", sims);     #close(file)
        #@save "./contacts/session2_sims"*string(n_traj)*"_taup"*string(τₚ)*"_1e4.jld2" sims
    end
end
function run_scenario_andMATsims(P::KenyaCoV_contacts.CoVParameters_AS,prob,n_traj,τₚ_list)
    for τₚ in τₚ_list
        println("Running ",n_traj," sims for τₚ=",τₚ, " and Κ_max_capacity=",P.Κ_max_capacity)
        P.τₚ = τₚ
        @time sims = solve(EnsembleProblem(prob,prob_func = randomise_params),FunctionMap(),dt = P.dt,trajectories = n_traj)
        file = matopen("./contacts/session3_sims"*string(n_traj)*"_taup"*string(τₚ)*"_1e4.mat", "w")
        write(file, "sims", sims);     close(file);
        #@save "./contacts/session2_sims"*string(n_traj)*"_taup"*string(τₚ)*"_1e4.jld2" sims
    end
end
function save_sims_MAT(outputfile,sims)
    sims_vector=sims.u[1].t
    for i=1:size(sims.u,1)
        sims_vector=[sims_vector sims.u[i].u]
    end
    file = matopen("./contacts/session""_sims"*string(n_traj)*"_taup"*string(τₚ)*"_1e4.mat", "w")
    write(file, "sims", sims);
    close(file);
end

τₚ_list=[0.0,0.25]#,0.5,0.75,0.9]
results_sessions = run_scenario_andMATsims(P,prob,10,τₚ_list)


P.τₚ = 0
@time sims = solve(EnsembleProblem(prob,prob_func = randomise_params),FunctionMap(),dt = P.dt,trajectories = 5)
save_sims_MAT()

#=results_sessions = run_scenario2(P,prob,100,τₚ_list)

#@save "./contacts/results_sessions_1" results_sessions

finalCumINairobiSum=[]
for τₚi=1:size(τₚ_list,1)
    push!(finalCumINairobiSum,[sum(results_sessions[τₚi][sim_i].u[end][4,:,8])   for sim_i=1:10])
end
plot(finalCumINairobiSum)

finalCumINairobi=[]
for τₚi=1:size(τₚ_list,1),sim_i=1:100
    push!(finalCumINairobi,results_sessions[τₚi][sim_i].u[end][4,:,8])
end
plot(finalCumINairobi)

using MAT
##https://github.com/JuliaIO/MAT.jl
file = matopen("./contacts/finalCumIData1000.mat", "w")
write(file, "finalCumINairobiSum", finalCumINairobiSum)
write(file, "finalCumINairobi", finalCumINairobi)
close(file)



boxplot(finalCumINairobiSum, leg = false)=#