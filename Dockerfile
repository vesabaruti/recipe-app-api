# name of the image we are going to base it from
FROM python:3.7-alpine
# maintainer line
MAINTAINER Vesa Baruti

# doesnt allow python to buffer the outputs
ENV PYTHONUNBUFFERED 1

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# copy file from the directory adjacent to the docker file - on the docker image
COPY ./requirements.txt /requirements.txt
RUN apk add --update --no-cache postgresql-client jpeg-dev
# temporary requirements
RUN apk add --update --no-cache --virtual .tmp-build-deps \
      gcc libc-dev linux-headers postgresql-dev musl-dev zlib zlib-dev
RUN pip install -r /requirements.txt
# delete temp requirements
RUN apk del .tmp-build-deps

#create a directory to store our application source code in the docker image, and copy source code to the app directory in docker image
RUN mkdir /app
WORKDIR /app
COPY ./app /app

# directory to store files
RUN mkdir -p /vol/web/media
# directory for static files like javascript(that dont change during the running of the application)
RUN mkdir -p /vol/web/static
# add a usser to use our app.  -D allows a user to only run applications
# without this user, the app will run using the root user which is not recommended for security reasons
RUN adduser -D user
# R stands for Recursive, and the command sets the ownership of vol directory to the user
RUN chown -R user:user /vol/
RUN chmod -R 775 /vol/web
USER user
