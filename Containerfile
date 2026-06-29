ARG FEDORA_VERSION=44

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

ARG FEDORA_VERSION
ARG USERNAME=gergoszaszvaradi

# Apply kernel arguments
COPY --chmod=0644 usr/lib/bootc/kargs.d/ /usr/lib/bootc/kargs.d/

# Configure dnf
COPY --chmod=0644 etc/dnf/dnf.conf /etc/dnf/dnf.conf

# Add dnf repositories
RUN dnf install -y dnf5-plugins \
    && dnf clean all
RUN dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm" \
    && dnf clean all
RUN dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release terra-gpg-keys \
    && dnf clean all
RUN dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo \
    && dnf clean all

# Install core packages
RUN dnf install -y \
        wget \
        fzf \
        ripgrep \
        btop \
        greetd \
        greetd-tuigreet \
    && dnf clean all

# Install desktop packages
RUN dnf install -y \
        niri \
        waybar \
        zenity \
        swaybg \
        swayidle \
        swaylock-effects \
        SwayNotificationCenter \
        playerctl \
        cascadia-code-nf-fonts \
        adwaita-icon-theme \
        xwayland-satellite \
        \
        alacritty \
        nautilus \
        gnome-calculator \
        file-roller \
        simple-scan \
        brave-browser \
        pavucontrol \
    && dnf clean all

# Install development packages
RUN dnf install -y \
        git \
        clang \
        toolbox \
        zed \
        golang-github-jesseduffield-lazygit \
    && dnf clean all

# Set default system configuration
COPY --chmod=0644 home/alacritty/.config/alacritty/ /etc/alacritty/
COPY --chmod=0644 home/niri/.config/niri/ /etc/niri/
COPY --chmod=0644 home/waybar/.config/waybar/ /etc/xdg/waybar/

# Configure the user
RUN usermod \
    -s /bin/bash \
    -G\
        wheel \
    ${USERNAME}

# Copy local scripts
COPY --chmod=0755 usr/local/bin/ /usr/local/bin/

# Copy systemd services
COPY --chmod=0644 usr/lib/systemd/system/ /usr/lib/systemd/system/

# Setup greetd
COPY --chmod=0644 etc/greetd/config.toml /etc/greetd/config.toml
RUN systemctl enable greetd.service

# Validate the container
RUN bootc container lint
