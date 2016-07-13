TO_GAUSS_KRUGER = gdalwarp -t_srs EPSG:31467
TO_WGS84 = gdalwarp -t_srs WGS84

all: gauss-kruger wgs84

gauss-kruger: morning_EPSG_31467.tif evening_EPSG_31467.tif

wgs84: morning_WGS84.tif evening_WGS84.tif


morning_EPSG_31467.tif: morgen_tmp.tif
	$(TO_GAUSS_KRUGER) $< $@

morning_WGS84.tif: morning_EPSG_31467.tif
	$(TO_WGS84) $< $@

evening_EPSG_31467.tif: abend_tmp.tif
	$(TO_GAUSS_KRUGER) $< $@

evening_WGS84.tif: evening_EPSG_31467.tif
	$(TO_WGS84) $< $@


# The .PHONY rule keeps make from doing something with a file named clean.
.PHONY: clean

clean:
	rm *_EPSG_31467.tif *_WGS84.tif
