#  ubuntu ----------------------------------
# to_bytes32_paddingLeft = $(shell echo "000000000000000000000000$(echo $(1) | cut -c 3-)")

# to_bytes32:
#	@echo $(call to_bytes32_paddingLeft, $(address))

# windows --------------------------------
to_bytes32_paddingLeft = $(shell powershell -Command "[System.String]::Format('000000000000000000000000{0}', '$(address)'.Substring(2))")

to_bytes32:
	@echo $(call to_bytes32_paddingLeft)
