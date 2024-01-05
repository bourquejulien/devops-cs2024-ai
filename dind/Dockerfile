FROM docker:24.0.5

RUN apk update && apk upgrade
RUN apk add bash make py-pip curl
RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo make
RUN pip install azure-cli

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod +x get_helm.sh && ./get_helm.sh

ENV DOCKER_TLS_CERTDIR=/certs
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
