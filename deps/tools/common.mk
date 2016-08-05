## Some shared configuration options ##

CONFIGURE_COMMON := --prefix=$(abspath $(build_prefix)) --build=$(BUILD_MACHINE) --libdir=$(abspath $(build_libdir)) --bindir=$(abspath $(build_depsbindir)) $(CUSTOM_LD_LIBRARY_PATH)
ifneq ($(XC_HOST),)
CONFIGURE_COMMON += --host=$(XC_HOST)
endif
ifeq ($(OS),WINNT)
ifneq ($(USEMSVC), 1)
CONFIGURE_COMMON += LDFLAGS="$(LDFLAGS) -Wl,--stack,8388608"
endif
endif
CONFIGURE_COMMON += F77="$(FC)" CC="$(CC) $(DEPS_CFLAGS)" CXX="$(CXX) $(DEPS_CXXFLAGS)"

CMAKE_CC_ARG := $(CC_ARG) $(DEPS_CFLAGS)
CMAKE_CXX_ARG := $(CXX_ARG) $(DEPS_CXXFLAGS)

CMAKE_COMMON := -DCMAKE_INSTALL_PREFIX:PATH=$(build_prefix) -DCMAKE_PREFIX_PATH=$(build_prefix)
CMAKE_COMMON += -DCMAKE_INSTALL_LIBDIR=$(build_libdir) -DCMAKE_INSTALL_BINDIR=$(build_bindir)
CMAKE_COMMON += -DLIB_INSTALL_DIR=$(build_shlibdir)
ifneq ($(VERBOSE), 0)
CMAKE_COMMON += -DCMAKE_VERBOSE_MAKEFILE=ON
endif
# The call to which here is to work around https://cmake.org/Bug/view.php?id=14366
CMAKE_COMMON += -DCMAKE_C_COMPILER="$$(which $(CC_BASE))"
ifneq ($(strip $(CMAKE_CC_ARG)),)
CMAKE_COMMON += -DCMAKE_C_COMPILER_ARG1="$(CMAKE_CC_ARG)"
endif
CMAKE_COMMON += -DCMAKE_CXX_COMPILER="$(CXX_BASE)"
ifneq ($(strip $(CMAKE_CXX_ARG)),)
CMAKE_COMMON += -DCMAKE_CXX_COMPILER_ARG1="$(CMAKE_CXX_ARG)"
endif

ifeq ($(OS),WINNT)
CMAKE_COMMON += -DCMAKE_SYSTEM_NAME=Windows
ifneq ($(BUILD_OS),WINNT)
CMAKE_COMMON += -DCMAKE_RC_COMPILER="$$(which $(CROSS_COMPILE)windres)"
endif
endif

# For now this is LLVM specific, but I expect it won't be in the future
ifeq ($(LLVM_USE_CMAKE),1)
ifeq ($(CMAKE_GENERATOR),Ninja)
CMAKE_GENERATOR_COMMAND := -G Ninja
else ifeq ($(CMAKE_GENERATOR),make)
CMAKE_GENERATOR_COMMAND := -G "Unix Makefiles"
else
$(error Unknown CMake generator '$(CMAKE_GENERATOR)'. Options are 'Ninja' and 'make')
endif
endif

# If the top-level Makefile is called with environment variables,
# they will override the values passed above to ./configure
MAKE_COMMON := DESTDIR="" prefix=$(build_prefix) bindir=$(build_depsbindir) libdir=$(build_libdir) shlibdir=$(build_shlibdir) libexecdir=$(build_libexecdir) datarootdir=$(build_datarootdir) includedir=$(build_includedir) sysconfdir=$(build_sysconfdir) O=


#Platform specific flags

ifeq ($(OS), WINNT)
LIBTOOL_CCLD := CCLD="$(CC) -no-undefined -avoid-version"
endif


## PATHS ##
# sort is used to remove potential duplicates
DIRS := $(sort $(build_bindir) $(build_depsbindir) $(build_libdir) $(build_includedir) $(build_sysconfdir) $(build_datarootdir) $(build_staging) $(build_prefix)/manifest)

$(foreach dir,$(DIRS),$(eval $(call dir_target,$(dir))))

$(build_prefix): | $(DIRS)
$(eval $(call dir_target,$(SRCDIR)/srccache))


## A rule for calling `make install` ##
#	rule: dependencies
#   	$(call make-install,rel-build-directory,add-args)
#   	touch -c $@
# this rule ensures that make install is more nearly atomic
# so it's harder to get half-installed (or half-reinstalled) dependencies
MAKE_DESTDIR = "$(build_staging)/$1"
define staged-install
	rm -rf $(build_staging)/$1
	$2
	mkdir -p $(build_prefix)
	cp -af $(build_staging)/$1$(build_prefix)/* $(build_prefix)
endef

define make-install
	$(call staged-install,$1,+$(MAKE) -C $(BUILDDIR)/$1 install $(MAKE_COMMON) $2 DESTDIR=$(call MAKE_DESTDIR,$1))
endef

## phony targets ##

.PHONY: default get extract configure compile install cleanall distcleanall \
	get-* extract-* configure-* compile-* check-* install-* \
	clean-* distclean-* reinstall-* update-llvm
