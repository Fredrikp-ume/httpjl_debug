FROM julia:1.7.3-buster

ENV JULIA_PROJECT @.
WORKDIR /home

ENV VERSION 1
ADD BiopatServer /home

RUN julia deploy/instantiate.jl

#ARG MONGOPROV="http//localhost:27017"
#ENV MONGOPROVIDER=$MONGOPROV

ARG JULIA_PORT=8080

#ENTRYPOINT [ "julia", "-e", "using MvdaServer;MvdaServer.run(port=8080)"]