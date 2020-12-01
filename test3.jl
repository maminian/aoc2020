# objects?

# seems it's bad practice/not allowed to have 
# member functions inside structs.
# so it's sort of back to old fortran land
struct Moo
    p::Int
    xl<:Float32
end

function setter(l::Moo,pval,xlval)
    l.p = pval
    l.xl = xlval
end


ell = Moo()
setter(ell, 3, [2,5])
