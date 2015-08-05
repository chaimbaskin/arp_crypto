####################################################
# Makefile to compile java source code for the GUI
#
# Author: Jad Naous
#


# Directories
SRC := src
BIN := bin
LIB := lib

#COMMON_C := ../common
#REG_C := ../../../projects/router_buffer_sizing/lib/C

NFSUMELIB_PATH := $(SUME_FOLDER)/lib/sw/std/hwtestlib

JAVAC := javac
JAVA := java
JAR := jar

JAVA_SRC_FILES := $(wildcard $(SRC)/org/netfpga/backend/*.java)
JAVA_SRC_FILES += $(wildcard $(SRC)/org/netfpga/graphics/*.java)
JAVA_SRC_FILES += $(wildcard $(SRC)/org/netfpga/mdi/*.java)
JAVA_SRC_FILES += $(wildcard $(SRC)/org/netfpga/router/*.java)

CONSTANTS_JAVA := $(SRC)/org/netfpga/backend/NFDeviceConsts.java

NFSUMELIB := $(NFSUMELIB_PATH)/libsume.so

# utils
EMPTY =
SPACE = $(EMPTY) $(EMPTY)

# setup the classpath
CLASSPATH := $(subst $(SPACE),:,$(wildcard $(LIB)/*.jar))

# compiler options
JAVAC_OPTIONS := -d $(BIN) -classpath $(CLASSPATH) -sourcepath $(SRC)

# rules
all: swlib $(NFSUMELIB) convert $(CONSTANTS_JAVA) router.sh eventcap.sh 

#$(NFSUMELIB): $(COMMON_C)/$(NFSUMELIB_NAME)
#	@cp $< $@

#$(COMMON_C)/$(NFSUMELIB_NAME):
#	@$(MAKE) -C $(dir $@) $(notdir $@)

swlib:
	@echo Building SW LIB
	if [ -a $(NFSUMELIB)]; \
	then \
		$(MAKE) -C $(NFSUMELIB_PATH)/ clean; \
	else \
		$(MAKE) -C $(NFSUMELIB_PATH)/; \
#		cp $(NFSUMELIB) $(LIB); \
	fi;
	@echo sw lib build Done


java: $(CONSTANTS_JAVA) $(JAVA_SRC_FILES)
	@echo Building java...
	@$(JAVAC) $(JAVAC_OPTIONS) $(JAVA_SRC_FILES)
	@echo Done

convert:
	./convert.py

$(CONSTANTS_JAVA): ./reg_defines_com.h
	@echo "/**********************************************************************" > $@
	@echo " * File generated using the Makefile from $<." >> $@
	@echo " * Author: Jad Naous" >> $@
	@echo " */" >> $@
	@echo "" >> $@
	@echo "package $(patsubst %.,%;,$(subst /,.,$(subst $(SRC)/,$(EMPTY),$(dir $@))))" >> $@
	@echo "" >> $@
	@echo "public class $(notdir $(basename $@)) {" >> $@
	@awk '(NF == 3) && ($$1 == "#define") && (length($$3) < 11) {printf "   public static final int %-50s = %s;\n", $$2, $$3}' $< >> $@
	@echo "}" >> $@
	@echo "" >> $@

$(BIN)/router-manifest.mf:
	@echo "Writing router gui manifest..."
	@echo "Main-Class: org.netfpga.router.RouterMainFrame" > $@
	@echo "Class-Path: $(wildcard $(LIB)/*.jar)" >> $@
	@echo >> $@

router_gui.jar: $(NFSUMELIB) java $(BIN)/router-manifest.mf
	@echo "Building router jar..."
	@cd $(BIN); $(JAR) cfm ../$@ router-manifest.mf org
	@rm -f $(BIN)/router-manifest.mf

router.sh: router_gui.jar
	@echo "Writing script to start router gui..."
	@echo "$(JAVA) -Djava.library.path=$(LIB) -Djna.library.path=$(LIB):$(NFSUMELIB_PATH) -jar router_gui.jar --no_download" > $@
	@echo >> $@
	@chmod +x $@

$(BIN)/eventcap-manifest.mf:
	@echo "Writing event capturing router gui manifest..."
	@echo "Main-Class: org.netfpga.eventcap.EventCaptureMainFrame" > $@
	@echo "Class-Path: $(wildcard $(LIB)/*.jar)" >> $@
	@echo >> $@

eventcap_gui.jar: $(NFSUMELIB) java $(BIN)/eventcap-manifest.mf
	@echo "Building event capturing router jar..."
	@cd $(BIN); $(JAR) cfm ../$@ eventcap-manifest.mf org
	@rm -f $(BIN)/eventcap-manifest.mf

eventcap.sh: eventcap_gui.jar
	@echo "Writing script to start event capturing router gui..."
	@echo "$(JAVA) -Djava.library.path=$(LIB) -Djna.library.path=$(LIB):$(NFSUMELIB_PATH) -jar eventcap_gui.jar --no_download" > $@
	@echo >> $@
	@chmod +x $@

install:

clean:
#	@rm -rf $(COMMON_C)/$(NFSUMELIB_NAME)
	@rm -rf $(BIN)/* router_gui.jar router.sh eventcap.sh eventcap_gui.jar
	@rm -rf $(CONSTANTS_JAVA)
#	@rm -rf $(NFSUMELIB)
	@rm -rf ./logregsReg
	@rm -rf ./reg_defines_com.h
