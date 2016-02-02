create table if not exists posts (
       id integer primary key autoincrement, 
       text varchar(512),
       spawn integer,
       ip varchar(512),
       is_admin tinyint(1) 
);
