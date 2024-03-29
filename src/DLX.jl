module DLX

export DancingLink, is_solved

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

    if !isempty(members)
        if sum(el -> el[1]*el[2], members) <= world[1] * world[2]    
            # TODO: 못 넣을 때 이거 순서 바꾸면 가능해짐...    
            sort!(members; by = el -> el[1]*el[2], rev = true) 
            
            slots = search_slot(board, members[1])
            if !isempty(slots)
                step = 1
                board = fillboard(board, slots[1], members[step])
            end
        end
    end
    # return setp=0 if it's not feasible
    me = DancingLink(missing, board, members, step, slots, 1)
    solve(me)
end
"""
    DancingLink(worlds::Vector, members)

제일 큰 world에 전부 구겨넣기, 남는거만 다음 world로 전달
"""
function DancingLink(worlds::Vector, members)
    sort!(worlds; by = el -> el[1] * el[2], rev = true)

    solutions = []
    for w in worlds
        i = length(members)

        while true 
            if i == 0 
                push!(solutions, DancingLink(w, members))
                break
            end
            sol = DancingLink(w, members[1:i])
            if is_solved(sol) 
                push!(solutions, sol)
                if i < length(members)
                    members = members[i+1:end]
                else
                    members = [] 
                end
                break
            else 
                i -= 1
            end

        end
    end
    if length(members) > 0 
        @warn "DancingLink - $(members) cannot fit into any world"
    end
    return solutions
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
    slots = search_slot(board, members[step])

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
        slots = search_slot(me.board, me.members[me.step+1])
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
        cor = i <= x.step ? :green : :normal
        printstyled(io, el; color = cor)

        i == length(x.members) ? print(io, "]") : print(io, ",")
    end
end


# 
function fillboard(board, cod, target)
    b = copy(board)
    b[cod[1], cod[2]] .= maximum(board) +1

    return b
end

"""
    search_slot(board, member_size)

if value iszero and top-left value is nonzero
"""
function search_slot(board, memeger::Tuple)
    a = _search(board, memeger)
    if memeger[1] != memeger[2]
        a = append!(a, _search(board, reverse(memeger)))
    end
    return a
end

function _search(board, member::Tuple)
    # Row=1이면 왼쪽이 notzero Col은 무관
    # Col=1이면 위가 notzero Row는 무관
    # 그외에는 왼쪽과 위가 모두 notzero 
    cods = Tuple[]
    board_size = size(board)

    for row in 1:board_size[1]
        for col in 1:board_size[2]
            if iszero(board[row, col])
                rg_row = row:(row + member[1] - 1)
                rg_col = col:(col + member[2] - 1)
                if last(rg_row) <= board_size[1] && last(rg_col) <= board_size[2]
                    # 또한 이 영역이 전부 0이어야 한다 
                    if iszero(sum(board[rg_row, rg_col]))
                        push!(cods, (rg_row, rg_col))
                    end
                end
            end
        end
    end
    return cods
end

end # module
