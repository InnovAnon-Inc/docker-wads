# TODO oblige fails to compile on modern systems;
#      gives an error about trying to assign a packed structure to a short...
#      is this 32-bit code?
FROM innovanon/poobuntu:latest
MAINTAINER Innovations Anonymous <InnovAnon-Inc@protonmail.com>

LABEL version="1.0"                                                     \
      maintainer="Innovations Anonymous <InnovAnon-Inc@protonmail.com>" \
      about="Doom WADS"                                                 \
      org.label-schema.build-date=$BUILD_DATE                           \
      org.label-schema.license="PDL (Public Domain License)"            \
      org.label-schema.name="docker-wads"                               \
      org.label-schema.url="InnovAnon-Inc.github.io/docker-wads"        \
      org.label-schema.vcs-ref=$VCS_REF                                 \
      org.label-schema.vcs-type="Git"                                   \
      org.label-schema.vcs-url="https://github.com/InnovAnon-Inc/docker-wads"

ENV B=/usr

COPY dpkg.list manual.list ./
RUN apt-fast update \
 && apt-fast install `grep -v '^[\^#]' dpkg.list` \
 && mkdir -pv ${B}/src ${B}/out

WORKDIR ${B}/src
RUN git clone --depth=1 --recursive https://github.com/Doom-Utils/deutex.git \
 && mv -v deutex deutex-master
#RUN pcurl https://github.com/Doom-Utils/deutex/archive/master.zip \
#  | busybox unzip -q -
RUN git clone --depth=1 --recursive https://github.com/Doom-Utils/zennode.git \
 && mv -v zennode zennode-master
#RUN pcurl https://github.com/Doom-Utils/zennode/archive/master.zip \
#  | busybox unzip -q -
RUN git clone --depth=1 --recursive https://github.com/freedoom/freedoom.git \
 && mv -v freedoom freedoom-master
#RUN pcurl https://github.com/freedoom/freedoom/archive/master.zip \
#  | busybox unzip -q -
RUN git clone --depth=1 --recursive https://github.com/pa1nki113r/Project_Brutality.git \
 && mv -v Project_Brutality Project_Brutality-master
#RUN pcurl https://github.com/pa1nki113r/Project_Brutality/archive/master.zip \
#  | busybox unzip -q -

WORKDIR ${B}/src/deutex-master
RUN chmod -v +x bootstrap \
 && ./bootstrap           \
 && ./configure           \
 && make                  \
 && make install

WORKDIR ${B}/src/zennode-master
RUN sed -i                         \
 -e 's/^DOCS=.*/DOCS=/'            \
 -e '/	install -Dm 644 $(DOCS)/d' \
 -e '/	for doc in $(DOCS)/d'      \
 Makefile                          \
 && make                           \
 && make install

WORKDIR ${B}/src/freedoom-master
RUN chmod -v +x scripts/*                 \
    graphics/text/* lumps/*/* bootstrap/* \
 && make rebuild-nodes                    \
 && make                                  \
 && mv -v wads/* ${B}/out

WORKDIR ${B}/src/deutex-master
RUN make uninstall

WORKDIR ${B}/src/zennode-master
RUN make uninstall

#RUN git clone --depth=1 --recursive https://github.com/pa1nki113r/Project_Brutality.git
WORKDIR ${B}/src/Project_Brutality-master
RUN rm -rf .git \
 && zip -q -Z bzip2 -9 ${B}/out/Project_Brutality.pk3 .
WORKDIR ${B}/src
RUN rm -rf freedoom-master deutex-master zennode-master Project_Brutality-master \
 && mkdir -v rainbow_blood bd_be

# TODO use repo
WORKDIR rainbow_blood
#RUN pcurl https://sjc3.dl.dbolical.com/dl/2017/07/30/rainbow_blood.zip \
#  | busybox unzip -q - | buxybox unzip -q -o - \
# && zip -q -Z bzip2 -9 -r ${B}/out/rainbow_blood.pk3 .
COPY rainbow_blood.zip .
RUN busybox unzip -q -p rainbow_blood.zip \
  | busybox unzip -q -o -                 \
 && rm -v rainbow_blood.zip               \
 && zip -q -Z bzip2 -9 -r ${B}/out/rainbow_blood.pk3 .

WORKDIR bd_be
COPY Brutal_Doom_Black_Edition.36.zip .
RUN busybox unzip -q -p Brutal_Doom_Black_Edition.36.zip \
  | busybox unzip -q -o -                                \
 && rm -v Brutal_Doom_Black_Edition.36.zip               \
 && zip -q -Z bzip2 -9 -r ${B}/out/bd_be.pk3 .

WORKDIR /
RUN rm -rf ${B}/src/rainbow_blood ${B}/src/bd_be   \
 && apt-mark manual `grep -v '^[\^#]' manual.list` \
 && apt-fast purge  `grep -v '^[\^#]' dpkg.list`   \
 && ./poobuntu-clean.sh                            \
 && rm -v manual.list dpkg.list

#ENTRYPOINT cp -v ${B}/out/*.wad ${B}/out/*.pk3 ${B}
#ENTRYPOINT find ${B}/out
ENTRYPOINT cp -v ${B}/out/* ${B}/vol/

