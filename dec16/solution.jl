push!(LOAD_PATH, abspath("../"))
import loaders

mutable struct Field
    name::String
    lim::Tuple
end

function process_field(inp::String)
    thing = split(inp, ":")
    name = String( thing[1] )
    rest = String.(split(thing[2], " "))
    l1,r1 = split(rest[2], "-")
    l2,r2 = split(rest[4], "-")
    l1,r1,l2,r2 = parse.(Int,String.([l1,r1,l2,r2]))
    return Field(name, ((l1,r1),(l2,r2)) )
end
function process_ticket(inp::String)
#    return parse.(Int, String(split(inp, ",")) )
    return parse.(Int, String.(split(inp,",")))
end
function elementof(entry::Int, interval::Tuple{Int,Int})
    return ( (entry >= interval[1]) && (entry <= interval[2]) )
end
function elementof(entry::Int, field::Field)
    return ( elementof(entry,field.lim[1]) || elementof(entry,field.lim[2]) )
end
function elementof(entry::Array, field::Field)
    return [elementof(e,field) for e in entry]
end

function eval_matching(permutation, fields, V)
#    for (p,f) in zip(permutation,fields)
        #println( sum(elementof(V[p,:], f)) )
#    end
    return all( [ sum(elementof(V[p,:],f))==size(V,2) for (p,f) in zip(permutation,fields)] )
end

# binary integer optimization, broadly...
# hopefully it doesn't come to that.

input = loaders.listloader("input", String)

global collection = []
global i=1
for (j,line) in enumerate(input)
    if (length(line)==0)
        global collection = vcat(collection, [input[i:j-1]])
        global i=j+1
    end
    if j==length(input)
        global collection = vcat(collection, [input[i:j]])
    end
end

# collection should have three entries
# first is collection of valid ranges for various objects
#   restrictions always come as the union of two intervals
#   format: name: a-b or c-d
# second is a header, followed by my ticket
#   format; a,b,c,d,...
# third is a header, followed by all nearby tickets.
#   format: a,b,c,d,...

fields = process_field.(collection[1])
mine = process_ticket(collection[2][2])
nearby = process_ticket.(collection[3][2:end])

nf = length(fields)

println("part 1: ticket scanning error rate?\n====================")
println("just do a lazy loop over nearby and loop over the fields.")
global tser = 0    # ticket scanning error rate
global valid = false
global mask = trues(length(nearby))
for (i,ticket) in enumerate(nearby)
    for entry in ticket
        global valid=false
        for f in fields
            if elementof(entry, f)
                global valid = true
                break
            end
        end
        if !valid
            mask[i] = false
            global tser += entry
        end
    end
end

println("Total scanning error rate: ", tser)
valid_tix = nearby[mask]
nt = sum(mask)
global V = zeros(Int,(nf,nt))
for (j,vi) in enumerate(valid_tix)
    global V[:,j] = vi
end

println("\npart 2: find a perfect matching among viable tickets.\n==================")

# M: matching matrix; entry (i,j)=1 if field i conditions 
# match perfectly for row j of V.
global M = zeros(Int, (nf,nf))
for (i,f) in enumerate(fields)
    for j=1:nf
        if sum( elementof(V[j,:], f) )==nt
            M[i,j] = 1
        end
    end
end

# 'greedy' matching algorithm.
# at each step, identify the field which has the fewest 
# viable matches, then (arbitrarily) take the first viable 
# entry in the tickets which is viable for that field.
#
# ...then deflate.
perm_f = collect(1:nf)
perm_v = collect(1:nf)
mask_f = trues(nf)
mask_v = trues(nf)
for i=1:nf
    # identify fields not assigned
    not_assigned_field = findall(mask_f)
    not_assigned_tix = findall(mask_v)
    
    # identify the field which has the fewest viable options in V; select it.
    viable_count_rel = sum( M[not_assigned_field,not_assigned_tix], dims=2 )[:]
    o = sortperm(viable_count_rel)
    
    # take the first of the viable options (arbitrary choice)
    winner_field = not_assigned_field[o[1]]
    options_local = findall(M[winner_field,not_assigned_tix].==1)
    winner_v = not_assigned_tix[options_local[1]]
    
    # save the matching.
    perm_f[i] = winner_field
    perm_v[i] = winner_v
    
    # deflate
    mask_f[winner_field] = false
    mask_v[winner_v] = false
end

if eval_matching(perm_v, fields[perm_f], V)
    println("Successful matching found!")
else
    println("oh no.")
end

# evaluate product of numbers associated with "departure"
global my_prod = 1
for (pv,pf) in zip(perm_v, perm_f)
    if length(fields[pf].name) < 9
        continue
    elseif fields[pf].name[1:9] == "departure"
        println(fields[pf].name, " : ", mine[pv])    # why not
        global my_prod *= mine[pv]
    end
end

println("Product: ",my_prod)