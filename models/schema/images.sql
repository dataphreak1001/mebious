create table if not exists images (
       id integer primary key autoincrement, 
       url varchar(32),
       spawn integer,
       ip varchar(512),
       checksum varchar(512)
);
