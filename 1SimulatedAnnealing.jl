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
        words = split(l,('\t',' '))                 # In case of multiple delimiters 
        node = Node(parse(Int,words[1]), parse(Float64, words[2]), parse(Float64, words[3]))
        push!(nodes, node)
    end
end

function dists(NodeA::Node, NodeB::Node)    # Calculates distance from Node A to Node B
    sqrt((NodeA.Xcoord-NodeB.Xcoord)^2 + (NodeA.Ycoord-NodeB.Ycoord)^2)
end

# function distance_matrix(nodes::Array{Node,1})            
#    dist_matrix = zeros(length(nodes),length(nodes))
#    for i in range(1,length = length(nodes))
#       for j in range(1,length = length(nodes))
#            if i<=j 
#                dist_matrix[i,j] = dists(nodes[i],nodes[j])
#            end
#        end
#    end
#    dist_matrix = dist_matrix + dist_matrix'        # Symmetric Adjacency Matrix 
#    return dist_matrix 
# end

function pathcost(path::Array{Node,1})              # Finds distance of a route starting and ending
    cost = 0                                        # at the same point 
    for i in range(1,length = length(path)-1)
        cost = cost + dists(path[i],path[i+1])
    end
    cost = cost + dists(path[end],path[1])    # Cost of going from last node back to the initial node
    return cost 
end 

function neighborpath(path::Array{Node,1})          # Swaps 2 nodes in a route 
    newpath = deepcopy(path)
    idx1 = rand(1:length(newpath))
    idx2 = rand(1:length(newpath))
    temp = newpath[idx1]
    newpath[idx1] = newpath[idx2]
    newpath[idx2] = temp 
    return newpath 
end

function switching_probability(T::Float64, currentpath::Array{Node,1}, newpath::Array{Node,1})
    prob = exp(-(pathcost(newpath)-pathcost(currentpath))/T)
    return prob 
end

function simulated_annealing(path::Array{Node,1},T::Float64,counter::Int64,α::Float64)
    currpath = deepcopy(path)
    for i in range(1,length=500)                # Random initial state
        currpath = neighborpath(currpath)
    end
    besttour = currpath 
    bestcost = pathcost(currpath)
    for i in range(1,length = counter)
        newpath = neighborpath(currpath)
        if pathcost(newpath) < pathcost(currpath)
            currpath = deepcopy(newpath)
            if pathcost(newpath) < bestcost
                bestcost = pathcost(newpath)
                besttour = deepcopy(newpath)
            end
        elseif switching_probability(T,currpath,newpath) > rand()
            currpath = deepcopy(newpath)
        end
        T = T*α
    end
    return besttour
end


# pathcost(simulated_annealing(nodes,20000.00,10000000,0.999999))
# 446.94528f0

# pathcost(simulated_annealing(nodes,2.00,100000,0.999999))
# 457.38843f0
