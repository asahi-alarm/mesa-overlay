FROM --platform=linux/amd64 archlinux:multilib-devel AS builder

RUN pacman -Sy --noconfirm archlinux-keyring
RUN pacman -Syu --noconfirm && \
  pacman -S --noconfirm \
  git vim rustup less 'lib32-llvm' 'lib32-llvm-libs' 'lib32-libpciaccess' 'lib32-libglvnd' 'lib32-libxrandr' 'lib32-spirv-tools' 'lib32-spirv-llvm-translator' 'lib32-clang' 'lib32-libxfixes' 'lib32-libvdpau' 'lib32-libva' 'lib32-xcb-util-keysyms'

RUN sed -i 's/tar.zst/tar.xz/' /etc/makepkg.conf

RUN useradd -m -s /bin/bash -G wheel user
RUN echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
USER user
WORKDIR /home/user
RUN rustup install stable && rustup target add i686-unknown-linux-gnu
RUN git clone https://github.com/asahi-alarm/PKGBUILDs.git
RUN cd PKGBUILDs/mesa-asahi && makepkg -s --noconfirm
RUN ls PKGBUILDs/mesa-asahi/*.xz

FROM scratch AS export-stage
COPY --from=builder /home/user/PKGBUILDs/mesa-asahi/mesa-asahi-fex*.xz /
