push!(LOAD_PATH, abspath("../"))
import loaders


input = loaders.listloader("input", String)

# run program from list of instructions.
# investigate infinite while loops by tracking lines executed.

pattern = r"([a-z]{3}) ([-+0-9]{1,})"   # e.g. "jmp +4", "acc -27"

function parse_day08(line::String, pat::Regex=pattern)
    rm = match( pat, line )
    if typeof(rm)!=RegexMatch
        println("bonk")
        return ("bonk!",NaN)
    else
        # exclamation point appended; in reference to function names below.
        return ( String(rm[1])*"!", parse(Int,rm[2]) )
    end
end

mutable struct Intcode
    program::Array # program as array of tuples
    n::Int  # size of program
    p::Int  # current index position
    a::Int  # accumulator
    history::Array # history of lines visited
    halted::Bool
end

# possible commands: 
#
# acc - global value; accumulator
# jmp - jump value; move to index relative to current position.
# nop - no operation

# following Julia convention - in-place modification
# ends functions with exclamation point.
function acc!(state::Intcode,i::Int)
    # acc - global value; accumulator
    state.a += i
    jmp!(state,1)
    return
end

function jmp!(state::Intcode,i::Int)
    # jmp - jump value; move to index relative to current position.
    state.p += i
    return
end

function nop!(state::Intcode,i::Int)
    # nop - no operation - only advance
    jmp!(state,1)
    return
end

function hist!(state::Intcode,i::Int)
    state.history[i] += 1
    return
end

function iter!(state::Intcode,verbose::Bool=true)
    cmdstr = state.program[state.p][1]
    i = state.program[state.p][2]
    hist!(state,state.p)
    
    if verbose
        println("Line ",state.p, " (visit ",state.history[state.p],") ",cmdstr, " ",i)
    end
    
    # following https://stackoverflow.com/a/34023458 for calling func by string ref
    getfield(Main, Symbol(cmdstr))(state,i)
    
    if state.p > state.n
        println("SUCCESSFUL HALT")
        state.halted = true
        return
    end
    return
end

function initialize(input::Array{String,1})
    program = parse_day08.(input)
    n = length(input)
    p = 1
    a = 0
    history = zeros(Int, n)
    return Intcode(program,n,p,a,history,false)
end

function attempt!(state::Intcode)
    iter!(state, false)
    while state.history[state.p] <1
        iter!(state, false)
        if state.halted # avoid illegal access in while's condition 
            break
        end
    end
    return
end

#
##########################
#
ic = initialize(input)

println("\nPart 1\n================")
iter!(ic)
while ic.history[ic.p] <1
    iter!(ic)
end
println("\nAccumulator previously: ", ic.a)

println("\nPart 2\n================")
for i=1:length(input)
    global ici = initialize(input)
    if ici.program[i][1]=="jmp!"
        global ici.program[i] = ("nop!", ici.program[i][2])
    elseif ici.program[i][1]=="nop!"
        global ici.program[i] = ("jmp!", ici.program[i][2])
    else
        continue
    end
    
    attempt!(ici)
    if ici.halted
        println("WINNER, replacement ",i, " acc: ",ici.a)
    end
end
