push!(LOAD_PATH, abspath("../"))
import loaders

using LinearAlgebra

input = loaders.listloader("input", String)

# make directed graphs or something.

re_parent_bag = r"^(.+) bags contain "
re_children_bag = r"([0-9]+) ([a-z ]+) bags?[.,]"

function parse_line(line::String,parent::Regex=re_parent_bag, child::Regex=re_children_bag)
    parent_rm = match( re_parent_bag, line )
    children_rm = eachmatch( re_children_bag, line )

    return (parent_rm, children_rm)
end

function build_dictionary(all_entries)
    global idx = 0
    global n = length(all_entries)
    
    global references = Dict() # assignment of bags to integers
    
    global counts = zeros(Float64, n,n)
    
    for (i,(p,c)) in enumerate(all_entries)
        # each entry is a (parent_rm, children_rm) tuple
        # children_rm itself is an iterator of regex matches (a type and number of bag found)

        parent = String(p[1])
        eval = (parent) in (keys(references))
        if !eval
            global idx += 1
            global references[parent] = idx
        end
        # leaving this here for historical record.
        # the (i,i) entry is useful for part 1, but not part 2. 
        # I finally opted to leave it out and add the identity when doing part 1.
        # (part 2 is follows the "modify this matrix slightly" theme; by transposing.)
        # global counts[references[parent],references[parent]] = 1
        
        for match in c
            child = String(match[2])
            eval = (child) in (keys(references))
            if !eval
                global idx += 1
                global references[child] = idx
            end
            
            global counts[references[parent],references[child]] = parse(Float64,match[1])
        end
    end
    
    return (references, counts)
end

#
##############################
#

ref,C = build_dictionary( parse_line.(input) )

n = size(C,1)

#
##############################
#

println("\nPart 1: how many types of bags could eventually have a gold shiny?")

# matrix C does not re-circulate existing values - necessary for part 1.
C1 = C + I  # Identity matrix; magical constant in Julia's LinearAlgebra package.

####
v = zeros(n, 1)
v[ref["shiny gold"]] = 1
prev=Int128(-1)
j=0
while (sum(v.!=0)-1!=prev) && j<=50 # arbitrary cutoff
    global prev = sum(v.!=0)-1
    global v=C1*v
    global v = sign.(v) # counting; eliminate magnitude.
    global j += 1
    println( "Step ", j, " nodes visited (excl. origin): ", sum(v.!=0)-1 )
end

#
##############################
#

println("\nPart 2: how many total bags used when carrying a gold shiny? (minus gold shiny)")

# part 2: v2 tracks active bags; accum tracks all bags used.
# critical that v2 is used for the graph traversal for counting.
v2 = zeros(Int128, n, 1)
v2[ref["shiny gold"]] = 1

accum = zeros(Int128, n, 1)

C2 = transpose(C)  # reverse flow of directed graph

prev=Int128(-1) # tracking change
j=0
while (sum(accum)!=prev) && j<=50 # arbitrary cutoff
    global v2=C2*v2
    global prev = sum(accum)
    global accum += v2  # itemized bag tally... didn't end up being used.
    global j+= 1
    println( "Step ", j, " bags accumulated (excl. origin): ", Int128(sum(accum)) )
end
