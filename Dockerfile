FROM ubuntu:22.04

ARG TARGETARCH
ARG JDK_VERSION=17
ARG PLATFORM_VERSION=android-33
ARG BUILD_TOOLS_VERSION=30.0.3

ENV ANDROID_HOME    /opt/android-sdk

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/${BUILD_TOOLS_VERSION}"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"

RUN apt-get update \
 && apt-get install -y openjdk-${JDK_VERSION}-jdk wget unzip

COPY license /opt/license

RUN mkdir -p $ANDROID_HOME
RUN chmod -R 777 $ANDROID_HOME

# Install Android Commandline-Tools
WORKDIR $ANDROID_HOME
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O commandlinetools-linux.zip
RUN unzip commandlinetools-linux.zip
RUN mv cmdline-tools tools
RUN mkdir cmdline-tools
RUN mv tools cmdline-tools/tools
RUN rm commandlinetools-linux.zip

RUN export ANDROID_HOME=/opt/android-sdk
# RUN export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
RUN export PATH="$PATH:$ANDROID_HOME/cmdline-tools/tools/bin"

RUN yes | sdkmanager --licenses

# RUN sdkmanager "cmdline-tools;latest"
RUN sdkmanager "platforms;${PLATFORM_VERSION}"
RUN sdkmanager "platform-tools"

# Install Android Emulator
RUN apt-get install -y libc6-amd64-cross libgcc1-amd64-cross
RUN ln -s /usr/x86_64-linux-gnu/lib64/ /lib64
RUN wget -q https://redirector.gvt1.com/edgedl/android/repository/emulator-linux_x64-8420304.zip -O emulator-linux.zip
RUN unzip emulator-linux.zip
RUN rm emulator-linux.zip
RUN mv /opt/license/package.xml $ANDROID_HOME/emulator
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/lib64:/usr/x86_64-linux-gnu/lib"
RUN apt-get clean

RUN sdkmanager "build-tools;${BUILD_TOOLS_VERSION}"