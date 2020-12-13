push!(LOAD_PATH, abspath("../"))
import loaders

# bus is here
# https://www.youtube.com/watch?v=6_HO5bRy0Vg

input = loaders.listloader("input", String)
inttype = Int64

arrival = parse(inttype, input[1])
things = split(input[2],",")
mask = (things .!= "x")
buses = parse.(inttype, things[mask])

next = convert.(inttype, buses .* ceil.(arrival./buses))

o = sortperm(next)

busid_min = buses[o[1]]
wait_p1 = next[o[1]] - arrival

println("part 1: ", busid_min*wait_p1)

# part 2
# for each input,
# want to identify integer t such that, for example,
# mod(t, bus1) == 0
# mod(t, bus2) == 1
# mod(t, bus3) == 2
# etc..

modulo = collect(0:length(things)-1)
modulo = modulo[mask]   # remove placeholders

function moop(step1,step2, shift1, shift2)
    # step1,shift1 represent a collection of synchronized
    # buses stepping according to their lcm (in this case, 
    # product of their steps, since they're all prime).
    # step2,shift2 is the bus synchronizing with this group.
    global pos1 = copy(shift1)
    global pos2 = copy(shift2)
    while pos1 != pos2
        if pos2 > pos1
            ss = inttype( floor((pos2-pos1)/step1) )
            ss = max(1,ss)
            global pos1 += inttype(ss)*step1
        else
            ss = inttype( floor((pos1-pos2)/step2) )
            ss = max(1,ss)
            global pos2 += inttype(ss)*step2
        end
#        println([pos1,pos2-pos1,step1,step2])
    end
    return pos1
end

#buses = [2,3,5,7]
#modulo = [0,1,2,3]
# --> should give 158

println("part 2...\n")

global pos=buses[1]
for j=1:length(buses)-1
    global pos = moop(prod(buses[1:j]), buses[j+1], pos, -modulo[j+1])
    println("\tUpdate: ", [j,pos,buses[ob[j]]])
end

println("\nminimum timestamp: ", pos)
