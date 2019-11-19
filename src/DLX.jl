module DLX

export DancingLink, solve, is_solved

"""
    DancingLink
"""
struct DancingLink
    prev::Union{Missing, DancingLink}
    board::Array{Integer, 2}
    members::Array
    step::Int
    slots::Array{Tuple, 1}
    selection::Int
end
function DancingLink(world::Tuple, members)
    step = 0
    board = zeros(Int16, world)
    slots = Tuple[]

    if sum(el -> el[1]*el[2], members) <= world[1] * world[2]        
        sort!(members; by = el -> el[1]*el[2], rev = true) #큰거부터 정렬
        
        slots = find_slot(board, members[1])
        if !isempty(slots)
            step = 1
            board = fillboard(board, slots[1], members[step])
        end
    end
    # return setp=0 if it's not feasible
    DancingLink(missing, board, members, step, slots, 1)
end
function solve(me::DancingLink)
    if is_solved(me)
        me
    else
        if is_windable(me)
            solve(wind(me))
        elseif is_forwardable(me)
            solve(forward(me))
        elseif is_unwindable(me)
            solve(unwind(me))
        else
            me
        end
    end
end

function wind(me::DancingLink)
    board = me.board
    members = me.members

    step = me.step+1
    slots = find_slot(board, members[step])

    board = fillboard(board, slots[1], members[step])
    DancingLink(me, board, members, step, slots, 1)
end
function forward(me::DancingLink)
    selection = me.selection +1

    board = replace(me.board, maximum(me.board) => 0)
    board = fillboard(board, me.slots[selection], me.members[1])

    return DancingLink(me.prev, board, me.members, me.step, me.slots, selection)
end
function unwind(me::DancingLink)
    forward(me.prev)
end

function is_solved(x::DancingLink) 
    x.step == length(x.members)
end
function is_windable(me::DancingLink)
    if me.step < length(me.members)
        slots = find_slot(me.board, me.members[me.step+1])
        if !isempty(slots) 
            return true
        end
    end
    return false
end
is_forwardable(x::Missing) = false
function is_forwardable(x::DancingLink)
    x.selection < length(x.slots)
end
function is_unwindable(x::DancingLink)
    is_forwardable(x.prev) 
    
end

function Base.show(io::IO, x::DancingLink)
    summary(io, x)
    print(io, " - ")
    display(x.board)
    print(io, "Members:[")
    for (i, el) in enumerate(x.members)
        col = i == x.step ? :green : :normal
        printstyled(io, el; color = col)

        i == length(x.members) ? print(io, "]") : print(io, ",")
    end
end


# 
function fillboard(board, cod, target)
    b = copy(board)
    b[cod[1]:cod[1]+target[1]-1, cod[2]:cod[2]+target[2]-1] .= maximum(board) +1

    return b
end

"""
    find_slot

if value iszero and top-left value is nonzero
#TODO add rotation cases
"""
function find_slot(board, bd_size::Tuple)
    # Row=1이면 왼쪽이 notzero Col은 무관
    # Col=1이면 위가 notzero Row는 무관
    # 그외에는 왼쪽과 위가 모두 notzero 
    cods = Tuple[]
    function isfillable(r, c) 
        (board_size[1] - r + 1) >= bd_size[1] && (board_size[2] - c + 1) >= bd_size[2]
    end

    board_size = size(board)
    for row in 1:board_size[1], col in 1:board_size[2]
        if iszero(board[row, col])
            if row == 1 && col == 1
                if isfillable(row, col)
                    push!(cods, (row, col))
                end
            elseif row == 1 && col > 1
                if !iszero(board[row, col-1]) 
                    if isfillable(row, col)
                        push!(cods, (row, col))
                    end
                end
            elseif row > 1 && col == 1
                if !iszero(board[row-1, col]) 
                    if isfillable(row, col)
                        push!(cods, (row, col))
                    end
                end
            else
                if !iszero(board[row-1, col]) && !iszero(board[row, col-1])  
                    if isfillable(row, col)
                        push!(cods, (row, col))
                    end
                end
            end
        end
    end
    return cods
end

end # module
