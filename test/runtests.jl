using Test
using DLX


# prepare test datas
worlds = [(5,5), (5,10), (10, 10), (10, 15), (20, 20), (20, 50)]

sets = [[(3,3), (2,2)], 
        [(4,4), (4,3), (4,2), (3,2), (2,2), (2,1)],
        [(8,8), (8,7), (8,6), (7,5), (7,4), (7,3), (6,2), (5,5), (4,2)]]

@testset "Some Random Test" begin
    for w in worlds
        world_area = w[1] * w[2]
        for s in sets
            a = DancingLink(w, sets[1])
            
            if world_area >= sum(el -> el[1] * el[2], s)
                @test is_solved(a)
            else 
                @test !is_solved(a)
            end
        end
    end
end
