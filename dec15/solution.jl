push!(LOAD_PATH, abspath("../"))
import loaders

mutable struct Game
    memory::Dict
    spoken::Int
    prev::Int
    turn::Int
    table::Array
    n::Int
end

function print_state(g::Game)
    println("\tTurn: ", g.turn)
    println("\tPrevious: ", g.prev)
    println("\tSpoken: ", g.spoken)
    println("\t",g.memory)
end

function initialize(starters::Array{Int,1})
    stuples = [(s,length(starters)-j) for (j,s) in enumerate(starters)]
    g = Game(Dict(stuples),starters[end],starters[end-1],length(starters))
    return g
end

function step!(g::Game,verbose::Bool=false)
    g.turn += 1
    g.prev = g.spoken
    spoken = (g.prev in keys(g.memory))
    if !spoken
        g.spoken = 0
        g.memory[g.prev] = 0
    else
        g.spoken = g.memory[g.prev]
        g.memory[g.prev] = 0
    end
    for k in keys(g.memory)
        g.memory[k] += 1
    end
    if verbose
        print_state(g)
    end
end

function step_many!(g::Game, nit::Int)
    for i=1:nit
        step!(g)
    end
end
##

#starters = [0,3,6] # input_mini
starters = [11,0,1,10,5,19] # input
g = initialize(starters)

for i=length(starters)+1:2020
    step!(g)
end
print_state(g)

println("\nPart 2: repeat for input 30 mil")

# ...is this going to take forever?
# looking pretty spooky past 2^15
for pows=2:15
    g2 = initialize(starters)
    println("this many steps: ")
    @time step_many!(g2,2^pows)
end