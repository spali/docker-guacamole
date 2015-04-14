# docker-guacamole

Docker image for [Guacamole Server](http://guac-dev.org/)

Based on the small debian:wheezy base.
Compiles all guacamole components from source.

## Build from source
```
git clone https://github.com/spali/docker-guacamole.git
cd docker-guacamole
docker build -t spali/guacamole .
```

## Usage

Create your guacamole config directory and populate with the guacamole.properties file.
See the examples directory. Then launch with the following.

If the config directory ```/etc/guacamole``` is empty, initially the examples/noauth config is copied to ```/etc/guacamole``` during first start of the docker container.

```
docker run -d --restart always --name guacamole \
  -v /my-configuration-directory:/etc/guacamole \
  -p 8080:8080 \
  spali/guacamole
```
Browse to ```http://localhost:8080```

##Credits

This is a complete rewrite of the project [hall757/guacamole](https://github.com/hall757/guacamole) by [Randy Hall](https://github.com/hall757). The main difference is the smaller size of the resulting image due base switch to debian and also the optimize build process.




