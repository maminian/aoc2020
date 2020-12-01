module loaders
export listloader

    function listloader(filename::String, dtype::DataType = Int64)
        # load input files which are simply a list of numbers.
        # Function will cast the read values (strings) to 
        # whatever datatype you ask for.
        # 
        # file reading partly following guide here:
        #  https://en.wikibooks.org/wiki/Introducing_Julia/Working_with_text_files


        # force absolute paths...
        if ~isabspath(filename)
            filename = abspath(filename)
        end

        # syntactic sugar; get the result of reading 
        # a file, casting datatypes, store result in x,
        # and automatically close the IO stream.
        x = open(filename) do file
            xstr = readlines(file)
            x = [parse(dtype,xi) for xi=xstr]
        end
        return x
    end

end
