using Plots,MAT, StatsPlots

results_folder=".\\contacts\\results_session20s\\results_session20\\"
taup_list=[0.0,0.25,0.5,0.75,0.9]
data_files=readdir(results_folder)#["sims100_taup0.0_capacity10000.mat","sims100_taup0.25_capacity10000.mat","sims100_taup0.5_capacity10000.mat","sims100_taup0.75_capacity10000.mat","sims100_taup0.9_capacity10000.mat"];
data_files=[s for s in data_files if endswith(s,".mat")]
n_traj=200
riskregionnames = ["Machakos/Muranga" "Mandera" "Baringo/Nakuru" "Nairobi" "Uasin Gishu" "Marsabit" "Garissa" "Nakuru/Narok" "Turkana" "Taita Taveta" "Kitui/Meru" "Kilifi/Mombasa" "Kericho/Kisumu" "Kilifi/Lamu" "Kakamega/Kisumu" "Wajir" "Kajiado/Kisumu" "Homa bay/Migori" "Samburu/Laikipia" "Kilifi/Kwale" "Total"]

## Plotting functions IN NAIROBI
function ALL_TAUP_cumulative_symptomatics_sumages(taup_list,results_folder,data_files,n_traj)
    p=plot(title="Final cumulative Infecteds(ID+IQ) "*string(n_traj)*" sims (sum all ages) Nairobi")
    for i=1:size(taup_list,1)
        file = matopen(results_folder*data_files[i])
        data_per_taup=read(file, "sims")
        close(file)
        data_per_taup=data_per_taup[:,2:end]

        Id_per_taup_nairobi=[]   # Infecteds=I_D+I_Q
        for j=1:size(data_per_taup,2)
            push!(Id_per_taup_nairobi,sum(data_per_taup[end,j][4,:,8]))
        end
        plot!(p,Id_per_taup_nairobi, label="taup"*string(taup_list[i]))
    end
    #display(p)
    savefig(p,results_folder*"jl_cumulative_symptomatics_allages_nairobi.png")
end
function ALL_TAUP_cumulative_symptomatics_sumages_BOXPLOT(taup_list,results_folder,data_files,n_traj)
    p=boxplot(title="Final cumulative Infecteds(ID+IQ) "*string(n_traj)*" sims (sum all ages) Nairobi")
    data=[]
    for i=1:size(taup_list,1)
        file = matopen(results_folder*data_files[i])
        data_per_taup=read(file, "sims")
        close(file)
        data_per_taup=data_per_taup[:,2:end]

        Id_per_taup_nairobi=[];   # Infecteds=I_D+I_Q
        for j=1:size(data_per_taup,2)
            push!(Id_per_taup_nairobi,sum(data_per_taup[end,j][4,:,8]))
        end
        boxplot!(Id_per_taup_nairobi,label="taup"*string(taup_list[i]))
    end
    #display(p)
    savefig(p,results_folder*"jl_cumulative_symptomatics_allages_BOXPLOT_nairobi.png")
end
function ALL_TAUP_cumulative_symptomatics_perage_BOXPLOT(taup_list,results_folder,data_files,n_traj)
    p=boxplot(layout=16)
    for a=1:16
        data=[]
        for i=1:size(taup_list,1)
            file = matopen(results_folder*data_files[i])
            data_per_taup=read(file, "sims")
            close(file)
            data_per_taup=data_per_taup[:,2:end]

            Id_per_taup_nairobi=[];   # Infecteds=I_D+I_Q
            for j=1:size(data_per_taup,2)
                push!(Id_per_taup_nairobi,data_per_taup[end,j][4,a,8])
            end
            boxplot!(Id_per_taup_nairobi,subplot=a,legend=false)#,label="taup"*string(taup_list[i])*" a"*string(a),subplot=a)
        end
    end
    #display(p)
    savefig(p,results_folder*"jl_cumulative_symptomatics_perage_BOXPLOT_nairobi.png")
end
function ALL_TAUP_cumulative_symptomatics_peragegroup_BOXPLOT(taup_list,results_folder,data_files,n_traj)
    p=boxplot(layout=4)
    for g=1:4#a=1:16
        data=[]
        for i=1:size(taup_list,1)
            file = matopen(results_folder*data_files[i])
            data_per_taup=read(file, "sims")
            close(file)
            data_per_taup=data_per_taup[:,2:end]

            Id_per_taup_nairobi=[];   # Infecteds=I_D+I_Q
            for j=1:size(data_per_taup,2)
                a=
                push!(Id_per_taup_nairobi,sum([data_per_taup[end,j][4,g*4-3,8],data_per_taup[end,j][4,g*4-2,8],data_per_taup[end,j][4,g*4-1,8],data_per_taup[end,j][4,g*4,8]]))
            end
            boxplot!(Id_per_taup_nairobi,subplot=g,legend=false,title="Cumulative symptomatics in Nairobi for ages "*string(g*4-3)*"-"*string(g*4),titlefontsize=8)
        end
    end
    #display(p)
    savefig(p,results_folder*"jl_cumulative_symptomatics_peragegroup_BOXPLOT_nairobi.png")
end
## Calling the functions , IN NAIROBI
ALL_TAUP_cumulative_symptomatics_sumages(taup_list,results_folder,data_files,n_traj)
ALL_TAUP_cumulative_symptomatics_sumages_BOXPLOT(taup_list,results_folder,data_files,n_traj)
ALL_TAUP_cumulative_symptomatics_perage_BOXPLOT(taup_list,results_folder,data_files,n_traj)
ALL_TAUP_cumulative_symptomatics_peragegroup_BOXPLOT(taup_list,results_folder,data_files,n_traj)