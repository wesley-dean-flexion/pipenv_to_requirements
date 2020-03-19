FROM python:3.7-slim

##
## Parameterize the build
##

# where to use as a data source (largely unneeded in most cases)
ARG WORKING_DIRECTORY=/data

# the unprivileged system username to create
ARG username=ptor

# the unprivileged system group to create
ARG groupname=ptor

# make sure the working directory, the user, and its group all exist and are
# owned properly
RUN mkdir -p ${WORKING_DIRECTORY} \
  && groupadd --system ${groupname} \
  && useradd --system --create-home --gid ${groupname} ${username} \
  && chown --recursive ${username}:${groupname} ${WORKING_DIRECTORY}

# move to the working directory
WORKDIR ${WORKING_DIRECTORY}

# make sure we have the Python tools needed to do the conversion
RUN pip install pipenv_to_requirements

# install the entrypoint script and make it executable
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod 755 /bin/entrypoint.sh

# switch to the unprivileged system user created previously
USER ${username}

# set the default entrypoint -- the command to run -- to the script we installed
ENTRYPOINT ["/bin/entrypoint.sh"]
