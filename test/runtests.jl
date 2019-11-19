using Test
using DLX


# prepare test datas
worlds = []
for i in 5:20, j in 4:2:20
    push!(worlds, (i, j))
end
sets = [[(2,2), (2,2), (3,3)], 
        [(2,4), (2,2), (3,5)],
        [(2,4), (2,5), (3,5), (3,5), (4,7)]]

@testset "Some Random Test" begin
    for w in worlds

        a = DancingLink(w, sets[1])
        b = DancingLink(w, sets[2])
        c = DancingLink(w, sets[3])

        a2 = solve(a)
        b2 = solve(b)
        c2 = solve(c)
        
        @test is_solved(a2)
        @test is_solved(b2)
        @test is_solved(c2)
    end
end
