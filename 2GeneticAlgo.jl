using StatsBase
using Random

struct Node 
    N::Int64
    Xcoord::Float64
    Ycoord::Float64
end

nodes = Node[]
open("eil51.txt") do f 
    lines = readlines(f)
    for l in lines 
        words = split(l,('\t',' '))         # Multiple delimiters 
        node = Node(parse(Int,words[1]), parse(Float64, words[2]), parse(Float64, words[3]))
        push!(nodes, node)
    end
end

function dists(NodeA::Node, NodeB::Node)
    sqrt((NodeA.Xcoord-NodeB.Xcoord)^2 + (NodeA.Ycoord-NodeB.Ycoord)^2)
end

function fitness(path::Array{Any,1})            # Calculates fitness of a route 
    cost = 0
    for i in range(1,length = length(path)-1)
        cost = cost + dists(path[i],path[i+1])
    end
    cost = cost + dists(path[end],path[1])    # Cost of going from last node back to the initial node
    return 1/cost 
end 

function makepopulation(nodes::Array{Node,1})             # Shuffles nodes to make initial population
    individual = deepcopy(nodes)                          # Works in conjunction with initialpopulation
    return sample!(nodes,individual,replace = false)
end

function initialpopulation(pop_size::Int64,path::Array{Node,1})
    population = []
    for i in range(1,length = pop_size)
        push!(population,makepopulation(path))
    end
    return population
end

function rankfit(population::Array{Any,1})                # Sorts routes in a population based on fitness
    fitnessresults = Dict()
    for i in range(1, length = length(population))
        fitnessresults[i] = fitness(population[i])
    end
    return sort(collect(fitnessresults), by = x -> x[2], rev = true)
end

function selection(rankedpop::Array{Pair{Any,Any},1})
    df1 = []
    cumsum0 = 0       # fitness for first element
    temp2 = []
    for i in range(1, length = length(rankedpop))
        cumsum0 = cumsum0 + rankedpop[i][2]
        push!(temp2,cumsum0)
    end
    
    for i in range(1, length = length(rankedpop))
        temp = [rankedpop[i][1], temp2[i]/cumsum0]
        push!(df1,temp)
    end
    
    selections = []
    for i in range(1,length = length(rankedpop))
        rng = rand()
        for i in range(1,length = length(rankedpop))
            if rng<df1[i][2]
                push!(selections,df1[i][1])
                break
            end
        end
    end
    return selections
end

function matingpool(population, selections::Array{Any,1})
    mpool = []
    for i in range(1,length = length(selections))
        push!(mpool,population[Int(selections[i])])
    end
    return mpool 
end

function crossover(Parent1::Array{Any,1}, Parent2::Array{Any,1})
    child = []
    # Randomly selected a subset of indices to take from Parent1
    lower = rand(1:length(Parent1))
    temp = rand(1:length(Parent1))
    if temp>lower
        upper = temp 
    else
        upper = length(Parent1)
    end


    for i in range(lower, stop = upper)         # Child created with selected indices or "genes" from Parent1
        push!(child,Parent1[i])
    end
    
    i = 1                                     # Rest of child's genes coming from Parent2 
    while i < length(Parent2)                  
        if Parent2[i] in child
            i+=1
        else
            push!(child,Parent2[i])
            i+=1
        end
    end
    return child
end

function newgeneration(matepool::Array{Any,1})              # Works with crossover to create new generation from old fittest routes
    children = []
    individual = deepcopy(matepool)
    pool = sample!(matepool,individual,replace = false)
    for i in range(1,length = length(matepool))
        push!(children,crossover(pool[i],pool[length(matepool)]))
    end
    return children 
end

function mutate(path::Array{Any,1}, mutationrate::Float64)          # Mutates an individual 
    mutation = deepcopy(path)
    idx1 = rand(1:length(mutation))
    idx2 = rand(1:length(mutation))
    if rand()<mutationrate
        temp = mutation[idx1]
        mutation[idx1] = mutation[idx2]
        mutation[idx2] = temp 
    end
    return mutation 
end

function mutatepopulation(path::Array{Any,1},mutationrate)
    mutatedpop = []
    for i in range(1,length = length(path))
        push!(mutatedpop,mutate(path,mutationrate))
    end
    return mutatedpop 
end


# Parameters 
PopulationSize = 50
MutationRate = 0.01 
Generations = 5
pop = initialpopulation(PopulationSize,nodes)

function nextGen(pop,MutationRate)
    RouteRanks = rankfit(pop)
    selections = selection(RouteRanks)
    children = newgeneration(matingpool(pop,selections))
    nextgen = mutatepopulation(children, MutationRate)
    return nextgen[1]
end

for i in range(1, length = Generations)
    pop = nextGen(pop,MutationRate)
end

1/rankfit(pop)[1][2]
# 1432.446473795974

