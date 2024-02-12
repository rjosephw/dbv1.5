INSERT INTO Cities  (City_Name, State_Name, Country_Name)
SELECT  city_name, state_name, country_name
FROM (
    SELECT DISTINCT current_city AS city_name, current_state AS state_name, current_country AS country_name from    public_user_information
    UNION
    SELECT DISTINCT hometown_city AS city_name, hometown_state AS state_name, hometown_country AS country_name from    public_user_information
    union 
    select DISTINCT e.event_city AS city_name , e.event_state AS state_name, e.event_country AS country_name from   public_event_information e
);


INSERT INTO Programs (institution, concentration, degree)
SELECT DISTINCT institution_name, program_concentration, program_degree
FROM public_User_Information
WHERE institution_name IS NOT NULL
  AND program_concentration IS NOT NULL
  AND program_degree IS NOT NULL;

insert into users 
(select distinct user_id, first_name, last_name, year_of_birth, month_of_birth, day_of_birth, gender
from    public_user_information p);
commit;

INSERT INTO User_Current_Cities (user_id, Current_City_ID)
SELECT pu.user_id, c.city_id
FROM public_User_Information pu
LEFT JOIN Cities c ON pu.current_city = c.city_name AND pu.current_state = c.state_name AND pu.current_country = c.country_name;
 
 insert into user_hometown_cities (user_id, hometown_city_id)
select pu.user_id , c.city_id  from    public_user_information pu JOIN cities c ON pu.hometown_city = c.city_name and
 pu.hometown_state = c.state_name and pu.hometown_country = c.country_name;



 INSERT INTO Education (user_id, program_id, program_year)
SELECT
    PUI.user_id,
    P.program_id,
    PUI.program_year
FROM
    public_User_Information PUI
JOIN
    Programs P ON PUI.institution_name = P.institution
             AND PUI.program_concentration = P.concentration
             AND PUI.program_degree = P.degree
WHERE
    PUI.institution_name IS NOT NULL
    AND PUI.program_concentration IS NOT NULL
    AND PUI.program_degree IS NOT NULL;
    
insert into Friends 
(select user1_id, user2_id from   public_Are_Friends);
commit;
SET AUTOCOMMIT OFF;
insert into photos(photo_id ,album_id, photo_caption, photo_created_time, photo_modified_time, photo_link) 
(select distinct photo_id, album_id, photo_caption, photo_created_time, photo_modified_time, photo_link from   public_Photo_Information);
insert into albums(album_id, album_owner_id, album_name, album_created_time, album_modified_time, album_link, album_visibility, cover_photo_id) 
(select distinct album_id, owner_id, album_name, album_created_time, album_modified_time, album_link, album_visibility, cover_photo_id from   public_Photo_Information pp);
commit;
SET AUTOCOMMIT ON;

commit;
insert into tags  (select distinct photo_id, tag_subject_id, tag_created_time, tag_x_coordinate, tag_y_coordinate from   public_Tag_Information);
commit;
insert into user_events  (select distinct event_id, event_creator_id, event_name, event_tagline, event_description, event_host, event_type, event_subtype, event_address,
 c.city_id ,event_start_time, event_end_time from   public_Event_Information e, cities c where c.city_name = e.event_city );
 commit;
