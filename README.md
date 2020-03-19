# pipenv_to_requirements
This is a tool to convert a Pipenv file into requirements.txt 
(or requirements-dev.txt).

When containerizing a Python application that used pipenv to specify
requirements, I found that the images were very large -- often more
than 2.0GB -- with a large amount of cached data and long build times,
even on reasonable hardware.  By switching to use 'requirements.txt'
instead of Pipfile (and Pipfile.lock), I was able to drop one image
from 2.16GB to 0.68GB (688MB) and cut build times by about the same 
ratio (roughly 7 minutes down to roughly 2 minutes on average).  The 
image stored on AWS ECR was about 0.200GB (200MB) which was very
helpful to us.  I was able to explore this path because virtual
environments -- which can be immensely helpful when developing in an
environment with multiple projects, multiple Python versions, multiple
module requirements, etc. -- weren't needed in the image where only ever
one version of Python would be installed along with only the modules
needed to run the application.

The application being containerized didn't need pipenv or virtual
environments -- it just needed a set of Python modules.  So, to
simplify the process, I created an image that would use `pipenv`
to generate a `Pipfile.lock` file which I was able to feed into
[pipenv_to_requirements](https://github.com/gsemet/pipenv-to-requirements)
to generate a `requirements.txt` (or `requirements-dev.txt`) file which
`pip install -r` could read and apply.

## How it Works

This image goes through two steps:

1. use `pipenv --lock` to generate a `Pipfile.lock` file
2. use `pipenv_to_requirements` to generate `requirements.txt`

### 1. Generate Pipfile.lock

The pipenv_to_requirements tool works from a `Pipfile.lock` file 
(not `Pipfile`); therefore, the first step is to generate `Pipfile.lock`
for use in the next step.

Running `pipenv --lock` scans for requirements in the `[packages]` and
`[packages-dev]` sections of the `Pipfile`.  Because of that, the
`pipenv_to_requirements` tool can generate either `requirements.txt`
(from the `[packages]` stanza) or `requirements-dev.txt` (from the
`[packages-dev]` stanza).

#### Providing the Pipfile

The tool reads the Pipfile from STDIN.  Therefore, the content of the
`Pipfile` will need to be piped in to `docker run`.  So, either of these
forms will work:

```sh
# piped
cat Pipfile | docker run -i [...]

# redirected
docker run -i [...] < Pipfile
```

The "piped" form is more readable while the "redirected" form spawns
one less process (which makes it slightly more efficient).

Note: because `docker run` is reading from STDIN, the `-i` flag for 
`docker run` is required to bind STDIN to the container.

### 2. Generate requirements.txt

Once we have the `Pipfile.lock` file, we can use `pipenv_to_requirements`
to generate `requirements.txt` or `requirements-dev.txt`.

## Usage

### Flags

A container running this image is able to pass several flags along to 
`pipenv_to_requirements`:

* **-o**: generate `requirements.txt` (the default)
* **-d**: generate `requirements-dev.txt`
* **-q**: run quietly (don't display logs)
* **-f**: generate files with frozen versions

The flags are placed at the end of the `docker run` command after the
name of the image.  Technically speaking, a script is setup as an
ENTRYPOINT so that flags are passed as through to the script as by
a CMD option.

The script that manages the process is a Bash script that uses
`getopts` so GNU-style flag combination is supported (e.g., 
`-df` is the same as `-d -f`)

### To Build

```sh
docker build -t pipenv_to_requirements .
```

### To Run

#### Generate requirements.txt

```sh
docker run -i --rm pipenv_to_requirements < Pipfile
```

#### Generate requirements-dev.txt

```sh
# local image:
docker run -i --rm pipenv_to_requirements -d < Pipfile

# dockerhub image:
docker run -i --rm wesleydeanflexion/pipenv_to_requirements -d < Pipfile
```

## Examples

### Generate requirements.txt from Pipfile

```sh
# pipe form with implied output specification
cat Pipfile | docker run -i --rm pipenv_to_requirements > requirements.txt

# redirect form with explicit output specification
docker run -i --rm pipenv_to_requirements -o < Pipfile > requirements.txt
```

### Generate requirements-dev from Pipfile

```sh
cat Pipfile | docker run -i --rm pipenv_to_requirements -d > requirements-dev.txt
```

### Generate frozen requirements-dev.txt

```sh
cat Pipfile | docker run -i --rm pipenv_to_requiremenst -df > requirements-dev.txt
```
