module Service

using ..Model, ..Mapper, ..Auth, ..Contexts
using DataFrames,CSV,JSON3,StructTypes,XLSX
using PyCall
using Pipe, Chain
using NIPALS_PCA
using StringViews
using Statistics

function posttest(obj)
    dataset1 = Model.Dataset("a","b","c",["e"])
    dataset2 = Model.Dataset("a2","b2","c2",["e2"])

    return [dataset1,dataset2]
end 

function loginUser(user)

    persistedUser = Mapper.get(user)

    if ismissing(persistedUser)
        throw(Auth.Unauthenticated()) 
    end

    if persistedUser.password == user.password
        persistedUser.password = ""
        return persistedUser
    else
        throw(Auth.Unauthenticated())
    end
end

end # module