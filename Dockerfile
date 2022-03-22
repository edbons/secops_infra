FROM alpine:3.14.4

RUN apk add --no-cache git
RUN mkdir /src

WORKDIR /src

RUN git clone https://github.com/Checkmarx/Goatlin.git