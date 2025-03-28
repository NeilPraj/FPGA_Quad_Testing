set io_pins { \
		clk				R20 "3.3-V LVTTL" \
		a 					T21 "3.3-V LVTTL" \
		b 					K25 "3.3-V LVTTL" \
		reset_pos		P11 "1.2-V" \
		direction		K26 "3.3-V LVTTL" \
		
		
		"position[0]"  M21 "3.3-V LVTTL"\
		"position[1]"  T22 "3.3-V LVTTL"\
		"position[2]"  U19 "3.3-V LVTTL"\
		"position[3]"  P8  "3.3-V LVTTL"\
		"position[4]"  R9  "3.3-V LVTTL"\
		"position[5]"  F26 "3.3-V LVTTL"\
      "position[6]"  G26 "3.3-V LVTTL"\
      "position[7]"  AA7 "3.3-V LVTTL"\
		
		
		"position_leds[0]"	L7 "2.5-V"\
		"position_leds[1]"	K6 "2.5-V"\
		"position_leds[2]"	D8 "2.5-V"\
		"position_leds[3]"	E9	"2.5-V"\
		"position_leds[4]"	A5 "2.5-V"\
		"position_leds[5]"	B6 "2.5-V"\
		"position_leds[6]"	H8 "2.5-V"\
		"position_leds[7]"	H9 "2.5-V"\
	}
	
foreach { signal pin iostd } ${io_pins} {
	set_location_assignment PIN_${pin} -to ${signal}
	set_instance_assignment -name IO_STANDARD "${iostd}" -to ${signal}
}