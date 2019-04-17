FROM openresty/openresty:1.13.6.2-stretch
MAINTAINER Hans Kristian Flaatten <hans.flaatten@evry.com>

ENV \
 SESSION_VERSION=2.22 \
 HTTP_VERSION=0.12 \
 OPENIDC_VERSION=1.7.1 \
 JWT_VERSION=0.2.0 \
 HMAC_VERSION=989f601acbe74dee71c1a48f3e140a427f2d03ae

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl 

RUN \
 cd /tmp && \
 curl -sSL https://github.com/bungle/lua-resty-session/archive/v${SESSION_VERSION}.tar.gz | tar xz && \
 curl -sSL https://github.com/pintsized/lua-resty-http/archive/v${HTTP_VERSION}.tar.gz | tar xz  && \
 curl -sSL https://github.com/pingidentity/lua-resty-openidc/archive/v${OPENIDC_VERSION}.tar.gz | tar xz && \
 curl -sSL https://github.com/cdbattags/lua-resty-jwt/archive/v${JWT_VERSION}.tar.gz | tar xz && \
 curl -sSL https://github.com/jkeys089/lua-resty-hmac/archive/${HMAC_VERSION}.tar.gz | tar xz && \
 cp -r /tmp/lua-resty-session-${SESSION_VERSION}/lib/resty/* /usr/local/openresty/lualib/resty/ && \
 cp -r /tmp/lua-resty-http-${HTTP_VERSION}/lib/resty/* /usr/local/openresty/lualib/resty/ && \
 cp -r /tmp/lua-resty-openidc-${OPENIDC_VERSION}/lib/resty/* /usr/local/openresty/lualib/resty/ && \
 cp -r /tmp/lua-resty-jwt-${JWT_VERSION}/lib/resty/* /usr/local/openresty/lualib/resty/ && \
 cp -r /tmp/lua-resty-hmac-${HMAC_VERSION}/lib/resty/* /usr/local/openresty/lualib/resty/ && \
 rm -rf /tmp/* && \
 mkdir -p /usr/local/openresty/nginx/conf/hostsites/ && \
 true

RUN apt-get update -y && \
    apt-get install lsb-release -y && \
    export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    apt-get install -y curl && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && \
    apt-get install gcsfuse -y

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


COPY bootstrap.sh /usr/local/openresty/bootstrap.sh
COPY nginx /usr/local/openresty/nginx/

ENTRYPOINT ["/usr/local/openresty/bootstrap.sh"]
