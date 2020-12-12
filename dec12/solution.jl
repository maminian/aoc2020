push!(LOAD_PATH, abspath("../"))
import loaders

#
# Today's problem
#
# https://www.youtube.com/watch?v=RuJNUXT2a9U
#

mutable struct Floater
    x::Float64
    y::Float64
    th::Float64   # theta
end

# function references and sign modifiers
funcd = Dict(
    'N' => ("dy!",+1.0),
    'S' => ("dy!",-1.0),
    'E' => ("dx!",+1.0),
    'W' => ("dx!",-1.0),
    'L' => ("dth!",+1.0),
    'R' => ("dth!",-1.0),
    'F' => ("dr!",+1.0)
)

function dy!(boat::Floater, amount::Float64 )
    boat.y += amount
end
function dy!(boat::Floater, wpt::Floater, amount::Float64 )
    wpt.y += amount
end

function dx!(boat::Floater, amount::Float64 )
    boat.x += amount
end
function dx!(boat::Floater, wpt::Floater, amount::Float64 )
    wpt.x += amount
end

function dth!(boat::Floater, amount::Float64 )
    boat.th += amount  # DEGREES
end
function dth!(boat::Floater, wpt::Floater, amount::Float64)
    # get the wpt to 
    # travel in a circular arc relative to the boat
    r = sqrt(wpt.x^2 + wpt.y^2)
    # update wpt.th if not already.
    wpt.th = 180/pi*atan(wpt.y, wpt.x) # atan2

    dth!(wpt,amount)    # overkill, i know
    
    wpt.x = r*cos(wpt.th*pi/180.)
    wpt.y = r*sin(wpt.th*pi/180.)
end

function dr!(boat::Floater, amount::Float64 )
    # advance boat radially the give amount
    boat.x += amount*cos(boat.th*pi/180.)
    boat.y += amount*sin(boat.th*pi/180.)
end
function dr!(boat::Floater, wpt::Floater, amount::Float64 )
    # advance boat to waypoint the number of times
    boat.x += amount*wpt.x
    boat.y += amount*wpt.y
end


function operate!(state, line::String, verbose::Bool = true)
    instruction = funcd[line[1]]
    magnitude = parse(Float64,line[2:end])
    # for calling a function by string ref
    # following https://stackoverflow.com/a/34023458 
    getfield(Main, Symbol(instruction[1]))( state, instruction[2]*magnitude )
    if verbose
        println([state.x,state.y,state.th],"\n")
    end
end
function operate!(boat::Floater, wpt::Floater, line::String, verbose::Bool = false)
    instruction = funcd[line[1]]
    magnitude = parse(Float64,line[2:end])
    getfield(Main, Symbol(instruction[1]))( boat, wpt, instruction[2]*magnitude )
end

####
println("\nPart 1\n==============")
input = loaders.listloader("input", String)

b = Floater(0.0,0.0,0.0)

for inp in input
    operate!(b,inp, false)
end
println("final manhattan distance: ", abs(b.x) + abs(b.y) )

println("\nPart 2\n==============")
b2 = Floater(0.0,0.0,0.0)
w = Floater(10.0, 1.0, 0.0)

for inp in input
    operate!(b2,w,inp, false)
end

println("final manhattan distance: ", abs(b2.x) + abs(b2.y) )

function get_history(input)
    # visualizing elsewhere
    bh = Floater(0.0,0.0,0.0)
    wh = Floater(10.0, 1.0, 0.0)
    
    # bx,by,wx,wy,wth
    state = zeros(length(input)+1, 5)
    state[1,:] = [0.0,0.0, 10.0, 1.0, atan(10.0,1.0)]
    for (j,inp) in enumerate(input)
        operate!(bh,wh,inp, false)
        state[j+1,:] = [bh.x, bh.y, wh.x, wh.y, wh.th]
    end
    return state
end