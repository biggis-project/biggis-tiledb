# biggis-tiledb
Database for indexed tiles (M3 demo)

# Notes
- thermal filght TIFFs have to be manually copied to the data directory due to licensing
- `gdal.jar` and related JNI files have to be installed on the linux machine (tested with gdal 1.10.1)
- in Eclipse, the `.classpath` file is configured to use the JNI files from `/usr/lib/jni`

# Preparing tiles
- make sure that TIFFs `abend_tmp.tif` and `morgen_tmp.tif` are copied to `data/` dir
- in the root of `biggis-tiledb` directory run:
``` sh
make
```

# Useful links
- http://www.gdal.org/frmt_gtiff.html
- http://www.gdal.org/gdal_translate.html
