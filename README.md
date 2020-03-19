# pipenv_to_requirements
Tool to convert a Pipenv file into requirements.txt (or requirements-dev.txt)

## To Build

```sh
docker build -t pipenv_to_requirements .
```


## To Run

### Generate requirements.txt

```sh
docker run -i --rm pipenv_to_requirements < Pipfile
```

### Generate requirements-dev.txt
```sh
# local image:
docker run -i --rm pipenv_to_requirements -d < Pipfile

# dockerhub image:
docker run -i --rm wesleydeanflexion/pipenv_to_requirements -d < Pipfile
```
