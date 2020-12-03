push!(LOAD_PATH, "/home/moo/aoc2020/")
import loaders

# Approach 3: just build coordinates explicitly 
# in a vectorized way. Then access and count.

input = loaders.listloader("input", String)

function count_bonks(   slope::Tuple{Int,Int}, 
                        field::Array{String,1} = input, 
                        start::Int=1, 
                        pattern::Regex=r"#")
    
    m,n = length(input),length(input[1])

    xx = 1 : slope[1] : m
    yy = start : slope[2] : slope[2]*length(xx)

    # periodic in columns, but not rows. Clean up.
    mask = (xx .<= m)
    xx,yy = xx[mask],yy[mask]
    yy = mod.(yy .-1, n) .+ 1

    # accumulate spots visited and count
    return count(pattern, join([input[x][y] for (x,y) in zip(xx,yy)]) )
end

#
######################################
#

slopes = [(1,1),(1,3),(1,5),(1,7),(2,1)]

println("Part 1: ", count_bonks(slopes[2]))
println("Part 2: ", prod( count_bonks.(slopes) ))
