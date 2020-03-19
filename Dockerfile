FROM python:3.7-slim

ARG WORKING_DIRECTORY=/data
ARG username=ptor
ARG groupname=ptor

RUN mkdir -p ${WORKING_DIRECTORY} \
  && groupadd --system ${groupname} \
  && useradd --system --create-home --gid ${groupname} ${username} \
  && chown --recursive ${username}:${groupname} ${WORKING_DIRECTORY}

WORKDIR ${WORKING_DIRECTORY}

RUN pip install pipenv_to_requirements 

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod 755 /bin/entrypoint.sh

USER ${username}

ENTRYPOINT ["/bin/entrypoint.sh"]
