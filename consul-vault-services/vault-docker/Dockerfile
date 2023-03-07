# base image
FROM alpine:3.14
# set vault version
ENV VAULT_VERSION 1.11.3
# create a new directory
RUN mkdir /vault
RUN mkdir /vault/data
RUN chmod 777 -R /vault
# download dependencies
RUN apk --no-cache add \
      bash \
      ca-certificates \
      wget \
      jq
# download and set up vault
RUN wget --quiet --output-document=/tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /vault && \
    rm -f /tmp/vault.zip && \
    chmod +x /vault
# update PATH
ENV PATH="PATH=$PATH:$PWD/vault"
# add the config file
COPY ./vault-docker/vault-repo/vault.hcl /vault/vault.hcl
COPY ./vault-docker/vault-repo/admin-policy.hcl /vault/admin-policy.hcl
COPY ./vault-docker/vault-init.sh /vault/vault-init.sh

RUN chmod +x /vault/vault-init.sh

# expose port 8200
EXPOSE 8200
# run vault
ENTRYPOINT ["/vault/vault-init.sh"]
