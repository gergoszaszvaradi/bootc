if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

./scripts/build-image.sh

podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    -v ./config.toml:/config.toml:ro \
    -v ./output:/output \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type qcow2 \
    --rootfs xfs \
    localhost/bootc:latest
