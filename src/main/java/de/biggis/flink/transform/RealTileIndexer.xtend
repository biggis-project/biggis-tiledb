package de.biggis.flink.transform

import de.biggis.flink.BiggisTransformation
import de.biggis.flink.Geometry
import de.biggis.flink.TileDb
import de.biggis.flink.messages.TileDiscoveredMsg
import de.biggis.flink.messages.TileIndexedMsg
import java.sql.Timestamp
import java.time.Instant
import org.gdal.gdal.gdal

class RealTileIndexer {
    def static void main(String[] args) {
        
        // GDAL initialization
        gdal.AllRegister // to recognize all formats
        println(gdal.VersionInfo)

        val tiledb = new TileDb
        val biggis = new BiggisTransformation

        biggis.addTransform(TileDiscoveredMsg, TileIndexedMsg, [ msg |
            
            val tile = tiledb.createNewTile(msg.uri)
            val raster = gdal.Open(tile.uri)

            raster.GetGeoTransform => [
                val sx = raster.rasterXSize
                val sy = raster.rasterYSize
                tile.extent = new Geometry(
                    point(0,0),
                    point(sx,0),
                    point(0,sy),
                    point(sx,sy)
                )
            ]
            
            tile.update_area = tile.extent

            // timestamp of the tile
            tile.ts = raster.GetMetadataItem("TIFFTAG_DATETIME").toTimestamp
            tile.update_past = tile.ts
            
            tiledb.updateTile(tile) // DB insert or replace
           
            new TileIndexedMsg(tile.tileid, tile.extent)
            => [println(it)] // DEBUG
        ])
        biggis.execute
    }
    
    static def toTimestamp(String str) {
         Timestamp.from(Instant.parse(str.fixDatetime))
    }
    
    static def fixDatetime(String datetime) {
        datetime.replaceAll("^(....):(..):(..) (.*)", "$1-$2-$3T$4Z")
    }
 
    static def String point(double[] gt, int x, int y)
        '''«gt.transx(x)» «gt.transy(y)»'''
 
    static def transx(double[] gt, int x) {
        gt.get(0) + x * gt.get(1)
    }

    static def transy(double[] gt, int y) {
        gt.get(3) + y * gt.get(5)
    }
   
}