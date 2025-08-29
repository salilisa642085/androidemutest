FROM debian:bullseye

# Install basics
RUN apt-get update && apt-get install -y \
    wget unzip openjdk-11-jdk qemu-kvm \
    xvfb x11vnc fluxbox novnc websockify \
    && rm -rf /var/lib/apt/lists/*

# Android SDK setup
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p $ANDROID_SDK_ROOT
WORKDIR $ANDROID_SDK_ROOT

# Download command-line tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d cmdline-tools \
    && rm cmdline-tools.zip

ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/bin:$PATH
ENV PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH
ENV PATH=$ANDROID_SDK_ROOT/emulator:$PATH
ENV PATH=$ANDROID_SDK_ROOT/tools/bin:$PATH

# Accept licenses + install emulator pieces
RUN yes | sdkmanager --licenses || true
RUN sdkmanager "platform-tools" "platforms;android-31" "system-images;android-31;google_apis;x86_64" "emulator"

# Create Android Virtual Device
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-31;google_apis;x86_64" --sdcard 512M

# Copy entry script + novnc index
COPY entrypoint.sh /entrypoint.sh
COPY novnc_index.html /usr/share/novnc/index.html
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
