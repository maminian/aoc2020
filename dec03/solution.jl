push!(LOAD_PATH, "/home/moo/aoc2020/")
import loaders

# day 3
# structure of trees, periodic in columns

input = loaders.listloader("input", String)

# convert map to 0/1.
m = length(input)
n = length(input[1])
A = zeros(Int,m,n)

for i=1:m
    line = input[i]
    for j=1:n
        if line[j]=='#'
            A[i,j] = 1
        end
    end
end

# part 1: given loaded map, how many trees would you encounter?
maneuver = (1,3)    # right 3, down 1. Remember to respect periodicity.

bonk_count=0
x,y=1,1 # careful: matrix coords

while x<=m
    println([x,y])
    if A[x,y]==1
        global bonk_count += 1
        println("bonk")
    end

    global x += maneuver[1]
    global y = mod(y-1+maneuver[2],n)+1 # wrap around if needed
end

println("Part 1: \n ======================")
println( bonk_count )

# part 2: repeat for the prescribed slopes.
# careful, coordinates are reversed from how they describe
# ("right" is the second coord).
slopes = [(1,1),(1,3),(1,5),(1,7),(2,1)]
counts = zeros(Int128,size(slopes))

for (k,maneuver) in enumerate(slopes)
    global bonk_count=0
    global x,y=1,1 # careful: matrix coords

    while x<=m
#        println([x,y])
        if A[x,y]==1
            global bonk_count += 1
#            println("bonk")
        end

        global x += maneuver[1]
        global y = mod(y-1+maneuver[2],n)+1
    end
    counts[k] = bonk_count
end

println("Part 2: \n ======================")
println( prod(counts) )

