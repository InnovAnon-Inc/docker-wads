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
RUN apt-fast install `grep -v '^[\^#]' dpkg.list` \
 && mkdir -pv ${B}/src ${B}/out

WORKDIR ${B}/src
#RUN git clone --depth=1 --recursive https://github.com/Doom-Utils/deutex.git
RUN wget -qO- https://github.com/Doom-Utils/deutex/archive/master.zip \
  | busybox unzip -q -
#RUN git clone --depth=1 --recursive https://github.com/Doom-Utils/zennode.git
RUN wget -qO- https://github.com/Doom-Utils/zennode/archive/master.zip \
  | busybox unzip -q -
#RUN git clone --depth=1 --recursive https://github.com/freedoom/freedoom.git
RUN wget -qO- https://github.com/freedoom/freedoom/archive/master.zip \
  | busybox unzip -q -
RUN wget -qO- https://github.com/pa1nki113r/Project_Brutality/archive/master.zip \
  | busybox unzip -q -

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

WORKDIR ${B}/src
#RUN git clone --depth=1 --recursive https://github.com/pa1nki113r/Project_Brutality.git
RUN zip -q -Z bzip2 -9 ${B}/out/Project_Brutality.pk3 Project_Brutality-master   \
 && rm -rf freedoom-master deutex-master zennode-master Project_Brutality-master \
 && mkdir -v rainbow_blood

# TODO use repo
WORKDIR rainbow_blood
#RUN wget -qO- https://sjc3.dl.dbolical.com/dl/2017/07/30/rainbow_blood.zip \
#  | busybox unzip -q - | buxybox unzip -q -o - \
# && zip -q -Z bzip2 -9 -r ${B}/out/rainbow_blood.pk3 .
COPY rainbow_blood.zip .
RUN busybox unzip -q   rainbow_blood.zip        \
 && mv -v 'rainbow blood.pk3' rainbow_blood.zip \
 && busybox unzip -q -o rainbow_blood.zip       \
 && rm -v rainbow_blood.zip                     \
 && zip -q -Z bzip2 -9 -r ${B}/out/rainbow_blood.pk3 .

WORKDIR /
RUN rm -rf ${B}/src/rainbow_blood                  \
 && apt-mark manual `grep -v '^[\^#]' manual.list` \
 && apt-fast purge  `grep -v '^[\^#]' dpkg.list`   \
 && ./poobuntu-clean.sh                            \
 && rm -v manual.list dpkg.list

#ENTRYPOINT cp -v ${B}/out/*.wad ${B}/out/*.pk3 ${B}
#ENTRYPOINT find ${B}/out
ENTRYPOINT cp -v ${B}/out/* ${B}/vol/

