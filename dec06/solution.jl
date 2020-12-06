#push!(LOAD_PATH, "/home/moo/aoc2020/")
push!(LOAD_PATH, abspath("../"))
import loaders

input = loaders.listloader("input", String)
d = Dict(letter => j for (j,letter) in enumerate("abcdefghijklmnopqrstuvwxyz"))

function make_gform(myl::Array{String,1})
    p = length(myl)
    gform = falses(p,26)
    
    for (i,line) in enumerate(myl)
        for c in line
            gform[i,d[c]] = true
        end
    end
    return gform
end

function parse_customs(obj::Array{String,1})
    # goal: break out input into groups.
    # groups distinguished by newline.
    
    gforms = []
    global l = 1
    
    for (r,line) in enumerate(obj)
        if line=="" || r==length(obj)
            id = r - (r!=length(obj))
            form = make_gform(obj[l:id])
            append!(gforms, [form])
            global l=r+1
        end
    end

    return gforms
end

function get_group_yesses(gfs::BitArray)
    return sum( any(gfs, dims=1) )
end

function get_group_yesses2(gfs::BitArray)
    return sum( all(gfs, dims=1) )
end

#########

gforms = parse_customs(input)

println("Part 1: sum of any(questions) in group?")
println( sum(get_group_yesses.(gforms)) )

println("Part 2: sum of all(questions) in group?")
println( sum(get_group_yesses2.(gforms)) )
