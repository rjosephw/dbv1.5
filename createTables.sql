    CREATE SEQUENCE Cities_seq
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE
    NOCACHE;
    CREATE SEQUENCE program_seq
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE
    NOCACHE;



CREATE TABLE Cities (
    city_id INTEGER PRIMARY KEY,
    city_name VARCHAR2(100) NOT NULL,
    state_name VARCHAR2(100) NOT NULL,
    country_name VARCHAR2(100) NOT NULL
);
ALTER TABLE Cities
ADD CONSTRAINT unq_cty
UNIQUE (city_name, state_name, country_name);

CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    year_of_birth INTEGER,
    month_of_birth INTEGER,
    day_of_birth INTEGER,
    gender VARCHAR2(100)
);

CREATE TABLE User_Current_Cities (
user_id INTEGER not null,
Current_City_ID INTEGER not null,
FOREIGN KEY (user_id) REFERENCES users(user_id),
FOREIGN KEY (Current_City_ID) REFERENCES Cities(city_id)
);
ALTER TABLE User_Current_Cities
ADD CONSTRAINT UQ_CC
UNIQUE (user_id);

CREATE table User_Hometown_Cities(
user_id integer not null,
hometown_city_id integer not null,
FOREIGN KEY (user_id) REFERENCES users(user_id),
FOREIGN KEY (hometown_city_id) REFERENCES Cities(city_id)
);
ALTER TABLE User_Hometown_Cities
ADD CONSTRAINT UQ_HC
UNIQUE (user_id);

CREATE TABLE Programs (
    program_id INTEGER PRIMARY KEY,
    institution VARCHAR2(100) NOT NULL,
    concentration VARCHAR2(100) NOT NULL,
    degree VARCHAR2(100) NOT NULL
);
ALTER TABLE programs
ADD CONSTRAINT unq_Prog
UNIQUE (institution, concentration, degree);


CREATE TABLE Education (
    user_id INTEGER NOT null,
    program_id INTEGER NOT NULL,
    program_year INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (program_id) REFERENCES Programs(program_id)
);
ALTER TABLE Education
ADD CONSTRAINT unq_edu
UNIQUE (user_id, program_id);
commit;



/*create or replace TRIGGER reject_error_entry 
AFTER UPDATE ON Education FOR EACH ROW
DECLARE

   PRAGMA AUTONOMOUS_TRANSACTION;
   py char(100);
BEGIN
     select distinct program_year into py from education where :NEW.program_id = education.program_id
    and :NEW.USER_ID = education.user_id;

     If py <> :NEW.program_year then  RAISE_APPLICATION_ERROR ( -20003,
        'Not Allowed to enter already completed program in different year' );
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20299)));
  COMMIT; -- don't forget it!!!
END;

/
*/
CREATE TABLE Friends (
    user1_id INTEGER NOT NULL,
    user2_id INTEGER NOT NULL,
      PRIMARY KEY (user1_id, user2_id),
    FOREIGN KEY (user1_id) REFERENCES Users(user_id),
    FOREIGN KEY (user2_id) REFERENCES Users(user_id)
);
CREATE TRIGGER Order_Friend_Pairs
    BEFORE INSERT ON Friends
    FOR EACH ROW
        DECLARE temp INTEGER;
        BEGIN
            IF :NEW.user1_id > :NEW.user2_id THEN
                temp := :NEW.user2_id;
                :NEW.user2_id := :NEW.user1_id;
                :NEW.user1_id := temp;
            END IF;
        END;
/

CREATE TABLE Messages (
    message_id INTEGER PRIMARY KEY,
    sender_id INTEGER NOT NULL,
    receiver_id INTEGER NOT NULL,
    message_content VARCHAR2(2000) NOT NULL,
    sent_time TIMESTAMP NOT NULL,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);
CREATE TABLE Photos (
    photo_id INTEGER PRIMARY KEY,
    album_id INTEGER NOT NULL,
    photo_caption VARCHAR2(2000),
    photo_created_time TIMESTAMP NOT NULL,
    photo_modified_time TIMESTAMP,
    photo_link VARCHAR2(2000) NOT NULL
    );

    ALTER TABLE photos
ADD CONSTRAINT pho_unq
UNIQUE (album_id, photo_id);

CREATE TABLE Albums (
    album_id INTEGER PRIMARY KEY,
    album_owner_id INTEGER NOT NULL,
    album_name VARCHAR2(100) NOT NULL,
    album_created_time TIMESTAMP NOT NULL,
    album_modified_time TIMESTAMP,
    album_link VARCHAR2(2000) NOT NULL,
    album_visibility VARCHAR2(100) NOT NULL,
    cover_photo_id INTEGER NOT NULL,
    FOREIGN KEY (album_owner_id) REFERENCES Users(user_id)
);
ALTER TABLE Photos
ADD CONSTRAINT fk_album_id FOREIGN KEY (album_id) REFERENCES Albums(album_id) INITIALLY DEFERRED DEFERRABLE;
ALTER TABLE Albums
ADD CONSTRAINT fk_photo_inalbum FOREIGN KEY (cover_photo_id) REFERENCES Photos(photo_id) INITIALLY DEFERRED DEFERRABLE;
Alter Table Albums
Add CONSTRAINT album_Vis Check (album_visibility IN ('Everyone', 'Friends', 'Friends_Of_Friends', 'Myself'));
alter table albums Add CONSTRAINT One_Photo FOREIGN KEY (album_id, cover_photo_id) REFERENCES Photos(album_id, photo_id);



/*CREATE OR REPLACE TRIGGER Check_Album_Photos
BEFORE INSERT OR UPDATE ON Albums
FOR EACH ROW
DECLARE
    photo_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO photo_count
    FROM Photos
    WHERE album_id = :NEW.album_id;
    IF photo_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Each album must contain at least one photo');  
    END IF;
END;
/
*/
CREATE TABLE Tags (
    tag_photo_id INTEGER NOT NULL,
    tag_subject_id INTEGER NOT NULL,
    tag_created_time TIMESTAMP NOT NULL,
    tag_x NUMBER NOT NULL,
    tag_y NUMBER NOT NULL,
    PRIMARY KEY (tag_photo_id, tag_subject_id),
    FOREIGN KEY (tag_photo_id) REFERENCES Photos(photo_id),
    FOREIGN KEY (tag_subject_id) REFERENCES Users(user_id)
);

CREATE TABLE User_Events (
    event_id INTEGER PRIMARY KEY,
    event_creator_id INTEGER NOT NULL,
    event_name VARCHAR2(100) NOT NULL,
    event_tagline VARCHAR2(100),
    event_description VARCHAR2(100),
    event_host VARCHAR2(100),
    event_type VARCHAR2(100),
    event_subtype VARCHAR2(100),
    event_address VARCHAR2(2000),
    event_city_id INTEGER NOT NULL,
    event_start_time TIMESTAMP,
    event_end_time TIMESTAMP,
    FOREIGN KEY (event_creator_id) REFERENCES Users(user_id),
    FOREIGN KEY (event_city_id) REFERENCES Cities(city_id)
);
CREATE TABLE Participants (
    event_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    confirmation VARCHAR2(100) NOT NULL,
    PRIMARY KEY (event_id, user_id),
    FOREIGN KEY (event_id) REFERENCES User_Events(event_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT chk_confirmation CHECK (confirmation IN ('Attending', 'Unsure', 'Declines', 'Not_Replied'))
);



CREATE TRIGGER Cities_BI
    BEFORE INSERT ON cities
    FOR EACH ROW
        BEGIN
            SELECT Cities_seq.NEXTVAL INTO :NEW.city_id FROM DUAL;
        END;
/
CREATE TRIGGER Programs_BI
    BEFORE INSERT ON Programs
    FOR EACH ROW
        BEGIN
            SELECT program_seq.NEXTVAL INTO :NEW.program_id FROM DUAL;
        END;

/
