push!(LOAD_PATH, abspath("../"))
import loaders

# constrained sequences...

input = loaders.listloader("input", Int128)
input = vcat(Int128(0),input)
#input = vcat(Int128(0),input,Int128(input[end]+3))

o = sortperm(input)

dd = diff( input[o] )
#dd = vcat(input[o[1]], dd)

onec = sum(dd .== 1)
threec = (1 + sum(dd .== 3))

println([onec, threec, onec*threec])

####################
#
# part 2

### Just leaving this here for github historians to appreciate
# how bad at recursion I am.
#

#global mem = Dict()
#mem[()] = 0
#mem[(1,)] = 1
#mem[(1,1)] = 2
#mem[(2,1)] = 2
#mem[(1,2)] = 2
#mem[(2,0)] = 
#mem[(0,2)] = 


#function countperm(seq)
#    global mem
#    if seq in keys(mem)
#        return mem[seq]
#    else
#        global allprod = 0
#        for i=1:length(seq)-1
#            left = seq[1:i]
#            right = seq[i+1:end]
#            global allprod += countperm(left) * countperm(right)
#        end
#    end
#    global mem[seq] = allprod
#    return allprod
#end

# Explicit formula for valid sequences of diff 1 ending 
# just before a jump size three, of length i. for example, 
# c[1]=1 represents subsequences of (1,4), 
# c[2]=2 represents subsequences of (1,2,5), 
# c[3]=4 represents subsequences of (1,2,3,6)

global cseq = zeros(Int128, length(input))
cseq[1:4] = [1,2,4,7]
for i=5:length(cseq)
    global cseq[i] = 2*cseq[i-1] - cseq[i-4]
end

global l=1
factors = []

# need to tack on ending to make loop work cleaner.
input2 = vcat(input,Int128(maximum(input)+3))
o2 = sortperm(input2)

diffs = diff(input2[o2])
global l=1

for (r,v) in enumerate( diffs )
    if (v==3)
        consec = r-l
        if consec > 0
            global factors = vcat(factors, cseq[consec])
        end
        global l = r+1
    end
end

println("Part 2\n================")
println(prod(factors))