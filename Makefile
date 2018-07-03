MKDIR?=	mkdir -p
PKGCONF?=	pkg-config
INSTALL_LIB?=	install -s -m 444
DESTDIR?=
PULSE_VERSION!=	${PKGCONF} --modversion libpulse | cut -d. -f 1-2
PULSE_LIBDIR?=	`${PKGCONF} --variable=libdir libpulse`
PULSE_MODDIR?=	`${PKGCONF} --variable=modlibexecdir libpulse`
CFLAGS+=	-fPIC -I. `${PKGCONF} --cflags libpulse`
LDFLAGS+=	`${PKGCONF} --libs libpulse`

all: module-sndio.so

module-sndio.so: module-sndio.o
	${CC} -shared module-sndio.o \
		-Wl,-rpath -Wl,${PULSE_LIBDIR} \
		-Wl,-rpath -Wl,${PULSE_LIBDIR}/pulseaudio \
		${LDFLAGS} \
		-L${PULSE_LIBDIR} \
		-L${PULSE_LIBDIR}/pulseaudio \
		-lpulsecore-${PULSE_VERSION} \
		-lpulsecommon-${PULSE_VERSION} \
		-lpulse \
		-lsndio \
		-o module-sndio.so

install: all
	${MKDIR} ${DESTDIR}${PULSE_MODDIR}
	${INSTALL_LIB} module-sndio.so ${DESTDIR}${PULSE_MODDIR}

clean:
	rm -f module-sndio.o module-sndio.so

prune-pulsecore: # Remove unused headers from pulsecore/
	@for f in pulsecore/*; do ${MAKE} clean; git rm -r $$f; \
		if ! ${MAKE}; then git reset HEAD $$f && git checkout $$f; fi; done

archive:
	@tag=$$(git tag --contains HEAD); git archive \
			--prefix=pulseaudio-module-sndio-$$tag/ \
			--output=pulseaudio-module-sndio-$$tag.tar.gz \
			$$tag
