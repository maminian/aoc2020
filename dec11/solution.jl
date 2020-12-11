push!(LOAD_PATH, abspath("../"))
import loaders

# CELLULAR AUTOMATA
#    If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
#    If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
#    Otherwise, the seat's state does not change.

tonum = Dict(
'L'=>0,
'#'=>1,
'.'=>-1,
)

function toint(input::Array,dd::Dict)
    d1 = length(input)
    d2 = length(input[1])
    state = zeros(Int,d1,d2)
    for (i,row) in enumerate(input)
        for (j,c) in enumerate(row)
            state[i,j] = tonum[c]
        end
    end
    return state
end

function get_nbrs(state::Array{Int,2},ii,jj)
    il = max(ii-1,1)
    ir = min(ii+1,size(state,1))
    jl = max(jj-1,1)
    jr = min(jj+1,size(state,2))
#    nbrs = state[il:ir, jl:jr]
    nn = (ir-il+1)*(jr-jl+1)-1
    nbrs = zeros(Int,nn)
    global idx = 0
    for (k,ki) in enumerate(il:ir)
        for (l,lj) in enumerate(jl:jr)
            if (ki==ii) && (lj==jj)
                continue
            else
                global idx += 1
                nbrs[idx] = state[ki,lj]
            end
        end
    end
#    nbrs = vcat(nbrs[1:4],nbrs[6:end])
    
    return nbrs
end

function get_nbrs2(state::Array{Int,2},ii,jj)
    global m = size(state,1)
    global n = size(state,2)
    il = max(ii-1,1)
    ir = min(ii+1,size(state,1))
    jl = max(jj-1,1)
    jr = min(jj+1,size(state,2))

    nn = (ir-il+1)*(jr-jl+1)-1
    nbrs = zeros(Int,nn)
    global idx = 0

    for u=[-1,0,1]
        for v=[-1,0,1]
            if u==0 && v==0
                continue
            end
            chair = false
            cond = true
            global p=ii
            global q=jj
            while !chair && cond
                global p+=u
                global q+=v
                cond = (0<p) && (p<=m) && (0<q) && (q<=n)
                if cond
                    chair = (state[p,q]>=0)
                end
                if chair
                    idx += 1
                    nbrs[idx] = state[p,q]
                end
            end
        end
    end
    
    return nbrs
end

function iter(state::Array{Int,2},patience::Int=4,op=get_nbrs2)
    newstate = copy(state)
    for i=1:size(state,1)
        for j=1:size(state,2)
            if state[i,j]==-1
                continue
            end
            nbrs = op(state,i,j)
            seated = (state[i,j]==1)
            nc = sum(nbrs.>0)

            if seated && nc>=patience
                newstate[i,j] = 0
            elseif !seated && nc==0
                newstate[i,j] = 1
            end
        end
    end
    return newstate
end

####
println("Part 1, cellular automata")
input = loaders.listloader("input", String)
state0 = toint(input, tonum) # cleanup later
state = toint(input, tonum) # cleanup later

global sprev = copy(state)
global dsum = 1
global cnt=0
while dsum>0
    global state = iter(sprev,4,get_nbrs)
    changes = ((state) .!= (sprev))
    global dsum = sum(changes)
    global sprev = copy(state)
    global cnt += 1
#    println([cnt,dsum])
end

println("\tEquilibrium seats occupied: ",sum(state .== 1))


###
# part 2
println("\nPart 2, pewpew")
global sprev = copy(state0)
global dsum = 1
global cnt=0
while dsum>0
    global state = iter(sprev,5,get_nbrs2)
    changes = ((state) .!= (sprev))
    global dsum = sum(changes)
    global sprev = copy(state)
    global cnt += 1
#    println([cnt,dsum])
end

println("\tEquilibrium seats occupied: ",sum(state .== 1))
