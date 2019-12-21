using StatsBase

"""
    startms()
prompts the player on which size game
to play,then initiates a minesweeper
game with that size
"""
function startms()
    print("\nChoose a size\n=============\n1: 8x8\n2: 16x16\n")
    input = readline()
    while true
        if input == "1"
            print("\nStarting 8x8 game...\n")
            global boards = createboards(8,8)
            break
        elseif input == "2"
            print("\nStarting 16x16 game...\n")
            global boards = createboards(16,16)
            break
        end
        print("\nChoose a size\n1: 8x8\n2: 16x16\n")
        input = readline()
    end
    displayboard(boards[:,:,2])
    gameloop(boards)
end

"""
    createboards(y::Int, x::Int)
create a 3-dimensional array with
two minesweeper boards

one with the answers, one blank for
the user to fill in
"""
function createboards(y::Int, x::Int)
    boards = Array{Any, 3}(nothing, y, x, 2)

    if(x == 8)
        minenum = 9
    elseif(x == 16)
        minenum = 20
    end
    m = sample(1:x*y, minenum, replace = false)
    for i = 1:minenum
        boards[m[i]] = *
    end


    for i in eachindex(1:x*y)

        # Array with all adjacent points to i
        adj = [i+1,i-1,i+x,(i+x)+1,(i+x)-1,i-x,(i-x)+1,(i-x)-1]

        # Removes adjacent points that are through edges
        if i <= x
            adj[6] = 0
            adj[7] = 0
            adj[8] = 0
        end
        if i <= x*y && i > x*y-y
            adj[3] = 0
            adj[4] = 0
            adj[5] = 0
        end
        if i % y == 1
            adj[2] = 0
            adj[5] = 0
            adj[8] = 0
        end
        if i % y == 0
            adj[1] = 0
            adj[4] = 0
            adj[7] = 0
        end

        # Assigns number of adjacent mines to a tile
        adjmines = 0
        for k in eachindex(adj)
            if adj[k] != 0

                if boards[adj[k]] == *
                    adjmines += 1
                end
            end
            if boards[i] != *
                boards[i] = adjmines
            end
        end
    end
    return boards
end

"""
    displayboard(a::Array)
displays a 2-dimensional array
on a numbered grid
"""
function displayboard(a::Array)
    rows = length(a[1,:])
    columns = length(a[:,1])

    for y = 1:columns
        for x = 1:rows
            if x == 1
                print(string((columns + 1) - y, "|"))
            end
            if a[y,x] == nothing
                print(" _ ")
            else
                print(string(" ",a[y,x]," "))
            end
        end
        print("\n")
    end

    print("  ")

    for i  = 1:length(a[1,:])
        print("___")
    end

    print("\n")
    print("  ")
    for i = 1:length(a[1,:])
        if i < 10
            print(string(" ", i, " "))
        else
            print(string(i," "))
        end
    end
    print("\n")
end

"""
    gameloop(boards::Array)

this function is passed the boards
created previously and continuously
prompts the user to fill in parts of
the grid until they land on a mine or win
"""
function gameloop(boards::Array)
    rows = length(boards[:,1,2])
    columns = length(boards[1,:,2])

    println("Enter row: ")
    x = parse(Int,readline())
    while (x <= 0 || x > rows)
        println("Enter row: ")
        x = parse(Int,readline())
        print("\n")
    end

    println("Enter column: ")
    y = parse(Int,readline())
    while (y <= 0 || y > columns)
        println("Enter column: ")
        y = parse(Int,readline())
        print("\n")
    end

    while boards[columns - y + 1,x,1] != *

        boards[columns - y + 1,x,2] = boards[columns - y + 1,x,1]

        displayboard(boards[:,:,2])

        println("Enter column: ")
        x = parse(Int,readline())
        while (x <= 0 || x > rows)
            println("Enter column: ")
            x = parse(Int,readline())
            print("\n")
        end

        println("Enter row: ")
        y = parse(Int,readline())
        while (y <= 0 || y > columns)
            println("Enter row: ")
            y = parse(Int,readline())
            print("\n")
        end

        mines = 0
        blanks = rows*columns-1

        for i in eachindex(boards[:,:,2])
            if boards[i] == *
                mines += 1
            end
        end
        println(mines)

        for i in eachindex(boards[:,:,2])
            if boards[i+rows*columns] != nothing
                blanks -= 1
            end
        end
        println(blanks)


        if blanks == mines
            println("\n========")
            println("YOU WON")
            println("========")

            @goto escape
        end

    end
    println("\n========")
    println("YOU LOST")
    println("========")

    @label escape
    displayboard(boards[:,:,1])
end
