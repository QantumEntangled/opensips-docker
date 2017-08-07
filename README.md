## Installing
Download to a local folder

```
$ git clone https://github.com/QantumEntangled/opensips-docker.git
$ cd opensips-docker
```

Build the docker image

```
$ docker build -t opensips-docker ./
```

Run the docker container

```
$ docker run -td --name opensips-container -p 80:80 -p 5060 --cap-add=NET_ADMIN opensips-docker
```

To log into the container to make configuration changes

```
$ docker exec -it opensips-container /bin/bash
```
