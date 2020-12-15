push!(LOAD_PATH, abspath("../"))
import loaders

struct BitMask
    v::Array    # 0/1 values to apply; 0 takes place of "X"
    m::BitArray # false/true values for actual application.
    f::BitArray # false/true values for presence of "X" ("floating")
end

function parse_input(input::Array)
    global masks = []
    global addresses = []
    global writes = []
    for (j,line) in enumerate(input)
        cmd,eq,arg = split(line, " ")
        if isequal(cmd, "mask")
            global masks = vcat(masks, [String(arg)])
            if (j!=1)
                global addresses = vcat(addresses, [writes])
                global writes = []  # reset writes
            end
        elseif isequal(cmd[1:3],"mem")
            memaddress = parse(Int, cmd[5:end-1])
            decval = parse(Int, arg)
            global writes = vcat(writes, (memaddress,decval))
        else
            println("\tBONK")
        end
        if (j==length(input))
            global addresses = vcat(addresses, [writes])
        end
    end
    return (masks,addresses)
end

function mdtv(val::String)   # mask digit to value
    dd = Dict("1"=>Int(1),"0"=>Int(0),"X"=>Int(0))
    return dd[val]
end
function mdtb(val::String)  # mask digit to boolean
    dd = Dict("1"=>true, "0"=>true, "X"=>false)
    return dd[val]
end
function mdtb_v2(val::String)  # mask digit to boolean; v2; "0" doesn't change value.
    # nominally force "X" values to zero to aid in summation later.
    dd = Dict("1"=>true, "0"=>false, "X"=>true)
    return dd[val]
end
function mdtf(val::String)  # mask digit to boolean, indicating floaters.
    dd = Dict("1"=>false, "0"=>false, "X"=>true)
    return dd[val]
end
function parse_bitmask(bm::String, part2::Bool=false)
    stringarr = String.(split(bm,""))
    if !part2
        return BitMask(mdtv.(stringarr), mdtb.(stringarr),mdtf.(stringarr))
    else
        return BitMask(mdtv.(stringarr), mdtb_v2.(stringarr),mdtf.(stringarr))
    end
end
function parse_assignment(memassigns::Array)
    # returns array of tuples of addresses and associated (nominal) bitmasks
    # given by memory assignment instructions.
    global assignments = []
    for mt in memassigns
        address,val_dec = mt
        val_bin = string(val_dec, base=2)
        val_bin = lpad(val_bin, 36, "0")
        stringarr = String.(split(val_bin,""))
        atuple = (address,BitMask(mdtv.(stringarr), trues(36), falses(36)))
        global assignments = vcat(assignments, [atuple] )
    end
    #return Dict(address=>BitMask(mdtv.(stringarr), trues(36)))
    return assignments
end
function parse_assignment(memassigns::Array, bitmask::BitMask)
    # returns array of tuples of addresses and associated (nominal) bitmasks
    # given by memory assignment instructions.
    # 
    # this time, the mask needs to respect the associated bitmask's new filter
    # so that "X" values will remain at zero (to help with summation later)
    global assignments = []
#    for (mt,bm) in zip(memassigns, bitmasks)
    for mt in memassigns
        address,val_dec = mt
        val_bin = string(val_dec, base=2)
        val_bin = lpad(val_bin, 36, "0")
        stringarr = String.(split(val_bin,""))

        xmask = .!bitmask.f
        atuple = (address,BitMask(mdtv.(stringarr), xmask, falses(36)))
        global assignments = vcat(assignments, [atuple] )
    end
    #return Dict(address=>BitMask(mdtv.(stringarr), trues(36)))
    return assignments
end
function apply!(memory::Dict, assignments::Array, mask::BitMask)
    # note assignments is an array of bitmasks whose masks are all true.
    # order matters.
    for at in assignments
        allocated = (at[1] in keys(memory))
        if !allocated
            memory[at[1]] = zeros(Int,36)
        end
        memory[at[1]][at[2].m] = at[2].v[at[2].m]
        memory[at[1]][mask.m] = mask.v[mask.m]
    end
end
function apply!(memory::Dict, assignments::Array, mask::BitMask, flm::Dict)
    # note assignments is an array of bitmasks whose masks are all true.
    # order matters.
    for at in assignments
        allocated = (at[1] in keys(memory))
#        if !allocated
#            memory[at[1]] = zeros(Int,36)
#        end
        memory[at[1]] = zeros(Int,36)
        # mask values marked as 1 need to update memory values with 1.
        # mask values marked as X need to update memory values with 0. (my convention)
        # mask values marked as 0 need to keep memory untouched.
        memory[at[1]][ mask.v .== 1 ] .= 1
        flm[at[1]][ mask.f ] .= true
        tochange = .!mask.f .& (mask.v .== 0)
        memory[at[1]][ tochange ] = at[2].v[ tochange ]

    end
end
function printmem(memory::Dict)
    kk = convert.(Int, keys(memory))
    kk = sort(kk)
    for k in kk
        println(k," => ", join(memory[k],""))
    end
end
function printmem(memory::Array)
    println(join(memory,""))
end
function printmem(memory::BitArray)
    println(join(Int.(memory),""))
end
function printmem2(memory::Dict)
    kk = convert.(Int, keys(memory))
    kk = sort(kk)
    for k in kk
        println(k," => ", join(memory[k],""))
    end
end
function mem2dec(mem::Array)
    return parse(Int, join(mem, ""),base=2)
end
    
#
############################################################
#

input = loaders.listloader("input", String)
masks,addresses = parse_input(input)

memory = Dict()

bms = parse_bitmask.(masks)
adms = parse_assignment.(addresses)

for (bm,adm) in zip(bms,adms)
    apply!(memory, adm, bm)
#    printmem(memory)
end
printmem(memory)

sumval = 0
for k in keys(memory)
    global sumval += mem2dec(memory[k])
end

println(sumval)

########################

println("Part 2")

memory2 = Dict()
flmory = Dict()

bms2 = parse_bitmask.(masks,true)
adms2 = parse_assignment.(addresses,bms2)

for (bm2,adm2) in zip(bms2,adms2)
    for (addr,abm) in adm2
        allocated = (addr in keys(flmory))
        if !allocated
            global flmory[addr] = falses(36)
        end
    end
    apply!(memory2, adm2, bm2, flmory)
#    printmem(memory)
end

# modify sumval accounting for floaters.
# supposing k floaters for a memory value, 
# 
sumval = 0
for addr in keys(memory2)
    k = sum(flmory[addr])
    term = 2^k*mem2dec(memory2[addr])
    if k>0
        # going heavily based on the visual example...
        # floating memory contributes one order smaller in count due to 
        # exploring all combinations (0,1)^k and linearity of addition.
        term += 2^(k-1)*mem2dec(Int.(flmory[addr]))
    end
  
    println(addr, "\t", term)
    global sumval += term
end
println(sumval)
