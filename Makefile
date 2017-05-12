build:
	docker build -t hhvm-nuclide .

start: stop
	docker run -d --name hhvm-nuclide \
		-v $(PWD)/web-root:/web-root \
		-p 2222:22 -p 8000:80 -p 9000:9000 -p 9090:9090 \
		hhvm-nuclide

stop:
	docker rm -f hhvm-nuclide || echo "skip..."

debug:
	docker exec -ti hhvm-nuclide bash

test: start
	sleep 3

	curl http://localhost:8000 | grep 'HHVM Version 3.19.2' > /dev/null
	ssh -o BatchMode=yes -vvv root@localhost -p 2222 2>&1 | grep 'Authentications that can continue' > /dev/null

	docker rm -f hhvm-nuclide
