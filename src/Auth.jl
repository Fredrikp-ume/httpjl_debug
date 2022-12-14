module Auth

using StructTypes, Dates, JWTs, HTTP
using ..Model

const JWT_AUTH_KEYS = Ref{JWKSet}()

function init(authkeysfile)
    JWT_AUTH_KEYS[] = JWKSet(authkeysfile)

    refresh!(JWT_AUTH_KEYS[])
    return
end

# generating a new token for a user
const DATE_FORMAT = DateFormat("e, dd u yyyy HH:MM:SS G\\MT") # Wed, 21 Oct 2015 07:28:00 GMT
const JWT_TOKEN_COOKIE_NAME = "X-MusicAlbums-Jwt-Token"

function addtoken!(resp::HTTP.Response, user::User)

    exp = Dates.now(Dates.UTC) + Dates.Hour(12)
    payload = Dict("iss"=>"MusicAlbums.jl", "exp"=>Dates.datetime2unix(exp), "sub"=>"managing albums", "aud"=>user.username, "uid"=>user.id)
    jwt = JWT(; payload=payload)
    keyid = first(first(JWT_AUTH_KEYS[].keys))
    sign!(jwt, JWT_AUTH_KEYS[], keyid)
    HTTP.setheader(resp, "Set-Cookie" => "$JWT_TOKEN_COOKIE_NAME=$(join([jwt.header, jwt.payload, jwt.signature], '.')); Expires=$(Dates.format(exp, DATE_FORMAT))")
    HTTP.setheader(resp, JWT_TOKEN_COOKIE_NAME => join([jwt.header, jwt.payload, jwt.signature], '.'))

    return resp
end

struct Unauthenticated <: Exception end

function getcookies(req::HTTP.Request)
    if HTTP.hasheader(req, "Cookie")
        return filter(x->lowercase(x.name) == lowercase(JWT_TOKEN_COOKIE_NAME), HTTP.cookies(req))
    end

    return []
end

# parsing token from HTTP request
function User(req::HTTP.Request)

    cookies = getcookies(req)

    if !isempty(cookies)
        if !isempty(cookies[1].value)
            jwt = JWT(; jwt=cookies[1].value)
            verified = false
            for kid in JWT_AUTH_KEYS[].keys
                validate!(jwt, JWT_AUTH_KEYS[], kid[1])
                verified |= isverified(jwt)
            end
            if verified
                parts = claims(jwt)
                return User(parts["uid"], parts["aud"])
            end
        end
    elseif HTTP.hasheader(req, JWT_TOKEN_COOKIE_NAME)

        jwt = JWT(; jwt=String(HTTP.header(req, JWT_TOKEN_COOKIE_NAME)))
        verified = false
        for kid in JWT_AUTH_KEYS[].keys
            validate!(jwt, JWT_AUTH_KEYS[], kid[1])
            verified |= isverified(jwt)
        end

        if verified
            parts = claims(jwt)

            return User(parts["uid"], parts["aud"])
        end
    end
    throw(Unauthenticated())
end

end # module