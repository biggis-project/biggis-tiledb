package de.biggis.flink

import java.lang.reflect.Modifier
import java.sql.Timestamp
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

@Data
class Polygon {
    
    String topleft
    String topright
    String bottomright
    String bottomleft
    
    override toString() '''
        polygon(( «topleft», «topright», «bottomright», «bottomleft», «topleft» ))
    '''
}

class Tile {
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) long tileid
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) String uri
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Polygon extent
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Polygon update_area
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Timestamp update_past
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Timestamp ts
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Timestamp ts_idx
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) long transid
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) long collisions
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) double pixel_mean
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) double pixel_stdev
    
    // list only non-transient fields
    override toString() '''
        «class.simpleName» [
            «FOR f : this.class.declaredFields.filter[!Modifier.isTransient(modifiers)]»
                «f.name» = "«f.get(this)»"
            «ENDFOR»
        ]
    '''
}
