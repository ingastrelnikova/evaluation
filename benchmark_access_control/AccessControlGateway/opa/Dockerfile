FROM openpolicyagent/opa:latest

WORKDIR /policy
COPY policy.rego /policy/policy.rego

EXPOSE 8181

CMD ["run", "--server", "/policy/policy.rego"]
