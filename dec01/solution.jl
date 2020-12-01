# aoc day 1
# read list of numbers
# identify pair that sums to 2020

# made my own module for loading; expecting to do 
# a lot of it during AOC
push!(LOAD_PATH, "/home/moo/aoc2020/")
import loaders

numbers = loaders.listloader("input",Int128)

function solution1(x, target::Int128 = 2020)

    # silver star.
    # nothing fancy, just do a double for-loop.
    # Inner for-loop endpoints avoid double-checking combinations.
    if false    # don't care anymore
        for i=1:length(x)-1
            for j=i+1:length(x)
                if x[i] + x[j] == target
                    println("Found double!")
                    println("\tSum is: ",x[i]+x[j]')
                    println("\tProduct is: ",x[i]*x[j]')
                end
            end
        end
    end

    # gold star.
    # repeat, but for triples.
    # Inner for-loop endpoints avoid double-checking combinations.
    for i=1:length(x)-2
        for j=i+1:length(x)-1
            for k=j+1:length(x)
                if x[i] + x[j] + x[k] == target
                    println("Found triple!")
                    println("\tSum is: ",x[i]+x[j]+x[k]')
                    println("\tProduct is: ",x[i]*x[j]*x[k])
                    println("\tIndices: ",[i,j,k])
                    return [i,j,k]
                end
            end
        end
    end

    return false
end

function solution2(x, target::Int128 = 2020)
    # only care about gold star for this one.
    # this time, do outer two loops as before, but 
    # do a binary search on the innermost loop.

    order = sortperm(x)
    y = x[order]

    for i=1:length(y)-2
        for j=i+1:length(y)-1
            current = y[i] + y[j]
            if current >= target
                # already over the target number
                continue
            end

            ysub = y[j+1:length(y)]
            k = j + binary_search(ysub, target-current, true)

            if y[i]+y[j]+y[k] != target
                continue
            else
                success_message(y,i,j,k,order)
                return [order[i],order[j],order[k]]
            end
        end
    end

    return false
end

function solution3(x, target::Int128 = 2020)
    # only difference: clip the right end by considering current
    # after selecting i.

    order = sortperm(x)
    y = x[order]

    for i=1:length(y)-2
        current = y[i]
        if current >= target
            # move on if the list is already bigger than the target number
            continue
        end
        # identify a naive upper bound for upper number; require 2020 - y[j] >=0.
        ysub = y[i+1:length(y)]
        jmax = i + binary_search(ysub, target-current, true)
        jmax = min(jmax, length(y)-1)

        for j=i+1:jmax
            current = y[i] + y[j]
            if current >= target
                # already over the target number; move on
                continue
            end

            ysub = y[j+1:length(y)]
            k = j + binary_search(ysub, target-current, true)
            if y[i]+y[j]+y[k] != target
                continue
            else
                success_message(y,i,j,k,order)
                return [order[i],order[j],order[k]]
            end
        end
    end

    return false
end

function solution4(x, target::Int128 = 2020)
    # lol wikipedia
    # https://en.wikipedia.org/wiki/3SUM#Quadratic_algorithm
    order = sortperm(x)
    y = x[order]
    n = length(y)

    for i=1:n-1
        a = y[i]
        ll = i+1
        rr = n-1
        while (ll < rr)
            b = y[ll]
            c = y[rr]
            if (a+b+c == target)
                success_message(y,i,ll,rr,order)
                return true
            elseif (a+b+c > target)
                rr -= 1
            else
                ll += 1
            end
        end
    end
    return false
end

function success_message(y,i,j,k,order)
    println("Found triple!")
    println("\tSum is: ",y[i]+y[j]+y[k])
    println("\tProduct is: ",y[i]*y[j]*y[k])
#    io = inverse_perm(order)
    println("\tIndices: ",[order[i],order[j],order[k]])
    return
end

function binary_search(x,target,sorted::Bool)
    if ~sorted
        o = sortperm(x)
    else
        o = Vector(1:length(x))
    end
    
    l,r = 1,length(x)

    if target < x[o[l]]
        return o[l]
    elseif target > x[o[r]]
        return o[r]
    end

    c = Int128(floor((l+r)/2))
    while x[o[c]]!=target
        if l+1==r
            # number not in list... just give the left value.
            return o[r]
        end

        c = Int128(floor((l+r)/2))

        if (x[o[l]]-target)*(x[o[c]]-target) < 0
            # right endpoint replaced
            r = c
        else
            # left endpoint replaced
            l = c
        end
    end

    return o[c]
end

function inverse_perm(perm)
    # returns the inverse permutation of a given permutation.
    iperm = zeros(Int128,size(perm))
    for i=1:length(perm)
        iperm[perm[i]] = i
    end
    return iperm
end

##########
function compare(xx=numbers, target::Int128 = Int128(2020))
    println("\n\nTriple for-loop:")
    println("==========================================")
    ind1 = @time solution1(xx,target);

    println("\n\nDouble for-loop with binary search:")
    println("==========================================")
    ind2 = @time solution2(xx,target);

    println("\n\nBinary search, trimming inner for-loop:")
    println("==========================================")
    ind3 = @time solution3(xx,target);

    return sort(ind1)==sort(ind2)==sort(ind3)
#    return sort(ind2)==sort(ind3)
end



if true
    compare()
else
    # want to test out the approaches with theoretical 
    # speedups, using random (and larger) lists.
    using Random
    Random.seed!(2718281828)
    OHNO = rand(50:4e6, 50000)
    OHNO = convert(Array{Int128,1}, OHNO)
    compare(OHNO,Int128(4e5+4e4))
end

#println("\n===============================")
#println("\n\t\tbig input (100k values, target 9920044) \n")
#println("\n===============================")
#xx = loaders.listloader("bigboi",Int128)
#target = Int128(99920044)
#@time solution4(xx, target)

