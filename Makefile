TB := $(basename $(notdir $(wildcard tb/*.v))) 
TB_VVP := $(addsuffix .vvp,$(TB)) 

.PHONY: all clean

all: $(TB_VVP)

clean:
	rm *.vvp

define TB_template =
$(1).vvp: $$($(1)_cmd)
	@echo Building $(1).vvp
	@iverilog -c $(1).cmd -o $(1).vvp
endef

$(foreach tb,$(TB),$(eval $(tb)_cmd := $(shell cat $(tb).cmd)))
$(foreach tb,$(TB),$(eval $(call TB_template,$(tb))))

