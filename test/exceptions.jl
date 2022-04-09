@testset "$(exec)" for exec in [
    UpdateManifests.UnableToParseSSHKey, UpdateManifests.UnableToDetectCIService
]
    io = IOBuffer()
    message = "foobar"
    show(io, exec(message))

    @test contains(String(io.data), message)
end
