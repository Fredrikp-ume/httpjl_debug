module Client

using HTTP, JSON3,CSV, DataFrames, JSONTables, Base64
using ..Model,..Auth

const SERVER = Ref{String}("http://localhost:8080")
const AUTH_TOKEN = Ref{String}()

function loginUser(username, password)
    body = (; username, password=password#= base64encode(password) =#)
    resp = HTTP.post(string(SERVER[], "/user/login"), [], JSON3.write(body); cookies=true)
    if HTTP.hasheader(resp, Auth.JWT_TOKEN_COOKIE_NAME)
        AUTH_TOKEN[] = HTTP.header(resp, Auth.JWT_TOKEN_COOKIE_NAME)
    end
    return JSON3.read(resp.body, User)
end

function test()
    resp = HTTP.post(string(SERVER[], "/test"), [Auth.JWT_TOKEN_COOKIE_NAME => AUTH_TOKEN[]], JSON3.write((;)))

    return JSON3.read(resp.body,Vector{Model.Dataset})    
end

end # module