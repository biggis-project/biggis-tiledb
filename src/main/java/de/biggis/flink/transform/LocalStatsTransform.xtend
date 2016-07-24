package de.biggis.flink.transform

import de.biggis.flink.BiggisTransformation
import de.biggis.flink.TileDb
import de.biggis.flink.messages.LocalStatsMsg
import de.biggis.flink.messages.TileIndexedMsg
import org.gdal.gdal.gdal

class LocalStatsTransform {
    def static void main(String[] args) {

        // GDAL initialization
        gdal.AllRegister // to recognize all formats
        println(gdal.VersionInfo)

        val tiledb = new TileDb
        val biggis = new BiggisTransformation

        biggis.addTransform(TileIndexedMsg, LocalStatsMsg, [ msg |

            // TODO: later, we just need a key-value store for hashing the values by tileid
            val tile = tiledb.getTileById(msg.tileid)
            
            // fail fast if the tile does not exist
            if(tile == null)
                return null

            println(tile.extent)
            
            // the tile exists and we will update its mean pixel value
            val old_mean = tile.pixel_mean
            val old_stdev = tile.pixel_stdev

            val raster = gdal.Open(tile.uri)
            
            val band = raster.GetRasterBand(1)
            
            var double[] gdal_min = newDoubleArrayOfSize(1)
            var double[] gdal_max = newDoubleArrayOfSize(1)
            var double[] gdal_mean = newDoubleArrayOfSize(1)
            var double[] gdal_stddev = newDoubleArrayOfSize(1)
            
            band.GetStatistics(false, true, gdal_min, gdal_max, gdal_mean, gdal_stddev)
            
            tile.pixel_mean = gdal_mean.get(0)
            tile.pixel_stdev = gdal_stddev.get(0)

            tiledb.updateTile(tile)
            println(tile)
            null

//            new LocalStatsMsg(
//                old_mean, tile.pixel_mean,
//                old_stdev, tile.pixel_stdev,
//                tile.extent
//            )
//            
//            => [println(it)] // DEBUG
        ])
        biggis.execute
    }
}
