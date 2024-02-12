create or replace view View_User_Information as 
 SELECT 
    u.user_id, u.first_name, u.last_name,
    u.year_of_birth, u.month_of_birth, u.day_of_birth,
    u.gender,
    cc.city_name as current_city, cc.state_name as current_state, cc.country_name as current_country,
    hc.city_name as hometown_city, hc.state_name as hometown_state, hc.country_name as hometown_country,
    prog.institution as institution_name, edu.program_year,
    prog.concentration as program_concentration, 
    prog.degree as program_degree
FROM 
    users u
LEFT JOIN 
    education edu ON edu.user_id = u.user_id
LEFT JOIN 
    programs prog ON edu.program_id = prog.program_id
LEFT JOIN 
    user_hometown_cities ht ON ht.user_id = u.user_id
LEFT JOIN 
    cities hc ON ht.hometown_city_id = hc.city_id
LEFT JOIN 
    user_current_cities ct ON ct.user_id = u.user_id
LEFT JOIN 
    cities cc ON ct.current_city_id = cc.city_id;
create or replace view View_Are_Friends as select * from friends;
commit;
create or replace view View_Photo_Information as
select a.album_id, a.album_owner_id as owner_id,
a.cover_photo_id, a.album_name, a.album_created_time, 
a.album_modified_time , a.album_link, a.album_visibility,  p.photo_id, p.photo_caption, p.photo_created_time,p.photo_modified_time,
p.photo_link from photos p, albums a
where p.album_id=a.album_id;
commit;

create or replace view View_Event_Information as
select e.event_id, e.event_creator_id, e.event_name,
e.event_tagline, e.event_description, e.event_host,
e.event_type, e.event_subtype, e.event_address,
c.city_name as event_city, c.state_name as event_State,
c.country_name as event_country , e.event_start_time,
e.Event_End_Time from user_events e , cities c
where e.event_city_id = c.city_id;

create or replace view View_Tag_Information as select * from tags;



