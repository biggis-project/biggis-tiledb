package de.biggis.flink.messages

import de.biggis.flink.Geometry
import org.eclipse.xtend.lib.annotations.Data

interface BiggisMessage {}

@Data
class TileDiscoveredMsg implements BiggisMessage {
    String uri
}

@Data
class TileIndexedMsg implements BiggisMessage {
    long tileid
    Geometry tileExtent
}

@Data
class LocalStatsMsg implements BiggisMessage {

    double old_mean
    double new_mean
    
    double old_stddev
    double new_stddev
    
    Geometry tileExtent
}

