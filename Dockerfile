# Pinned toolchain so local runs and CI match.
FROM ubuntu:26.04

ARG TERRAFORM_VERSION=1.10.5
ARG PACKER_VERSION=1.11.2
ARG TFLINT_VERSION=0.55.0
ARG TRIVY_VERSION=0.58.0
ARG INFRACOST_VERSION=0.10.39

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg unzip git make bash jq \
    && rm -rf /var/lib/apt/lists/*

# HashiCorp tools (Terraform + Packer) from the official apt repo, pinned.
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com noble main" \
        > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        terraform=${TERRAFORM_VERSION}-* \
        packer=${PACKER_VERSION}-* \
    && rm -rf /var/lib/apt/lists/*

# tflint
RUN curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_$(dpkg --print-architecture).zip" -o /tmp/tflint.zip \
    && unzip /tmp/tflint.zip -d /usr/local/bin && rm /tmp/tflint.zip

# Trivy
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" -o /tmp/trivy.tgz \
    && tar -xzf /tmp/trivy.tgz -C /usr/local/bin trivy && rm /tmp/trivy.tgz

# Infracost
RUN curl -fsSL "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-$(dpkg --print-architecture).tar.gz" -o /tmp/infracost.tgz \
    && tar -xzf /tmp/infracost.tgz -C /tmp \
    && mv /tmp/infracost-linux-* /usr/local/bin/infracost && rm /tmp/infracost.tgz

# ClickHouse client (to talk to the search instance)
RUN curl -fsSL https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key | gpg --dearmor -o /usr/share/keyrings/clickhouse.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/clickhouse.gpg] https://packages.clickhouse.com/deb stable main" \
        > /etc/apt/sources.list.d/clickhouse.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends clickhouse-client \
    && rm -rf /var/lib/apt/lists/*

# CINC Auditor (open-source InSpec) for post-apply checks
RUN curl -fsSL https://omnitruck.cinc.sh/install.sh | bash -s -- -P cinc-auditor

WORKDIR /work
CMD ["bash"]
