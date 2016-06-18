#!/usr/bin/env sh
sqlite3 mebious.db < models/schema/posts.sql
sqlite3 mebious.db < models/schema/bans.sql
sqlite3 mebious.db < models/schema/api.sql
sqlite3 mebious.db < models/schema/images.sql
sqlite3 mebious.db < models/schema/filters.sql
mkdir -p public/images
