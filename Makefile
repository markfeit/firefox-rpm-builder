#
# Makefile for Firefox RPM from Distributed Binary
#

NAME=firefox

LATEST_URL=https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US


#
# Binary Distribution
#

LATEST_FILE=$(shell curl -sI '$(LATEST_URL)' \
	| awk '$$1 == "Location:" { print $$2 }' \
	| sed -e 's|^.*/||')

ifeq ($(LATEST_FILE),)
  $(error "Can't find latest at download.mozilla.org.")
endif

$(LATEST_FILE):
	curl --fail --silent --show-error --location --output '$@' '$(LATEST_URL)'
TO_CLEAN += $(LATEST_FILE)


VERSION=$(shell echo "$(LATEST_FILE)" \
	| egrep -e '^firefox-[0-9\.]+\.' \
	| sed -e 's/^[^-]\+-\([0-9.]\+\)\..*$$/\1/')

ifeq ($(VERSION),)
  $(error "Can't determine version.  $(LATEST_FILE)")
endif


#
# RPM Spec
#

SPEC=$(NAME).spec

$(SPEC): $(SPEC).raw $(LATEST_FILE)
	sed -e 's/__VERSION__/$(VERSION)/g' $(SPEC).raw > $@
TO_CLEAN += $(SPEC)

spec: $(SPEC)


#
# Build
#

default:
	$(MAKE) build

build install rpmdump b i r cb cbr cbi cbic cbrc: $(SPEC)
	$(MAKE) -f Makefile-stage2 $@

clean c:
	touch $(SPEC)
	$(MAKE) -f Makefile-stage2 $@
	rm -rf $(SPEC)
	rm -rf $(TO_CLEAN) *~
