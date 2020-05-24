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

COPY dpkg.list .
RUN apt-fast install `grep -v '^[\^#]' dpkg.list` \
 && mkdir -pv ${B}/src ${B}/out

WORKDIR ${B}/src
#RUN git clone --depth=1 --recursive https://github.com/Doom-Utils/deutex.git
RUN wget -qO- https://github.com/Doom-Utils/deutex/archive/master.zip \
  | busybox unzip -
WORKDIR deutex-master
RUN chmod -v +x bootstrap \
 && ./bootstrap           \
 && ./configure           \
 && make                  \
 && make install
WORKDIR ${B}/src

#RUN git clone --depth=1 --recursive https://github.com/Doom-Utils/zennode.git
RUN wget -qO- https://github.com/Doom-Utils/zennode/archive/master.zip \
  | busybox unzip -
WORKDIR zennode-master
RUN sed -i                         \
 -e 's/^DOCS=.*/DOCS=/'            \
 -e '/	install -Dm 644 $(DOCS)/d' \
 -e '/	for doc in $(DOCS)/d'      \
 Makefile                          \
 && make                           \
 && make install
WORKDIR ${B}/src

#RUN git clone --depth=1 --recursive https://github.com/freedoom/freedoom.git
RUN wget -qO- https://github.com/freedoom/freedoom/archive/master.zip \
  | busybox unzip -
WORKDIR freedoom-master
RUN chmod -v +x scripts/*                 \
    graphics/text/* lumps/*/* bootstrap/* \
 && make rebuild-nodes                    \
 && make                                  \
 && mv -v wads/* ${B}/out
WORKDIR ${B}/src

WORKDIR ${B}/src/deutex-master
RUN make uninstall
WORKDIR ${B}/src

WORKDIR ${B}/src/zennode-master
RUN make uninstall
WORKDIR ${B}/src

#WORKDIR ${B}/src
#RUN git clone --depth=1 --recursive https://github.com/pa1nki113r/Project_Brutality.git
RUN rm -rf freedoom-master deutex-master zennode-master                          \
 && wget -qO- https://github.com/pa1nki113r/Project_Brutality/archive/master.zip \
  | busybox unzip -                                                              \
 && zip -Z bzip2 -9 ${B}/out/Project_Brutality.pk3 Project_Brutality-master

#RUN rm -rf ${B}/src/freedoom-master

#RUN zip -r -Z bzip2 -9 Project_Brutality.zip Project_Brutality
#RUN rm -rf Project_Brutality
#RUN mv -v Project_Brutality.zip ${B}/out/Project_Brutality.pk3

WORKDIR /
COPY manual.list .
RUN apt-mark manual `grep -v '^[\^#]' manual.list` \
 && apt-fast purge  `grep -v '^[\^#]' dpkg.list`   \
 && ./poobuntu-clean.sh                            \
 && rm -v manual.list dpkg.list

# TODO use repo
COPY rainbow_blood.pk3 ${B}/out/

#ENTRYPOINT cp -v ${B}/out/*.wad ${B}/out/Project_Brutality.pk3 ${B}
ENTRYPOINT find ${B}/out
