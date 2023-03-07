DESCRIPTION = "ASUS Tinker V overlay package"
PR = "r2"
SRC_URI = "file://common \
           file://COPYING \
"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/COPYING;md5=d32239bcb673463ab874e80d47fae504"

INSANE_SKIP_${PN} = "stripped"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

FILES_SOLIBSDEV = ""
INSANE_SKIP_${PN} += "dev-so"

inherit systemd

do_package_qa[noexec] = "1"
SYSTEMD_SERVICE_${PN} = "adbd.service"

do_install() {
  install -d ${D}
  if [ -n "$(ls -A ${WORKDIR}/common)" ]; then
    cp -rf ${WORKDIR}/common/* ${D}
  fi
}

FILES_${PN} += "/ "
