FROM quay.io/keycloak/keycloak:latest as builder

# Habilita o banco Postgres e otimiza o build
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_DB=postgres

WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Variáveis para a Render entender que o SSL acaba no Load Balancer deles
ENV KC_DB=postgres
ENV KC_PROXY=edge
ENV KC_HOSTNAME_STRICT=false
ENV KC_HTTP_ENABLED=true

# A Render injeta a porta na variável PORT, o Keycloak usa a 8080 por padrão
# Vamos forçar a 8080 e configurar o Health Check da Render para ela
EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", "--optimized"]