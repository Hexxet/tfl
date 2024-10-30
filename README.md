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
- Так как угадыватель знает количество узлов в лабиринте, то можно предположить, что длина пути до выхода из лабиринта не будет превышать количество этих узлов. Так как если длина пути больше, то это означает, что или угадыватель попал в циклы, или он сильно заплутал.  

## Взаимодейсвие с МАТ
Работу МАТ имитируют следующие функции

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
