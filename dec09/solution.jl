push!(LOAD_PATH, abspath("../"))
import loaders

# look at short recurrent sequences. Identify space of possible 
# sums of numbers and identify when an entry in the 
# sequence doesn't fit this framework.

mutable struct Sequence
    n::Int          # length
    p::Int          # length of preamble
    s::Array        # array of terms
    valid::Array    # bitarray identifying valid terms.
    m::Int          # number of combinations to find
    t1::Array       # ptr for term 1
    t2::Array       # ptr for term 2
    t3::Array       # value for s[t1] + s[t2]
end

function initialize(input, p::Int=25)
    n = length(input)
    m = Int128(p*(p-1)/2)
    valids = falses(n)
    valids[1:p] = trues(p)
    seq = Sequence(n,p,input,valids,m,zeros(Int128,m),zeros(Int128,m),zeros(Int128,m))
    return seq
end

function build_space!(seq::Sequence)
    global idx=0
    for i=1:seq.p
        for j=i+1:seq.p
            global idx+=1
            seq.t1[idx] = i
            seq.t2[idx] = j
            seq.t3[idx] = seq.s[i] + seq.s[j]
        end
    end
end

function eval!(seq::Sequence, i::Int)
    # CAREFUL - DEPENDS ON STATE
    # MUST EVALUATE BEFORE UPDATING MEMORY
    seq.valid[i] = (seq.s[i] in seq.t3)
    return
end

function replace!(seq::Sequence, i::Int)
    # identify first entries to be replaced, then second.
    # update the sum by adding the difference.
    
    iold = i - seq.p
    diff = seq.s[i] - seq.s[iold]
    global cnt=0
    for k=1:seq.m
        if (seq.t1[k]==iold)
            seq.t1[k] = i
            seq.t3[k] += diff
            global cnt += 1
        elseif (seq.t2[k]==iold)
            seq.t2[k] = i
            seq.t3[k] += diff
            global cnt += 1
        end
        if (cnt==seq.p-1)   # sometimes may save time.
            break
        end
    end
    return
end

#
#########
#

input = loaders.listloader("input", Int128)
# set p=5 if testing this.
#input = loaders.listloader("input_mini", Int128)
#input = vcat( 20, collect(1:19), collect(21:25), 45 ) 

seq = initialize(input)
build_space!(seq)

println("Part 1.....")

for i=seq.p+1:seq.n
    eval!(seq, i)
    replace!(seq, i)
end

bad_idx = findall( .!seq.valid )[1]
bad_num = seq.s[bad_idx]
println(bad_num)

println("\nPart 2...")
# identify contiguous terms that sum to bad_num
# really don't think we can do iterative collapsing like with SUM2
# because the numbers aren't ordered.
# Unless there's something about the loose geometric growth that's happening.

terms = cumsum(seq.s[1:bad_idx-1])

l,r=-1,-1
for i=2:seq.n
    active = terms[i:end] .- terms[i-1]
    finds = findall( active .== bad_num )   # do this without another lookthrough?
    
    if length(finds)>0
        global l = i
        global r = finds[1] + i -1  # off-by-one... too lazy to work out why.
        println("(l, r, sum(s[l:r]), target)")
        println([l,r, sum(seq.s[l:r]), bad_num])
        break
    end
end
println("\nSum of minimum and maximum values in contiguous section:")
println(minimum(seq.s[l:r]) + maximum(seq.s[l:r]))
