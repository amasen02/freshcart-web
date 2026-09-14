# syntax=docker/dockerfile:1.7
# ---------------------------------------------------------------------------
# Multi-stage build for the FreshCart customer SPA.
#  - build stage: Node, npm ci + production Angular build
#  - runtime stage: nginx serving the static bundle as a non-root user
# In Kubernetes the ingress routes /api and /hubs to the gateway; nginx here
# only serves the static application shell and the SPA fallback.
# ---------------------------------------------------------------------------

FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build -- --configuration production

FROM nginx:1.31.5-alpine3.24@sha256:72ba65eb42c10344912a84ff42408db7d34f2feb642204570ab8fc5ffd29f1d3 AS runtime

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist/freshcart-customer/browser /usr/share/nginx/html

# Keep libuuid at the Alpine 3.24 security-fixed version or newer.
RUN apk add --no-cache --upgrade 'libuuid>=2.42.3-r1'

# nginx writes its pid and temp files outside the read-only html root; pre-create
# the writable paths and hand ownership to the unprivileged nginx user.
RUN touch /run/nginx.pid \
    && chown -R nginx:nginx /run/nginx.pid /var/cache/nginx /var/log/nginx /usr/share/nginx/html

USER nginx
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s CMD wget --spider --quiet http://127.0.0.1:80/ || exit 1

ENTRYPOINT ["nginx", "-g", "daemon off;"]
