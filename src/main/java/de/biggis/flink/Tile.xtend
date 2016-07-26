package de.biggis.flink

import java.math.BigInteger
import java.sql.Timestamp
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

@Data
class Geometry {
    String geom

    new(String stringValue) {
        geom = stringValue
    }
    
    new() {this("")}
    new(String topleft, String topright, String bottomright, String bottomleft) {
        this('''polygon((«topleft», «topright», «bottomright», «bottomleft», «topleft»))''')
    }

    override toString() { geom }
}

class Tile {

    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) long tileid
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) String uri
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Geometry extent
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Geometry update_area
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Timestamp update_past
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Timestamp ts
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) Timestamp ts_idx
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) long transid
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) double pixel_mean
    @Accessors(PUBLIC_GETTER, PUBLIC_SETTER) double pixel_stdev

    def toSetter(String fieldName) {
        val fieldType = class.getDeclaredField(fieldName).type
        class.getMethod('''set«fieldName.toFirstUpper»''', fieldType)
    }

    dispatch def void setFieldByName(String fieldName, BigInteger bigint) {
        setFieldByName(fieldName, bigint.longValue)
    }
    
    dispatch def void setFieldByName(String fieldName, Void _null_) {
        fieldName.toSetter.invoke(this, _null_)
    }
    
    dispatch def void setFieldByName(String fieldName, Object value) {
        fieldName.toSetter.invoke(this, value.fixGeometryValue(fieldName))
    }
    
    // TODO: by type, not hardcoded
    def fixGeometryValue(Object value, String fieldName) {
        switch(value) {
            String: switch(fieldName) {
                case "extent",
                case "update_area" : new Geometry(value)
                default: value
            }                
            default: value
        }
    }
    
    override equals(Object obj) {
        switch(obj) {
            Tile:  tileid == obj.tileid
                && uri == obj.uri
                && extent == obj.extent
                && update_area == obj.update_area
                && ts == obj.ts
                && ts_idx == obj.ts_idx
                && transid == obj.transid
                && pixel_mean == obj.pixel_mean
                && pixel_stdev == obj.pixel_stdev
                && update_past == obj.update_past
            default: false
        }
    }
}
