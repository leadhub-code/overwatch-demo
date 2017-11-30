docker_tag=overwatch-demo

run:
	make build
	docker run --rm --name overwatch-demo -p 8000:8000 $(docker_tag)

build:
	make clone git_clone_args='--depth 1'
	docker build --tag $(docker_tag) .

clone:
	test -d overwatch-hub || git clone $(git_clone_args) git@github.com:leadhub-code/overwatch-hub.git
	test -d overwatch-web || git clone $(git_clone_args) git@github.com:leadhub-code/overwatch-web.git
	test -d overwatch-basic-agents || git clone $(git_clone_args) git@github.com:leadhub-code/overwatch-basic-agents.git

clean:
	rm -rf overwatch-hub
	rm -rf overwatch-web
	rm -rf overwatch-basic-agents
