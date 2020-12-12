push!(LOAD_PATH, abspath("../"))
import loaders

input = loaders.listloader("input", Int128)
input = vcat(input, Int128(0), Int128(maximum(input)+3))

####################
# part 1

dd = diff( sort(input) )
println("Part 1: ", sum(dd .== 1)*sum(dd .== 3))

####################
# part 2

# cache combinations for subsequences of ones
combos = zeros(BigInt, sum(dd.==1))   
combos[1:4] = [1,2,4,7]
for i=5:length(combos)
    combos[i] = 2*combos[i-1] - combos[i-4]
end

l=1
answer = BigInt(1)
for (r,v) in enumerate( dd )
    if (v==3)
        consec = r-l
        if consec > 0
            global answer *= combos[consec]
        end
        global l = r+1
    end
end

println("Part 2: ", answer)
