log -r *
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
view wave1
do nsb.do
view wave2
do pref.do
view wave3
do age.do
view wave4
do fte.do
run -all
view wave
wave zoom full
view wave1
wave zoom full
view wave2
wave zoom full
view wave3
wave zoom full
view wave4
wave zoom full
