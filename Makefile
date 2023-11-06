ALL_SOURCES := $(wildcard src/*.vhd src/**/*.vhd src/**/**/*.vhd)
TEST_FILES := $(wildcard test/*.vhd test/**/*.vhd)

dist : pangman.zip
	unzip pangman.zip -d $@

pangman.zip : $(ALL_SOURCES) $(TEST_FILES)
	zip -rj $@ $(ALL_SOURCES) $(TEST_FILES)


clean :
	rm pangman.zip
	rm dist/*