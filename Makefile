#
# Makefile for Firefox RPM from Distributed Binary
#

NAME=firefox

LATEST_URL=https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US


default: build


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
	@echo
	@echo Downloading version $(VERSION)
	@echo
	curl --fail --silent --show-error --location --output '$@' '$(LATEST_URL)'

# Older versions can be left over if the version changes from the last
# build.  Cover all the bases, not just the latest.
TO_CLEAN += $(NAME)-*.tar.bz2 



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

build install rpmdump b i r cb cbr cbi cbic cbrc: $(SPEC)
	$(MAKE) -f Makefile-stage2 $@

clean c:
	touch $(SPEC)
	$(MAKE) -f Makefile-stage2 $@
	rm -rf $(SPEC)
	rm -rf $(TO_CLEAN) *~
