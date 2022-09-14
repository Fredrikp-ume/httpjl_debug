using Test
using MvdaServer

using HTTP

server = @async MvdaServer.run()

@testset "Some basic tests" begin

    user = Client.loginUser("fredrik", "freddansLosen")

    token = Client.AUTH_TOKEN[]

    Client.test() |> println
end

