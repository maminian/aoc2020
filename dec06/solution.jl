#push!(LOAD_PATH, "/home/moo/aoc2020/")
push!(LOAD_PATH, abspath("../"))
import loaders

input = loaders.listloader("input", String)
d = Dict(letter => j for (j,letter) in enumerate("abcdefghijklmnopqrstuvwxyz"))

mutable struct Group
    forms::BitArray
end

function make_group(myl)
    p = length(myl)
    forms = falses(p,26)
    myg = Group(forms)
    
    for (i,line) in enumerate(myl)
        for c in line
            myg.forms[i,d[c]] = true
        end
    end
    
    return myg
end

function parse_customs(obj::Array{String,1})
    # goal: break out input into groups.
    # groups distinguished by newline.
    
    groups = []
    global l = 1
    
    for (r,line) in enumerate(obj)
        if line=="" || r==length(obj)
            if r!=length(obj)
                id=r-1
            else
                id=r
            end
            group = make_group(obj[l:id])
            append!(groups, [group])
            global l=r+1
        else
        
        end
    end

    return groups
end

function get_group_yesses(g::Group)
    return sum( any(g.forms, dims=1) )
end

function get_group_yesses2(g::Group)
    return sum( all(g.forms, dims=1) )
end

#########

groups = parse_customs(input)

println("Part 1: sum of any(questions) in group?")
println( sum(get_group_yesses.(groups)) )

#########

println("Part 2: sum of all(questions) in group?")
println( sum(get_group_yesses2.(groups)) )
