# Docker CLI

## Create an image to emulate vscode "Reopen in Container"

```bat
docker build -t starter-image:latest .

docker run -d --name prep_IMG0 --env-file DEV.env starter-image:latest sleep infinity
docker exec prep_IMG0 mkdir /workspace
docker cp . prep_IMG0:/workspace

docker commit prep_IMG0 repository:tag
docker push repository:tag
```

