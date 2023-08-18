# Import the os of the docker image
FROM python:alpine3.18
LABEL maintainer="interact.it"

# This print any outputs directly to the console
ENV PYTHONUNBUFFERED 1

# Copy files and folders from local to the image filesystem
COPY ./requirements.txt /requirements.txt
COPY ./app /app
COPY ./scripts /scripts

# Working directory of new containers
WORKDIR /app

# The port used to connect to the Django development server
EXPOSE 8000

# Create a virtual environment in the image, install Django, create user 'app'
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client &&\
    apk add --update --no-cache --virtual .tmp-deps \
        build-base postgresql-dev musl-dev linux-headers && \
    /py/bin/pip install -r /requirements.txt && \
    apk del .tmp-deps && \
    adduser --disabled-password --no-create-home app && \
    mkdir -p /vol/web/static && \
    mkdir -p /vol/web/media && \
    chown -R app:app /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

# Set the system path for use python commands inside the virtual environment
ENV PATH="/scripts:/py/bin:$PATH"

# Switch the user from the root user to app user created above
# all the commands below will running as app user
USER app

CMD ["run.sh"]
