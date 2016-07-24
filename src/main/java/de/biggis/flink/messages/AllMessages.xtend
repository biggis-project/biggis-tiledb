package de.biggis.flink.messages

import org.eclipse.xtend.lib.annotations.Data
import de.biggis.flink.Polygon

interface BiggisMessage {}

@Data
class TileDiscoveredMsg implements BiggisMessage {
    String uri
}

@Data
class TileIndexedMsg implements BiggisMessage {
    long tileid
    Polygon tileExtent
}

@Data
class LocalStatsMsg implements BiggisMessage {

    double old_mean
    double new_mean
    
    double old_stddev
    double new_stddev
    
    Polygon tileExtent
}

