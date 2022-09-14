module Resource

using HTTP, JSON3
using ..Model, ..Service, ..Mapper, ..Auth, ..Contexts
using Dates

const ROUTER = HTTP.Router()

function contextHandler(req)

    user = Auth.User(req)

    withcontext(user) do
        HTTP.Response(200, JSON3.write(ROUTER(req)))
    end
end

const AUTH_ROUTER = HTTP.Router(#= HTTP.Handlers.default404,HTTP.Handlers.default405, =#contextHandler)

function authenticate(user::User)

    resp = HTTP.Response(200, JSON3.write(user))
    return Auth.addtoken!(resp, user)
end

loginUser(req) = authenticate(Service.loginUser(JSON3.read(req.body, User))::User)
HTTP.register!(AUTH_ROUTER, "POST", "/user/login", loginUser)

test(req) = Service.posttest(req.body)
HTTP.register!(ROUTER, "POST", "/test", test)

function requestHandler(req)

    start = Dates.now(Dates.UTC)
    @info (timestamp=start, event="ServiceRequestBegin", tid=Threads.threadid(), method=req.method, target=req.target)
    local resp

    #resp = HTTP.handle(ROUTER, req)

    try
        resp = AUTH_ROUTER(req)
    catch e        

        if e isa Auth.Unauthenticated
            resp = HTTP.Response(401)
        else
            s = IOBuffer()
            showerror(s, e, catch_backtrace(); backtrace=true)
            errormsg = String(resize!(s.data, s.size))
            @error errormsg
            resp = HTTP.Response(500, errormsg)
        end
    end
    stop = Dates.now(Dates.UTC)
    @info (timestamp=stop, event="ServiceRequestEnd", tid=Threads.threadid(), method=req.method, target=req.target, duration=Dates.value(stop - start), status=resp.status, bodysize=length(resp.body))

    return resp
end

function run(port)
    HTTP.serve(requestHandler, "0.0.0.0", port)
end

end # module

