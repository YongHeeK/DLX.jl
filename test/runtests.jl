using Test
using StatsBase
using GameDataManager
using DLX

# 테스트 데이터 준비
v = Village()
sites = v.layout.sites
site = sites[15] # 이거 제일 큰거

# 사이트 보너스
sitebonus = begin 
    ref = get(Dict, ("SiteBonus", "Data"))
    x = map(el -> vcat(get.(el["Requirement"], "Buildings", missing)...), ref)
    unique(x)
end



# prepare test datas
worlds = []
for i in 5:20, j in 4:2:50
    push!(worlds, (i, j))
end

# 아 음...
sets = [[(2,2), (2,2), (3,3)], 
[(2,4), (2,2), (3,5)],
[(2,4), (2,5), (3,5), (3,5), (4,7)]]


w = worlds[5]

a = DancingLink(w, sets[1])
solve(a)