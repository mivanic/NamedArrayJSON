module NamedArrayJSON
using JSON, NamedArrays
export readJSON, writeJSON

function writeJSON(data, filename)

    # Create a new dictionary where data and set names are separate
    data_out = Dict()
    for k ∈ keys(data)
        if size(data[k]) == () || data[k] isa Vector{String}
            data_out = merge(data_out, Dict(
                k => Dict(
                    "data" => data[k]
                )
            ))
        else
            data_out = merge(data_out, Dict(
                k => Dict(
                    "data" => reshape(data[k], prod(size(data[k]))),
                    "sets" => names(data[k])
                )
            ))
        end

    end

    # Write it into a JSON file
    open(filename, "w") do f
        JSON.print(f, data_out)
    end

end

function readJSON(filename)

    # Read a JSON file
    datain = JSON.parsefile(filename)

    # Set up an empty dictionary
    dataout = Dict()

    # Loop through all keys in the JSON we read in
    for k ∈ keys(datain)
        # See if there are sets defined
        if "sets" ∈ keys(datain[k])
            # If there is a single set, we need to interpert the JSON set differently
            if length(datain[k]["sets"]) == 1
                dataout = merge(dataout, Dict(Symbol(k) => NamedArray(reshape(convert(Vector{Float64}, datain[k]["data"]), map(length, datain[k]["sets"])...), datain[k]["sets"][1])))
            else
                println(k)
                dataout = merge(dataout, Dict(Symbol(k) => NamedArray(reshape(convert(Vector{Float64}, datain[k]["data"]), map(length, datain[k]["sets"])...), datain[k]["sets"])))
            end
        else
            dataout = merge(dataout, Dict(Symbol(k) => datain[k]["data"]))
        end
    end

    return dataout
end


end
