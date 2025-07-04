```bash
docker run --gpus all -dit \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    -v "$HOME/git-repos/on-policy:/workspace/mounted/on-policy:rw" \
    -e DISPLAY=$DISPLAY \
    -e XAUTHORITY=/root/.Xauthority \
    --net=host \
    onpolicy-image

    # -p 6426:6006 \
```

```bash
docker exec -it CONTAINER_NAME bash
```

```bash
(cd onpolicy/scripts/train_smacv2_scripts/ && ./train_defeatRoaches.sh)
```