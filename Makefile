SPLIT_APP = R/split_to_tiles.R
SPLIT_ROWS = 7
SPLIT_COLS = 5
TILES_DIR = data/tiles

all: $(TILES_DIR)/evening*.tif $(TILES_DIR)/morning*.tif

data/%_EPSG_31467.tif:
	make -C data

$(TILES_DIR)/evening*.tif: data/evening_EPSG_31467.tif
	$(SPLIT_APP) --nrow $(SPLIT_ROWS) --ncol $(SPLIT_COLS) --meta "TIFFTAG_DATETIME=2008:09:26 20:00:00" -- $< $(TILES_DIR)

$(TILES_DIR)/morning*.tif: data/morning_EPSG_31467.tif
	$(SPLIT_APP) --nrow $(SPLIT_ROWS) --ncol $(SPLIT_COLS) --meta "TIFFTAG_DATETIME=2008:09:26 06:30:00" -- $< $(TILES_DIR)

.PHONY: clean

clean:
	make clean -C data
	rm $(TILES_DIR)/*
	rmdir $(TILES_DIR)
