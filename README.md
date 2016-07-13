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

# Database schema
``` sql
-- PostGIS only: CREATE EXTENSION postgis;

CREATE DATABASE tiledb;
drop table if exists tiles; -- cleanup
create table tiles (
  tileid serial primary key,
  fname varchar(100) unique not null, -- image location
  
  -- the map extend of this tile
  extent geometry,
  
  -- the tile has to be regenerated if something within update_area
  -- and in a time frame between now and update_past
  update_area geometry,
  update_past timestamp,
  
  ts timestamp, -- time dimension of the tile
  ts_idx timestamp, -- when the tile was indexed
  
  -- to distinguish amongst different data sources
  source int
);
```

## Useful queries
``` sql
-- find all tiles "a" that are affected
-- by change in tile "b" (here with tileid=3)
SELECT 
    a.*
FROM
    tiles AS a,
    tiles AS b
WHERE
    ST_INTERSECTS(a.update_area, b.extent)
        AND a.tileid <> b.tileid
        AND b.tileid = 3
```

## Sample data
``` sql
insert into tiles(tileid, fname, extent, update_area, ts, ts_idx) values
(2, "test2",
ST_PolygonFromText('polygon((0 0, 1 0, 1 1, 0 1, 0 0))'),
ST_PolygonFromText('polygon((-1 -1, 2 -1, 2 2, -1 2, -1 -1))'),
"2016-07-10 00:00:00", "2016-07-10 00:00:01"),
(3, "test3",
ST_PolygonFromText('polygon((1 0, 2 0, 2 1, 1 1, 1 0))'),
ST_PolygonFromText('polygon((0 -1, 3 -1, 3 2, 0 2, 0 -1))'),
"2016-07-10 00:00:00", "2016-07-10 00:00:01");
```

# Useful links
- http://www.gdal.org/frmt_gtiff.html
- http://www.gdal.org/gdal_translate.html
