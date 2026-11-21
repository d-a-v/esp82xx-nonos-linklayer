ifndef LWIP_ROOT
$(error $$LWIP_ROOT must be defined)
endif

ifndef LWIP_REF
$(error $$LWIP_REF must be defined)
endif

define lwip-checkout
	@test -r "$(LWIP_ROOT)"/.git \
		|| (mkdir -p "$(LWIP_ROOT)" \
			&& cd "$(LWIP_ROOT)" \
			&& git init \
			&& git remote add origin $(LWIP_GIT) )
	@cd "$(LWIP_ROOT)" \
		&& if ! git checkout -f $(LWIP_REF) -- ; then \
			case "$(LWIP_REF)" in \
			  refs/tags/*) git fetch --no-tags origin $(LWIP_REF):$(LWIP_REF) ;; \
			  *) git fetch origin $(LWIP_REF) ;; \
			esac \
			&& git checkout -f $(LWIP_REF) -- ; \
		fi
endef

define lwip-reset
	@test -r "$(LWIP_ROOT)"/.git
	@cd "$(LWIP_ROOT)" \
		&& git reset --hard \
		&& git clean -x -f -d
endef

define lwip-patch
	@set -e; for p in $(PATCHES) ; do \
		(set -x; patch -d "$(LWIP_ROOT)" -p1 -i $$p ); \
	done
endef

define lwip-all
	$(lwip-checkout)
	$(lwip-reset)
	$(lwip-patch)
endef

.PHONY: lwip

lwip:
	$(lwip-all)

.PHONY: checkout reset patch

checkout:
	$(lwip-checkout)

reset:
	$(lwip-reset)

patch:
	$(lwip-patch)
