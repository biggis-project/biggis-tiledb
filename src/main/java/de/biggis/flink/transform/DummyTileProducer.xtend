package de.biggis.flink.transform

import de.biggis.flink.BiggisTransformation
import de.biggis.flink.messages.TileDiscoveredMsg
import java.io.File
import java.util.Collections
import org.apache.commons.io.FileUtils

class DummyTileProducer {

    def static void main(String[] args) {
        val biggis = new BiggisTransformation
        biggis.addProducer(TileDiscoveredMsg, [iteration|
            val files = FileUtils
                .listFiles(new File("/home/vlx/Work/biggis/biggis-tiledb/data/tiles"), #["tif"], false)
                .map[toString].toList
            
            Collections.shuffle(files)
            new TileDiscoveredMsg(files.head) => [
                println('''iteration #«iteration»: «it»''')
                Thread.sleep(1000)
            ]
        ])
        biggis.execute
    }
}
