FROM registry.access.redhat.com/3scale-amp20/apicast-gateway

# Copy customized source code to the appropriate directory
COPY ./apicast_oauth.lua /opt/app-root/src/src/oauth/