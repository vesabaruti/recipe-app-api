# name of the image we are going to base it from
FROM python:3.7-alpine
# maintainer line
MAINTAINER vesabaruti

# doesnt allow python do buffer the outputs
ENV PYTHONUNBUFFERED 1

# copy file from the directory adjacent to the docker file - on the docker image
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

#create a directory to store our application source code in the docker image, and copy source code to the app directory in docker image
RUN mkdir /app
WORKDIR /app
COPY ./app /app

# add a usser to use our app.  -D allows a user to only run applications
# without this user, the app will run using the root user which is not recommended for security reasons
RUN adduser -D user
USER user
