#
#    byr (Birth Year)
#    iyr (Issue Year)
#    eyr (Expiration Year)
#    hgt (Height)
#    hcl (Hair Color)
#    ecl (Eye Color)
#    pid (Passport ID)
#    cid (Country ID)
#

push!(LOAD_PATH, "/home/moo/aoc2020/")
import loaders

# need to 
# (a) load all passwords; separating factor is a double newline.
# (b) Assign to struct, and identify empty fields.

function check_pass!(p::Dict, required::Array{String,1}=["byr","iyr","eyr","hgt","hcl","ecl","pid"])
    # not a flexible setup. whatever.
    p["field"] = [p[f]!="" for f=required]
    p["valid"] = all(p["field"])
    return
end

function parse_passport(obj::String)
    # input: array of strings.
    # output: dictionary.
    
    passport = Dict(
        "byr" => "",
        "iyr" => "",
        "eyr" => "",
        "hgt" => "",
        "hcl" => "",
        "ecl" => "",
        "pid" => "",
        "cid" => "",
        "field" => zeros(Bool,7),
        "valid" => false
    )

    fields = split(obj)

    for f in fields
        if f==""
            continue
        end
        kv = split(f, ":")
#        setproperty!(passport,Symbol(kv[1]),kv[2])
        passport[kv[1]] = String(kv[2])
    end

    check_pass!(passport)

    return passport
end

function isvalid(passport::Dict, field::String="valid")
    return passport[field]
end

function check_byr(p::Dict, debug::Bool=false)
    byr=p["byr"]
    if length(byr)==0
        if debug
            println("byr missing: ",byr)
        end
        return false
    elseif typeof( match(r"^[0-9]{4}$",byr) ) != RegexMatch
        if debug
            println("byr invalid: ",byr)
        end
        return false
    else
        valid_yr = 1920 <= parse(Int,byr) <= 2002
        if !valid_yr && debug
            println("byr invalid: ",byr)
        end
        return valid_yr
    end
end

function check_iyr(p::Dict, debug::Bool=false)
    iyr=p["iyr"]
    if length(iyr)==0
        if debug
            println("iyr missing: ",iyr)
        end
        return false
    elseif typeof( match(r"^[0-9]{4}$",iyr) ) != RegexMatch
        if debug
            println("iyr invalid: ",iyr)
        end
        return false
    else
        valid_yr = 2010 <= parse(Int,iyr) <= 2020
        if !valid_yr && debug
            println("iyr invalid: ",iyr)
        end
        return valid_yr
    end
end

function check_eyr(p::Dict, debug::Bool=false)
    eyr=p["eyr"]
    if length(eyr)==0
        if debug
            println("eyr missing: ",eyr)
        end
        return false
    elseif typeof( match(r"^[0-9]{4}$",eyr) ) != RegexMatch
        if debug
            println("eyr invalid: ",eyr)
        end
        return false
    else
        valid_yr = 2020 <= parse(Int,eyr) <= 2030
        if !valid_yr && debug
            println("eyr invalid: ", eyr)
        end
        return valid_yr
    end
end

function check_hgt(p::Dict, debug::Bool=false)
    hgt = p["hgt"]
    if length(hgt)==0
        if debug
            println("hgt missing: ",hgt)
        end
        return false
    end

    hgt_pat = r"^([0-9]{1,})(cm|in)$"
    rm = match(hgt_pat, hgt)
    if typeof(rm)==RegexMatch
        val = parse(Int,rm[1])
        if rm[2]=="cm"
            valid_hgt = 150<=val<=193
        elseif rm[2]=="in"
            valid_hgt = 59<=val<=76
        else
            println("bonk")
        end
    else
        valid_hgt = false
    end

    if !valid_hgt && debug
        println("hgt invalid: ",hgt)
    end
    return valid_hgt
end

function check_hcl(p::Dict, debug::Bool=false)
    hcl = p["hcl"]

    hcl_pat = r"^\#[0-9a-f]{6}$"
    rm = match(hcl_pat, hcl)
    valid_hcl = typeof(rm)==RegexMatch

    if !valid_hcl && debug
        println("hcl invalid: ",hcl)
    end
    return valid_hcl
end

function check_ecl(p::Dict, debug::Bool=false,allowed::Array{String,1}=["amb","blu","brn","gry","grn","hzl","oth"])
    ecl = p["ecl"]
    # no need to check length
    valid_ecl = (ecl in allowed)
    if !valid_ecl && debug
        println("ecl invalid: ",ecl)
    end
    return valid_ecl
end

function check_pid(p::Dict, debug::Bool=false)
    pid = p["pid"]
#    pid_pat = r"[0-9]{9}"
    pid_pat = r"^[0-9]{9}$" # a few hours wasted here.
    rm = match(pid_pat,pid)
    valid_pid = typeof(rm)==RegexMatch
    if !valid_pid && debug
        println("pid invalid: ",pid)
    end
    return valid_pid
end

function isvalid2(p::Dict, debug::Bool = false)  # passport
    checks = [
        check_byr(p,debug),
        check_iyr(p,debug),
        check_eyr(p,debug),
        check_hgt(p,debug),
        check_hcl(p,debug),
        check_ecl(p,debug),
        check_pid(p,debug)
    ]
    if sum(checks)!=length(checks) && debug
        println("=======================")
    end
    return checks

end

#
#############################################
#

lines = loaders.listloader("input", String)

pstrings = []
passports = []
l=1
valid_count=0
for (r,line) in enumerate(lines)
    if line=="" || r==length(lines)
        pstring = join(lines[l:r], " ")
        passport = parse_passport(pstring)

        if isvalid(passport)
            global valid_count += 1
        end

        append!(passports, [passport])
        global l=copy(r+1)
    end
end

println("Part 1: how many valid passes?")
checks1 = isvalid.(passports)
println( valid_count )

println("Part 2: how many valid passes with extra conditions?")
checks2 = isvalid2.(passports);
println( sum( all.(checks2), dims=1) )

