module Mapper

using DataFrames,XLSX,CSV
using ..Contexts,..Model,..MvdaServer
using PyCall
using Dates
using Chain,Pipe
using CategoricalArrays
using Statistics
using DataFramesMeta
using JSONTables
using Mongoc
import YAML

const users = Ref{Vector{Dict}}()

function get(user::User)
    filteredusers = filter(usr->usr[:username] == user.username,users[])

    if !isempty(filteredusers)
        userdict = first(filteredusers)
        return User(userdict[:id],userdict[:username],userdict[:password])
    end

    return missing
end

function initUsers(yamlfile::String)
    users[] = YAML.load_file(yamlfile; dicttype=Dict{Symbol,Any})[:users]
end

end # module