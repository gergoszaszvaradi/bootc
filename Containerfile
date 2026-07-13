ARG FEDORA_VERSION=44

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

ARG FEDORA_VERSION

# Apply kernel arguments
COPY --chmod=0644 system/usr/lib/bootc/kargs.d/ /usr/lib/bootc/kargs.d/

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime

# Configure dnf
COPY --chmod=0644 system/etc/dnf/dnf.conf /etc/dnf/dnf.conf

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
        zsh \
        wget \
        jq \
        fzf \
        ripgrep \
        btop \
        greetd \
        greetd-tuigreet \
        gnome-keyring-pam \
        kernel-modules-extra \
        glibc-langpack-en \
        stow \
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
        grimshot \
        adwaita-icon-theme \
        xwayland-satellite \
        xdg-desktop-portal \
        xdg-desktop-portal-gtk \
        \
        alacritty \
        nautilus \
        solaar \
        easyeffects \
        gnome-calculator \
        file-roller \
        simple-scan \
        loupe \
        decibels \
        evince \
        pinta \
        vlc \
        brave-browser \
        pavucontrol \
        stremio-service \
        discord \
        fragments \
    && dnf clean all

# Install development packages
RUN dnf install -y \
        git \
        clang \
        clang-tools-extra \
        gf \
        toolbox \
        zed \
        golang-github-jesseduffield-lazygit \
    && dnf clean all

# Install MultiViewer for F1 (fetches latest RPM from their API)
RUN MULTIVIEWER_RPM_URL=$(curl -s https://api.multiviewer.app/api/v1/releases/latest | jq -r '.downloads[] | select(.platform == "linux_rpm") | .url') \
    && dnf install -y "${MULTIVIEWER_RPM_URL}" \
    && dnf clean all

# Install gaming packages
RUN dnf install -y \
        steam \
    && dnf clean all

# Copy assets
COPY --chmod=0644 system/usr/share/backgrounds /usr/share/backgrounds
COPY --chmod=0644 system/usr/share/fonts/caskaydia-cove-nf /usr/share/fonts/caskaydia-cove-nf
COPY --chmod=0644 system/usr/share/fonts/noto-color-emoji /usr/share/fonts/noto-color-emoji
RUN fc-cache -f /usr/share/fonts/caskaydia-cove-nf
RUN fc-cache -f /usr/share/fonts/noto-color-emoji

# Set default system configuration
COPY --chmod=0644 home/alacritty/.config/alacritty/ /etc/alacritty/
COPY --chmod=0644 home/niri/.config/niri/ /etc/niri/
COPY --chmod=0644 home/waybar/.config/waybar/ /etc/xdg/waybar/
COPY --chmod=0644 home/swaylock/.config/swaylock/ /etc/swaylock/
COPY --chmod=0644 home/fuzzel/.config/fuzzel/ /etc/xdg/fuzzel/

# Set dconf system defaults
COPY --chmod=0644 system/etc/dconf/profile/user /etc/dconf/profile/user
COPY --chmod=0644 system/etc/dconf/db/local.d/ /etc/dconf/db/local.d/
RUN dconf update

# Disable default bootc upgrader (not ideal in desktop environments since it could reboot silently every 8 hours)
RUN systemctl mask bootc-fetch-apply-updates.timer
RUN systemctl mask bootc-fetch-apply-updates.service

# Copy local scripts
COPY --chmod=0755 system/usr/local/bin/ /usr/local/bin/

# Copy systemd services
COPY --chmod=0644 system/usr/lib/systemd/system/ /usr/lib/systemd/system/

# Enable systemd services
RUN systemctl enable bootc-upgrade.timer
RUN systemctl enable disable-wakeup.service

# Setup greetd
COPY --chmod=0644 system/etc/greetd/config.toml /etc/greetd/config.toml
RUN systemctl enable greetd.service

# Enable gnome-keyring-daemon socket activation (auto-unlock via PAM on login)
RUN systemctl --global enable gnome-keyring-daemon.socket

# Enable SSH agent via gnome-keyring
RUN sed -i '/^OnlyShowIn/d' /etc/xdg/autostart/gnome-keyring-ssh.desktop \
    && mkdir -p /usr/lib/environment.d \
    && echo 'SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/keyring/ssh' > /usr/lib/environment.d/10-ssh-agent.conf

# Validate the container
RUN bootc container lint
