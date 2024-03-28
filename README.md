# osm2psql camping

Notes and scripts to import camping POIs from osm.
Based on: https://mvexel.prose.sh/20230227-keeping-osm-database-uptodate-osm2pgsql

1. Install `osm2psql`

https://osm2pgsql.org/doc/install.html

```bash
brew install osm2pgsql
```

2. Download osm file:

```bash
curl https://download.geofabrik.de/europe/poland/pomorskie-latest.osm.pbf -o ./tmp/pomorskie.osm.pbf
```

3. Create the database and enable PostGIS

```bash
# -O owner
createdb -O postgress osm_campsites
psql -d osm_campsites -c 'create extension postgis'
```

4. Load the data

```bash
osm2pgsql --slim -H localhost -U postgres -P 5432 -d osm_campsites -x -O flex -S camp_sites.lua -c tmp/pomorskie.osm.pbf
```

<!--  osm2pgsql took 100s (1m 40s) overall -->

- `--slim`: use "slim mode". This slows down the initial import but is required if we want to keep the database updated.
- `-d osm`: the database to use
- `-x`: read the OSM object's attributes (version, timestamp). osm2pgsql skips these by default for performance reasons, but we need them.
- `-O flex`: use flex mode (allow to use lua)
- `-s camp_sites.lua`: the lua mapping file to use
- `-c tmp/pomorskie.osm.pbf`: the input file to use
