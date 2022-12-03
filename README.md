# mbentley/nvidia-smi-rest

docker image for [nvidia-smi-rest](https://github.com/lampaa/nvidia-smi-rest)
based off of nvidia/cuda:11.8.0-base-ubuntu22.04

To pull this image:
`docker pull mbentley/nvidia-smi-rest`

## Example Usage

```
docker run -d \
  --gpus 'all,"capabilities=compute,utility"' \
  -p 8176:8176 \
  mbentley/nvidia-smi-rest
```

By default, this just runs the nvidia-smi-rest process that listens on port 8176.

For the API documentation, refer to the [nvidia-smi-rest](https://github.com/lampaa/nvidia-smi-rest) README.
