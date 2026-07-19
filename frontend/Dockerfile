# ---------- Stage: produção (servidor estático leve) ----------
# FROM python:3.12-alpine AS dev
# WORKDIR /srv

# COPY index.html /srv/sysrev/index.html
# COPY src /srv/sysrev/src

# EXPOSE 80
# CMD ["python", "-m", "http.server", "80", "--directory", "/srv"]

FROM caddy:2-alpine AS dev

COPY index.html /srv/sysrev/index.html
COPY src /srv/sysrev/src
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 80
