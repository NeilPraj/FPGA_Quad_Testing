set io_pins { \
		clock	R20 "3.3-V LVTTL" \
		reset	P11 "1.2-V" \
		led		F7	"2.5-V" \
	}
	
foreach { signal pin iostd } ${io_pins} {
	set_location_assignment PIN_${pin} -to ${signal}
	set_instance_assignment -name IO_STANDARD "${iostd}" -to ${signal}
}