push!(LOAD_PATH, abspath("../"))
import loaders

# CELLULAR AUTOMATA, round 2

tonum = Dict(
'#'=>1,
'.'=>0,
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

function get_nbrs(state::Array{Int,3},ii,jj,kk)
    il,ir = ii-1,ii+1
    jl,jr = jj-1,jj+1
    kl,kr = kk-1,kk+1
    nbrs = state[il:ir, jl:jr,kl:kr]
    nbrs = nbrs[:]  # flatten
    nbrs = vcat(nbrs[1:13], nbrs[15:end]) # remove center
    return nbrs
end
function get_nbrs(state::Array{Int,4},ii,jj,kk,ll)
    il,ir = ii-1,ii+1
    jl,jr = jj-1,jj+1
    kl,kr = kk-1,kk+1
    ll,lr = ll-1,ll+1
    nbrs = state[il:ir, jl:jr, kl:kr, ll:lr]
    nbrs = nbrs[:]  # flatten
    # size 81; center at idx 41
    nbrs = vcat(nbrs[1:40], nbrs[42:end]) # remove center
    return nbrs
end
function iter(state::Array{Int,3})
    newstate = copy(state)
    for i=2:size(state,1)-1
        for j=2:size(state,2)-1
            for k=2:size(state,3)-1
                nbrs = get_nbrs(state,i,j,k)
                nbcount = sum(nbrs)
                if state[i,j,k]==0 && (nbcount==3)
                    newstate[i,j,k] = 1
                elseif state[i,j,k]==1 && ((nbcount<2) || (nbcount>3))
                    newstate[i,j,k] = 0
                end
            end
        end
    end
    return newstate
end
function iter(state::Array{Int,4})
    # lol
    newstate = copy(state)
    for i=2:size(state,1)-1
        for j=2:size(state,2)-1
            for k=2:size(state,3)-1
                for l=2:size(state,4)-1
                    nbrs = get_nbrs(state,i,j,k,l)
                    nbcount = sum(nbrs)
                    if state[i,j,k,l]==0 && (nbcount==3)
                        newstate[i,j,k,l] = 1
                    elseif state[i,j,k,l]==1 && ((nbcount<2) || (nbcount>3))
                        newstate[i,j,k,l] = 0
                    end
                end
            end
        end
    end
    return newstate
end

####
println("Part 1")
input = loaders.listloader("input", String)
state = toint(input, tonum)

(nx,ny) = size(state)
N = max(nx,ny)*4
oidx = Int(floor(N/2))
xl = oidx - Int(floor(nx/2))
yl = oidx - Int(floor(ny/2))
z0 = oidx

# embed initial state in larger container
universe = zeros(Int, N,N,N)
universe[xl:xl+nx-1,yl:yl+ny-1,z0] = state

for i=1:6
    global universe = iter(universe)
    println(i)
end
println("Active blobs: ", sum(universe))


println("\nPart 2.. repeat for 4d space.")
println("Julia's multiple dispatch really useful here... ignoring my bad coding practices")

# embed initial state in larger container
w0 = oidx
universe4 = zeros(Int, N,N,N,N)
universe4[xl:xl+nx-1,yl:yl+ny-1, z0,w0] = state

for i=1:6
    global universe4 = iter(universe4)
    println(i)
end
println("Active blobs: ", sum(universe))
