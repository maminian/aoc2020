# collatz meme

function print_status(ii,val)
    println(ii,'\t',num)
end

num = 14
iter = 0
print_status(iter,num)

while num>1
    if mod(num,2)==1
        # odd number
        global num = 3*num+1
    else
        # even number
        global num = Int(num/2)
    end

    global iter += 1
    print_status(iter,num)
end
