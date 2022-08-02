CONTEXT := ci.ocamllabs.io

all:
	dune build ./service/main.exe ./client/main.exe ./web-ui/main.exe ./service/local.exe @runtest

deploy-backend:
	env DOCKER_BUILDKIT=1 docker --context $(CONTEXT) build -t ocaml-ci-service .

deploy-web:
	env DOCKER_BUILDKIT=1 docker --context $(CONTEXT) build -f Dockerfile.web -t ocaml-ci-web .

deploy-stack:
	docker --context $(CONTEXT) stack deploy --prune -c stack.yml ocaml-ci
