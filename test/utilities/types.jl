@testset "Package Base.in" begin
    p = UpdateManifests.Package("Foobar", UUID(1))
    ce = UpdateManifests.DepInfo(p)

    @testset "Exists" begin
        s = Set([ce])

        @test p in s
    end

    @testset "DNE" begin
        p2 = UpdateManifests.Package("BizBaz", UUID(0))
        @test !(p2 in Set([ce]))
    end
end
