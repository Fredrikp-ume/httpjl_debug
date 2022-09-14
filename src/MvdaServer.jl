module MvdaServer

export Workers, Model, Mapper, Service, Resource, Client

include("Workers.jl")
using .Workers

include("Model.jl")
using .Model

include("Auth.jl")
using .Auth

include("Contexts.jl")
using .Contexts

include("Mapper.jl")
using .Mapper

include("Service.jl")
using .Service

include("Resource.jl")
using .Resource

include("Client.jl")
using .Client

export getresourcedir

include("util.jl")

function getresourcedir()
    joinpath(pathof(MvdaServer),"../../resources") |> normpath
end

function run(;port=8080)

    resourcedir = getresourcedir()

    authkeysfile = join(["file://",joinpath(resourcedir,"authkeys.json")])

    #init()

    Auth.init(authkeysfile)
    Mapper.initUsers(joinpath(resourcedir,"users.yml"))

    Resource.run(port)
end

end # module
