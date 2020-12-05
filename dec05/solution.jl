#push!(LOAD_PATH, "/home/moo/aoc2020/")
push!(LOAD_PATH, abspath("../"))
import loaders

function todec(val::String, o::Char)
    n = length(val)
    out = 0
    for (j,l) in enumerate(val)
        if l==o
            out += 2^(n-j)
        end
    end
    return out
end

function parse_ticket(val::String, o1::Char='B', o2::Char='R')
    rowstr = val[1:7]
    colstr = val[8:end]
    
    row = todec(rowstr, o1)
    col = todec(colstr, o2)
    return (row, col, 8*row+col)
end

input = loaders.listloader("input", String)

#########

println("Part 1: highest seat ID?")

seats = parse_ticket.(input)
ids = [s[3] for s=seats]
println( maximum(ids) )

#########

println("Part 2: which seat are we in? (missing one)")
sort!(ids)
loc = findall(diff(ids) .> 1)
println(ids[loc] .+ 1)
