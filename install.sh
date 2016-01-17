#!/usr/bin/env sh
sqlite3 mebious.db < models/schema/posts.sql
sqlite3 mebious.db < models/schema/bans.sql
