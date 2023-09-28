FROM registry.access.redhat.com/ubi8/ubi-minimal:8.8

LABEL maintainers="Kubernetes Authors"
LABEL description="CSI External Health Monitor Controller"
ARG binary=./bin/csi-external-health-monitor-controller

COPY ${binary} csi-external-health-monitor-controller
COPY LICENSE /licenses/LICENSE

ENTRYPOINT ["/csi-external-health-monitor-controller"]
