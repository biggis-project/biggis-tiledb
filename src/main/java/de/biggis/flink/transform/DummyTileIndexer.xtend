package de.biggis.flink.transform

import de.biggis.flink.BiggisTransformation
import de.biggis.flink.TileDb
import de.biggis.flink.messages.TileDiscoveredMsg
import de.biggis.flink.messages.TileIndexedMsg

@Deprecated
class DummyTileIndexer {
    def static void main(String[] args) {
        
        val tiledb = new TileDb
        val biggis = new BiggisTransformation

        biggis.addTransform(TileDiscoveredMsg, TileIndexedMsg, [ msg |
           val tile = tiledb.createNewTile(msg.uri)
           new TileIndexedMsg(tile.tileid, tile.extent)
           => [println(it)] // DEBUG
        ])
        biggis.execute
    }
    
}