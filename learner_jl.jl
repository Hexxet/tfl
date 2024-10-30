using DataStructures

struct ObservationTable
    A::Set{Char}
    S::Vector{String}
    E::Vector{String}
    T::DefaultDict{String, Dict{String, Bool}}
    cache::Dict{String, Bool}
    nodes::Int
end

function ObservationTable(alphabet::Set{Char}, nodes::Int)
    return ObservationTable(alphabet, [""], [""], DefaultDict{String, Dict{String, Bool}}(() -> Dict{String, Bool}()), Dict{String, Bool}(), nodes)
end

function cached_membership(table::ObservationTable, word::String)
    if haskey(table.cache, word)
        return table.cache[word]
    else
        result = membership(word)
        table.cache[word] = result
        return result
    end
end

function update(table::ObservationTable)
    low_s = [s * a for s in table.S, a in table.A if s * a ∉ table.S && length(s * a) ≤ table.nodes]
    for s in union(table.S, low_s)
        if length(table.T[s]) == length(table.E)
            continue
        end
        for e in table.E
            table.T[s][e] = cached_membership(table, s * e)
        end
    end
end

function check_closedness(table::ObservationTable)
    up_rows = [table.T[s] for s in table.S]
    low_s = [s * a for s in table.S, a in table.A if s * a ∉ table.S && length(s * a) ≤ table.nodes]
    for s in low_s
        if !(table.T[s] in up_rows)
            return false, s
        end
    end
    return true, nothing
end

function print_table(table::ObservationTable)
    header = ["S/E"; table.E...]
    println(join(header, "\t"))
    for s in table.S
        row = [s]
        for e in table.E
            push!(row, string(get(table.T[s], e, "")))
        end
        println(join(row, "\t"))
    end
    println("-"^40)
    low_s = [s * a for s in table.S, a in table.A if s * a ∉ table.S]
    for s in low_s
        row = [s]
        for e in table.E
            push!(row, string(get(table.T[s], e, "")))
        end
        println(join(row, "\t"))
    end
end

function equivalence(table::ObservationTable)
    print_table(table)
    println("Is it equivalent (yes/no)? ")
    is_equivalent = readline()
    if is_equivalent == "yes"
        return true, ""
    else
        println("Enter counter example: ")
        counter_example = readline()
        return false, counter_example
    end
end

function membership(word::String)
    println("Is this \"$word\" part of the language (1/0)? ")
    is_membership = readline()
    if is_membership == "1"
        return true
    else
        return false
    end
end

function read_parameters(filename::String)
    open(filename, "r") do file
        line = strip(readline(file))
        nodes, exits = split(line) .|> x -> parse(Int, x)
        return nodes, exits
    end
end

function lstar(alphabet::Set{Char})
    nodes, exits = read_parameters("parameters.txt")
    observation_table = ObservationTable(alphabet, nodes)
    update(observation_table)

    while true
        is_closed, s = check_closedness(observation_table)
        if !is_closed
            push!(observation_table.S, s)
            update(observation_table)
            continue
        end

        is_equivalent, counter_example = equivalence(observation_table)
        if !is_equivalent
            for i in 1:length(counter_example)
                push!(observation_table.E, counter_example[i:end])
            end
            update(observation_table)
            continue
        end

        return print_table(observation_table)
    end
end

lstar(Set(['a', 'b']))