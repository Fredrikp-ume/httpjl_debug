module Model

using ..MvdaServer
using StructTypes,DataFrames
using Statistics
using Pipe
using Dates
using StructTypes, JSON3,PyCall
using Mongoc
using HTTP

export User

struct Dataset
    user::String
    name::String
    description::String
    wl::Vector{String}
end
StructTypes.StructType(::Type{Dataset}) = StructTypes.Struct()

mutable struct User
    id::Int64 # service-managed
    username::String
    password::String
end

==(x::User, y::User) = x.id == y.id
User() = User(0, "", "")
User(username::String, password::String) = User(0, username, password)
function User(id::T, username::String, password::String) where T <:AbstractString
    User(tryparse(Int64,String(id)), username, password)
end
User(id::Int64, username::String) = User(id, username, "")
#User(dict) = User(dict[:id], dict[:username], dict[:password])
#User(req::HTTP.Messages.Request) = Dict([Pair(Symbol(k),v) for (k,v) in req.headers]) |> User 
StructTypes.StructType(::Type{User}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{User}) = :id
    
end # module