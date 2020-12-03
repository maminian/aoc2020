push!(LOAD_PATH, "/home/moo/aoc2020/")
import loaders

# Approach 2: concatenate enough copies of the matrix.
# Then slice and count.
# (already used mod in approach 1)

input = loaders.listloader("input", String)

function count_bonks(   slope::Tuple{Int,Int}, 
                        field::Array{String,1} = input, 
                        start::Int=1, 
                        pattern::Regex=r"#")
    # number of concatenations needed is...
    # dependent on the slope.
    m = length(field)
    n = length(field[1])

    factor = Int( ceil( m/n * slope[2]/slope[1] ) )
    factor = max(1,factor)

    # make repeated field and calculate step.
    linear_field = join([repeat(row,factor) for row in field])
    step = factor*n*slope[1] + slope[2]

    return count(pattern, linear_field[start:step:end])
end

#
######################################
#

slopes = [(1,1),(1,3),(1,5),(1,7),(2,1)]

println("Part 1: ", count_bonks(slopes[2]))
println("Part 2: ", prod( count_bonks.(slopes) ))
