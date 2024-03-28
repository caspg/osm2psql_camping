local camp_sites = osm2pgsql.define_table({
    name = 'camp_sites',
    ids = {
        type = 'any',
        type_column = 'osm_type',
        id_column = 'osm_id'
    },
    columns = {{
        column = 'name'
    }, {
        column = 'website'
    }, {
        column = 'backcountry'
    }, {
        column = 'tents'
    }, {
        column = 'geom',
        type = 'point',
        not_null = true,
        projection = 4326
    }}
})

function is_campsite(object)
    return object.tags.tourism == 'camp_site'
end

function process_poi(object, geom)
    local fields = {
        name = object.tags.name,
        website = object.tags.website,
        backcountry = object.tags.backcountry,
        tents = object.tags.tents,
        geom = geom
    }

    -- TODO: if name is not existing and edited was X years ago, ignore

    local inserted, message, column, object = camp_sites:insert(fields)

    if not inserted then
        print('Error: ', inserted, message, column, object)
    end
end

function osm2pgsql.process_node(object)
    if is_campsite(object) then
        process_poi(object, object:as_point())
    end
end

function osm2pgsql.process_way(object)
    if object.is_closed and is_campsite(object) then
        process_poi(object, object:as_polygon():centroid())
    end
end
