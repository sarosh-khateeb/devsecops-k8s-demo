package main

deny[msg] {
    input.kind = "Service"
    not input.spec.type = "NodePort"
    msg = "Service type should be NodePort"
}

# deny[msg] {
#    input.kind = "Deployment"
#    not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true
#    msg = "Container must not run as root - use runAsNonRoot within Container security context"
#}