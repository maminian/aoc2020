push!(LOAD_PATH, abspath("../"))
import loaders

# combinatorics of subsequences...

input = loaders.listloader("input", Int128)
input = vcat(Int128(0),input,Int128(maximum(input)+3))  # include implied head and tail

o = sortperm(input)

diffs = diff( input[o] )

onec = sum(diffs .== 1)
threec = sum(diffs .== 3)

println("\nPart 1\n================")
println("First two numbers are the counts; third is the product.")
println([onec, threec, onec*threec])

####################
#
# part 2

# Explicit formula for valid sequences of diff 1 ending 
# just before a jump size three, of length i. 
# 
# For example, 
# c[1]=1 represents number of subsequences of (1,4), 
# c[2]=2 represents number of subsequences of (1,2,5), 
# c[3]=4 represents number of subsequences of (1,2,3,6)

global cseq = zeros(Int128, onec)   # upper bound on consecutive ones
cseq[1:4] = [1,2,4,7]
for i=5:length(cseq)
    global cseq[i] = 2*cseq[i-1] - cseq[i-4]
end

global l=1
factors = []
for (r,v) in enumerate( diffs )
    if (v==3)
        consec = r-l
        if consec > 0
            global factors = vcat(factors, cseq[consec])
        end
        global l = r+1
    end
end

println("\nPart 2\n================")
println("Number of combinations:\n", prod(factors))
