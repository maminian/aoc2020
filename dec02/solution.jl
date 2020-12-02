push!(LOAD_PATH, "/home/moo/aoc2020/")
import loaders

# read a list of passwords with assorted "policies"
# and evaluate which ones are valid according to the 
# provided rules.

# use a structure which will parse the input format
# and expose useful information.
struct Password
    ismatch :: Bool
    rawstr :: String
    minc :: Int
    maxc :: Int
    char :: Char
    pass :: String
end

# regex for input pattern
pass_pattern = r"([0-9]+)-([0-9]+) ([a-z]): ([a-z]{1,})"

# parse a given input
function pwparse(strline :: String, pattern :: Regex = pass_pattern)
    # parse a string for given pattern.
    rm = match(pattern, strline)
    if typeof(rm) == RegexMatch
        return Password(
            true,
            strline,
            parse(Int,rm[1]),
            parse(Int,rm[2]),
            Char(rm[3][1]),
            rm[4]
        )
    else
        # failed to match
        return Password(
            false,
            "",
            0,
            0,
            "",
            ""
        )
    end
end

####
## For identifying consecutive letters
#
#using Printf
#function is_valid_pass(p :: Password)
#    pattern = Regex( @sprintf("[%s]{%i,%i}",p.char,p.minc,p.maxc) )
#    rm = match(pattern, p.pass)
#    if typeof(rm) == RegexMatch
#        println(p)
#        return true
#    else
#        return false
#    end
#end

function is_valid_pass(p :: Password)
    # version 1: is the total number of letters within the bounds?
    lettercount = sum([p.char==pi for pi=p.pass])
    return (lettercount >= p.minc && lettercount <= p.maxc)
end

function is_valid_pass2(p :: Password)
    # version 2: does the letter show in one, or the other,
    # but not both positions? (xor)
    c1 = p.pass[p.minc]==p.char
    c2 = p.pass[p.maxc]==p.char
    return xor(c1,c2)
end

#
###################################################
#

lines = loaders.listloader("input", String);

passes = pwparse.(lines);

hits1 = is_valid_pass.(passes);
hits2 = is_valid_pass2.(passes);

println("Silver star")
println("=======================")
println("Number of valid passes: ", sum(hits1))

println("\n")

println("Gold star")
println("=======================")
println("Number of valid passes: ", sum(hits2))


