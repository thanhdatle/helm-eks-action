# For contributors: in case someone would like to contribute a change in the base docker image,
# please open a PR for the `dockerhub/Dockerfile` in the same project.

#FROM koslib/ga-helm-eks:2.4

FROM mozilla/sops:v3.6.0-alpine as sops

FROM alpine:3.13

#ARG AWSCLI_VERSION="1.20.8"
ARG AWSCLI_VERSION="1.27.41"
ARG HELM_VERSION="3.10.1"
ARG KUBECTL_VERSION="1.25.4"

COPY --from=sops /usr/local/bin/sops /usr/bin/sops

RUN apk add py-pip curl wget ca-certificates git bash jq gcc alpine-sdk
#RUN pip install "awscli==${AWSCLI_VERSION}"
RUN pip install awscliv2
RUN alias aws="awsv2"
RUN curl -L -o /usr/bin/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN chmod +x /usr/bin/kubectl

RUN curl -o /usr/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x /usr/bin/aws-iam-authenticator

RUN wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm
RUN chmod +x /usr/local/bin/helm

RUN wget https://github.com/helmfile/helmfile/releases/download/v0.149.0/helmfile_0.149.0_linux_amd64.tar.gz -O - | tar -xzO helmfile > /usr/local/bin/helmfile
RUN chmod +x /usr/local/bin/helmfile

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]: