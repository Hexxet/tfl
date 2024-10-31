# Лабораторная работа №2 / Планарный лабиринт

## Запуск
1. Запустите Julia REPL:
    ```
    julia
    ```
2. Пропишите следующие команды:
    ```
    using Pkg
    ]
    ```
3. В Pkg REPL выполните следующую команду:
    ```
    add DataStructures
    add JSON
    add HTTP
    ```
4. Выйдите из Pkg REPL нажав `Ctrl + C`, а затем выйдите из Julia:
   ```
   exit()
   ```
5. Запустите угадывателя:
    ```
    julia learner_jl.jl
    ```

## Реализация
В целом был реализован стандартный алгоритм L*, но с небольшими оптимизациями:
- Контрпример и все его суффиксы добавляются в суффиксы таблицы. Следовательно, проверка на непротиворечивость не нужна.
- Для уменьшения membership запросов сделан кэш.
- Так как угадыватель знает количество узлов в лабиринте, то можно предположить, что длина пути до выхода из лабиринта не будет превышать количество этих узлов. Так как если длина пути больше, то это означает, что или угадыватель попал в цикл, или он сильно заплутал.  

## Взаимодейсвие с МАТ
Работу с МАТ Никиты Нащекина ИУ9-52Б выполняют следующие функции:

```
function equivalence(table::ObservationTable)
    main_prefixes = "ε " * join(table.S, " ")
    low_s = [s * a for s in table.S, a in table.A if s * a ∉ table.S && length(s * a) ≤ table.nodes]
    non_main_prefixes = join(low_s, " ")
    suffixes = "ε " * join(table.E, " ")
    table_data = []
    for s in table.S
        for e in table.E
            push!(table_data, get(table.T[s], e, false) ? "1" : "0")
        end
    end
    for s in low_s
        for e in table.E
            push!(table_data, get(table.T[s], e, false) ? "1" : "0")
        end
    end
    table_str = join(table_data, " ")
    data = JSON.json(Dict(
        "main_prefixes" => main_prefixes,
        "non_main_prefixes" => non_main_prefixes,
        "suffixes" => suffixes,
        "table" => table_str
    ))
    url = "http://localhost:8095/checkTable"
    response = HTTP.post(url, body=data, headers=["Content-Type" => "application/json"])
    if response.status == 200
        is_equivalent = JSON.parse(String(response.body))
        if isnothing(is_equivalent["type"])
            return true, ""
        else
            return false, is_equivalent["response"]
        end
    end
end

function membership(word::String)
    if word == ""
        word = "ε"
    end
    data = JSON.json(Dict("word" => word))
    url = "http://localhost:8095/checkWord"
    response = HTTP.post(url, body=data, headers=["Content-type" => "application/json"])
    if response.status == 200
        is_membership = JSON.parse(String(response.body))
        if is_membership["response"]
            return true
        else
            return false
        end
    end
end
```

Ручную работу МАТ выполняют следующие функции:

```
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
```
