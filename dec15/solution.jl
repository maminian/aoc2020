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
    # dictionary is now for pointers to array tracking
    # last-seen values.
    stuples = [(s,j) for (j,s) in enumerate(starters)]
    g = Game(
        Dict(stuples),
        starters[end],
        starters[end-1],
        length(starters),
        zeros(Int,length(starters)),
        length(starters)
        )
    return g
end

function expand_table!(g::Game)
    new_size = 2*g.n
    new_table = zeros(Int, new_size)
    new_table[1:g.n] = g.table
    g.table = new_table
end

function step!(g::Game,verbose::Bool=false)
    g.turn += 1
    g.prev = g.spoken
    was_spoken = ( g.prev in keys(g.memory) )
    if !was_spoken
        g.spoken = 0
        if g.n == length(g.table)
            expand_table!(g)
        end
        g.n += 1
        g.memory[g.prev] = g.n  # get pointer in table
        g.table[g.memory[g.prev]] = g.turn
    else
#        g.spoken = g.memory[g.prev]
        g.spoken = g.turn-1 - g.table[g.memory[g.prev]]
        g.table[g.memory[g.prev]] = g.turn
    end
#    for k in keys(g.memory)
#        g.memory[k] += 1
#    end
#    g.table[1:g.n] .+= 1
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

starters = [0,3,6] # input_mini
#starters = [11,0,1,10,5,19] # input
g = initialize(starters)

step!(g)
#for i=length(starters)+1:5
#    step!(g,true)
#end
print_state(g)

if false
    println("\nPart 2: repeat for input 30 mil")

    # ...is this going to take forever?
    # looking pretty spooky past 2^15
    for pows=2:15
        g2 = initialize(starters)
        println("this many steps: ")
        @time step_many!(g2,2^pows)
    end
end