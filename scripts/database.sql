drop database if exists projdb;
create database projdb;
use projdb;
drop table if exists artist_creates_song;
drop table if exists producer_produces_song;
drop table if exists song_is_genre;
drop table if exists user_follows_artist;
drop table if exists artist_creates_album;
DROP TABLE IF EXISTS user_likes_playlist;
drop table if exists playlist_contains_song;
drop table if exists song;
drop table if exists album;
drop table if exists genre;
drop table if exists playlist;
drop table if exists friend_requests;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS user_follows_artist;
DROP TABLE IF EXISTS artist_creates_album;
DROP TABLE IF EXISTS producer;
DROP TABLE IF EXISTS artist;


/*
Tables in this schema:

    album(album_id: int, album_name: varchar(200), album_image_link: varchar(600), is_explicit: bool) -- stores records of albums
    genre(genre_name: varchar(24)) -- stores different music genres
    artist(artist_id: int, stage_name: varchar(255), follower_count: int) -- stores artist profiles
    users(username: varchar(255), email_address: varchar(255), password: varchar(255), artist_id: int, profile_image: varchar(600)) -- stores user accounts mapped to artist profiles
    playlist(playlist_id: int, playlist_name: varchar(24), cover_image_url: varchar(600), like_count: int, is_public: bool, creator: varchar(255)) -- stores user playlists
    producer(email_address: varchar(255), producer_name: varchar(255), company_name: varchar(255)) -- stores producer profiles
    song(sid: int, song_name: varchar(200), length: int, date_added: date, cover_image_link: varchar(600), streaming_link: varchar(600), album_id: int, producer_email: varchar(255)) -- stores song details
    artist_creates_song(artist_id: int, sid: int) -- maps artists to the songs they created
    playlist_contains_song(playlist_id: int, sid: int) -- maps songs to the playlists they are included in
    song_is_genre(genre_name: varchar(24), sid: int) -- maps songs to their genres
    user_follows_artist(username: varchar(255), artist_id: int) -- tracks which users follow which artists
    artist_creates_album(album_id: int, artist_id: int) -- maps albums to the artists who created them
    user_likes_playlist(username: varchar(255), playlist_id: int) -- tracks which users liked which playlists
    producer_produces_song(producer_email: varchar(255), song_id: int) -- maps producers to the songs they produced
    friend_requests(requester: varchar(255), requestee: varchar(255), status: enum('pending', 'accepted')) -- stores friend requests between users
*/
# select count(*) from artist;
-- Procedures:
/*
    get_songs() -- returns all songs in the database ordered by date_added descending
    add_song(p_artist_id, p_song_name, ...) -- adds a new song to the database and maps it to the specified artist
    DeleteSong(p_sid) -- deletes the specified song and its associated album if it was the last song in that album
    AddUser(p_username, p_email, p_password, p_profile_image, p_stage_name) -- adds a new user account and creates an associated artist profile
    DeleteUser(p_username) -- deletes the specified user account and their associated artist profile
    follow_artist(p_artist_id, p_username) -- marks that the specified user is following the specified artist
    unfollow_artist(p_artist_id, p_username) -- marks that the specified user is no longer following the specified artist
    FollowUnfollowArtist(p_username, p_stage_name, p_action) -- follows or unfollows an artist based on the specified action ('follow' or 'unfollow')
    AddAlbum(p_album_name, p_album_image_link, p_is_explicit, p_stage_name, song_ids) -- adds a new album and optionally links it to an artist and existing songs
    SendFriendRequest(p_requester, p_requestee) -- sends a friend request from one user to another
    AcceptFriendRequest(p_requester, p_requestee) -- accepts a pending friend request between two users
    DeclineFriendRequest(p_requester, p_requestee) -- declines a pending friend request between two users
    AddingSongToPlaylist(p_sid, p_playlist_id) -- adds a song to the specified playlist if it doesn't already exist in that playlist
*/

create table album (
    album_id int auto_increment primary key,
    album_name varchar(200) not null,
    album_image_link varchar(600),
    is_explicit boolean not null default false
);

create table genre (
    genre_name VARCHAR(96) PRIMARY KEY
);

/* need to make subclass */
CREATE TABLE artist (
    artist_id INT PRIMARY KEY auto_increment,
	stage_name VARCHAR(255) NOT NULL,
	follower_count INT NOT null DEFAULT 0
);

CREATE TABLE user (
    username VARCHAR(255) PRIMARY KEY,
    email_address VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL UNIQUE,
    artist_id INT NOT NULL,
    profile_image VARCHAR(600),      /* image url */ 
    foreign key (artist_id) references artist(artist_id) on update cascade on delete cascade
);

create table playlist(
    playlist_id INT PRIMARY KEY AUTO_INCREMENT,
    playlist_name VARCHAR(96) not null,
    cover_image_url VARCHAR(600),
    like_count INT not null DEFAULT 0,
    is_public boolean default true,
    creator VARCHAR(255),
    foreign key (creator) references user(username) on update cascade on delete set null
);

CREATE TABLE producer(
	email_address VARCHAR(255) PRIMARY KEY,
	producer_name VARCHAR(255) NOT NULL,
	company_name VARCHAR(255)
);

create table song (
    sid int auto_increment primary key,
    song_name varchar(200) not null,
    length int,
    date_added date not null,
    cover_image_link varchar(600),
    streaming_link varchar(600),
    album_id int,
    producer_email varchar(255),
    foreign key (album_id) 
		references album(album_id)
           on update cascade on delete set null,
    foreign key (producer_email) 
		references producer(email_address)
        on update cascade on delete set null
);

create table artist_creates_song (
    primary key(sid, artist_id),
    artist_id int not null,
    sid int not null,
    foreign key (sid) 
		references song(sid)
           on update cascade on delete cascade,
    foreign key (artist_id) 
		references artist(artist_id)
           on update cascade on delete cascade
);

create table playlist_contains_song (
    primary key(playlist_id, sid),
    playlist_id int not null,
    sid int not null,
    foreign key (sid) 
		references song(sid)
           on update cascade on delete cascade,
    foreign key (playlist_id) 
		references playlist(playlist_id)
           on update cascade on delete cascade
);
create table song_is_genre (
	primary key(genre_name, sid),
    genre_name varchar(48) not null,
    sid int not null,
    foreign key (sid) 
		references song(sid)
        on update cascade on delete cascade,
    foreign key (genre_name) 
		references genre(genre_name)
        on update cascade on delete cascade
);

create table user_follows_artist (
	primary key(username, artist_id),
    artist_id int not null,
    username varchar(255) not null,
    foreign key (username) 
		references user(username)
        on update cascade on delete cascade,
    foreign key (artist_id) 
		references artist(artist_id)
        on update cascade on delete cascade
);

create table artist_creates_album (
	primary key(album_id, artist_id),
    artist_id int not null,
    album_id int not null,
    foreign key (album_id) 
		references album(album_id)
        on update cascade on delete cascade,
    foreign key (artist_id) 
		references artist(artist_id)
        on update cascade on delete cascade
);

CREATE TABLE user_likes_playlist (
	username VARCHAR(255),
	playlist_id INT,
	PRIMARY KEY(username, playlist_id),
	CONSTRAINT user_Like FOREIGN KEY (username) REFERENCES user(username)
ON DELETE CASCADE, 
CONSTRAINT playlist_like FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id) ON DELETE CASCADE
);

CREATE TABLE producer_produces_song (
	PRIMARY KEY (producer_email, song_id),
	producer_email VARCHAR(255) not null,
	song_id INT not null, 
	FOREIGN KEY (producer_email) REFERENCES producer(email_address) 
	ON DELETE CASCADE,
	FOREIGN KEY (song_id) REFERENCES song(sid) 
	ON DELETE CASCADE
);

-- create a table for frined relationships
CREATE TABLE friend_requests (
    requester VARCHAR(255),
    requestee VARCHAR(255),
    status ENUM('pending', 'accepted'),
    PRIMARY KEY (requester, requestee),
    FOREIGN KEY (requester) REFERENCES user(username) ON DELETE CASCADE,
    FOREIGN KEY (requestee) REFERENCES user(username) ON DELETE CASCADE
);

/* PROCEDURES */



--
DROP PROCEDURE IF EXISTS get_songs;
DELIMITER //
CREATE PROCEDURE get_songs()
BEGIN
    SELECT * from song ORDER BY date_added DESC;
END //
DELIMITER ;
drop procedure if exists mark_songs_genre;
delimiter //
create procedure mark_songs_genre(
	p_song_ids TEXT,
    p_genre varchar(96)
)
BEGIN
	IF (select COUNT(genre_name) from genre where genre.genre_name = p_genre) = 0
    THEN
		insert into genre values (genre_name);
	END IF;
    insert into song_is_genre (genre_name, sid) select p_genre, sid from song where find_in_set(sid, p_song_ids) and not exists (select * from song_is_genre where song_is_genre.genre_name = p_genre and song_is_genre.sid = song.sid);
END //
DELIMITER ;

drop procedure if exists mark_songs_genre_by_artist;
delimiter //
create procedure mark_songs_genre_by_artist(
	p_artist_id INT,
    p_genre varchar(96)
)
BEGIN
	IF (select COUNT(genre_name) from genre where genre.genre_name = p_genre) = 0
    THEN
		insert into genre values (p_genre);
	END IF;
    insert into song_is_genre (genre_name, sid) select p_genre, sid from song 
    where exists (select * from artist_creates_song where artist_creates_song.artist_id = p_artist_id and artist_creates_song.sid = song.sid) 
    and not exists (select * from song_is_genre where genre_name = p_genre and song_is_genre.sid = song.sid);
END //
DELIMITER ;

drop procedure if exists add_song;
DELIMITER $$
CREATE PROCEDURE add_song(
	p_artist_id VARCHAR(255),
    p_song_name VARCHAR(200),
    p_length INT,
    p_date_added DATE,
    p_cover_image_link VARCHAR(600),
    p_streaming_link VARCHAR(600),
    p_is_explicit BOOLEAN,
    p_album_id INT,
    p_producer_email VARCHAR(255)
)
BEGIN
	DECLARE song_id int;
    
	IF p_artist_id not in (select artist_id from artist) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid artist'; 
    ELSE 
		INSERT INTO song (
			song_name,
			length,
			date_added,
			cover_image_link,
			streaming_link,
			is_explicit,
			album_id,
			Producer_email)
		VALUES (
			p_song_name,
			p_length,
			p_date_added,
			p_cover_image_link,
			p_streaming_link,
			p_is_explicit,
			p_album_id,
			p_producer_email
		);
        SELECT LAST_INSERT_ID() INTO song_id;
        INSERT INTO artist_creates_song(artist_id, sid) VALUES(p_artist_id, song_id);
	END IF;
END$$
DELIMITER ;

-- a procedure to add a single song and mention however many artists worked on it.
drop procedure if exists add_song_n_artists;
DELIMITER $$
CREATE PROCEDURE add_song_n_artists(
	p_artist_ids TEXT,
    p_song_id INT,
    p_song_name VARCHAR(200),
    p_length INT,
    p_date_added DATE,
    p_cover_image_link VARCHAR(600),
    p_streaming_link VARCHAR(600)
)
BEGIN
	INSERT INTO song (
		sid,
		song_name,
		length,
		date_added,
		cover_image_link,
		streaming_link)
	VALUES (
		p_song_id,
		p_song_name,
		p_length,
		p_date_added,
		p_cover_image_link,
		p_streaming_link
	);
	INSERT INTO artist_creates_song (artist_id, sid) select artist_id, p_song_id from artist where FIND_IN_SET(artist_id, p_artist_ids);
END$$
DELIMITER ;


-- add songs to playlist
DELIMITER //

CREATE PROCEDURE create_playlist_from_songs(
	IN p_id INT,
    IN p_playlist_name VARCHAR(96),
    IN p_cover_image_url VARCHAR(600),
    IN p_like_count INT,
    IN p_is_public BOOLEAN,
    IN p_creator VARCHAR(255),
    IN p_song_ids TEXT
)
BEGIN
    INSERT INTO playlist (playlist_id, playlist_name, cover_image_url, like_count, is_public, creator)
    VALUES (p_id, p_playlist_name, p_cover_image_url, p_like_count, p_is_public, p_creator);
    -- create table playlist_contains_song (primary key(playlist_id, sid),
    INSERT INTO playlist_contains_song (playlist_id, sid) select p_id, sid from song where FIND_IN_SET(sid, p_song_ids);
END //

DELIMITER ;
drop procedure if exists DeleteSong;
DELIMITER $$
CREATE PROCEDURE DeleteSong(
    IN p_sid INT
    )
BEGIN
	DECLARE album_id_var INT;
    DECLARE num_album_songs INT;
    SELECT album_id INTO album_id_var 
    WHERE sid = p_sid;
    DELETE FROM song WHERE sid = p_sid; # delete album if there are no more songs in it
    IF album_id_var IS NOT NULL THEN 
    SELECT COUNT(sid) INTO num_album_songs FROM song
    WHERE album_id = album_id_var;
		IF num_album_songs = 0 THEN 
        DELETE FROM album 
        WHERE album_id = album_id_var;
        END IF;
    END IF;
    
END$$
DELIMITER ;

/* adds in a user (creates a corresponding artist profile as well ) */
drop procedure if exists AddUser;
DELIMITER $$
CREATE PROCEDURE AddUser(
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_profile_image VARCHAR(600),
    IN p_stage_name VARCHAR(255)
)
BEGIN
    /* Check if username or email already exists */
    IF (SELECT COUNT(*) FROM user WHERE username = p_username OR email_address = p_email) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username or Email already exists';
    ELSE
		INSERT INTO artist (stage_name) values (p_stage_name);
        INSERT INTO user (username, email_address, password, artist_id, profile_image)
        VALUES (p_username, p_email, p_password, last_insert_id(), p_profile_image);
    END IF;
END$$
DELIMITER ;

/* deletes a users (and corresponding artist) */
drop procedure if exists DeleteUser;
DELIMITER $$
CREATE PROCEDURE DeleteUser(
    IN p_username VARCHAR(255)
)
BEGIN
	declare u_a_id INT;
    /* Check if users exists */
    IF (SELECT COUNT(*) FROM user WHERE username = p_username) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'users does not exist';
    ELSE
		select user.artist_id into u_a_id from user where user.username = p_username;
        DELETE FROM artist where artist.artist_id = u_a_id;
        DELETE FROM user WHERE username = p_username;
    END IF;
END$$
DELIMITER ;

/* marks that a users is following an artist */
DROP PROCEDURE IF EXISTS follow_artist;
DELIMITER //
CREATE PROCEDURE follow_artist(
	p_artist_id INT,
    p_username VARCHAR(255) 
)
BEGIN
	IF 0 = (SELECT COUNT(*) from user_follows_artist where user_follows_artist.artist_id = p_artist_id and user_follows_artist.username = p_username)
    then
		insert into user_follows_artist values (p_artist_id, p_username);
        update artist set artist.follower_count = artist.follower_count + 1;
    end if;
END //
DELIMITER ;

/* marks that a user is no longer following an artist */
DROP PROCEDURE IF EXISTS unfollow_artist;
DELIMITER //
CREATE PROCEDURE unfollow_artist(
	p_artist_id INT,
    p_username VARCHAR(255) 
)
BEGIN
	IF 0 <> (SELECT COUNT(*) from user_follows_artist where user_follows_artist.artist_id = p_artist_id and user_follows_artist.username = p_username)
    then
		delete from user_follows_artist where user_follows_artist.artist_id = p_artist_id and user_follows_artist.username = p_username;
        update artist set artist.follower_count = artist.follower_count - 1;
    end if;
END //
DELIMITER ;

-- procedure for album 
drop procedure if exists AddAlbum;
DELIMITER $$
CREATE PROCEDURE AddAlbum(
    IN p_album_name VARCHAR(200),
    IN p_album_image_link VARCHAR(600),
    IN p_is_explicit boolean,
    IN p_stage_name VARCHAR(255),
    IN song_ids TEXT
)
BEGIN
    DECLARE album_exists INT;
	-- Insert the new album
	INSERT INTO album (album_name, album_image_link)
	VALUES (p_album_name, p_album_image_link);

	-- If an artist's name is provided, link the album to the artist
	IF p_stage_name IS NOT NULL AND p_stage_name <> '' THEN
		INSERT INTO artist_creates_album (album_id, stage_name)
		VALUES (LAST_INSERT_ID(), p_stage_name);
		
	END IF;
	IF song_ids IS NOT NULL AND song_ids <> '' THEN
		UPDATE song SET album_id = LAST_INSERT_ID()
		WHERE FIND_IN_SET(sid, song_ids) > 0 ;
	ELSE 
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'song ids cannot be empty';
	END IF; 
END
$$
DELIMITER ;

-- procedure to add album and pass certain information 

drop procedure if exists AddAlbumAndDets;
DELIMITER $$
CREATE PROCEDURE AddAlbumAndDets(
	IN p_album_id INT,
    IN p_album_name VARCHAR(200),
    IN p_album_image_link VARCHAR(600),
    IN p_is_explicit boolean,
    IN p_artist_ids TEXT,
    IN p_song_ids TEXT
)
BEGIN
	-- Insert the new album
	INSERT INTO album (album_id, album_name, album_image_link, is_explicit)
	VALUES (p_album_id, p_album_name, p_album_image_link, p_is_explicit);	
	INSERT INTO artist_creates_album (artist_id, album_id) select artist_id, p_album_id from artist where FIND_IN_SET(artist_id, p_artist_ids);
	UPDATE song SET album_id = p_album_id WHERE FIND_IN_SET(sid, p_song_ids) > 0;
END $$
DELIMITER ;
-- Procedure for Sending a Friend Request
drop procedure if exists SendFriendRequest;
DELIMITER $$

CREATE PROCEDURE SendFriendRequest(
    IN p_requester VARCHAR(255),
    IN p_requestee VARCHAR(255)
)
BEGIN
    DECLARE existing_count INT;

    -- Check if there's already a request or a friendship
    SELECT COUNT(*) INTO existing_count FROM friend_requests 
    WHERE (requester = p_requester AND requestee = p_requestee)
       OR (requester = p_requestee AND requestee = p_requester);


    IF existing_count = 0 THEN
        -- Insert new friend request
        INSERT INTO friend_requests (requester, requestee, status)
        VALUES (p_requester, p_requestee, 'pending');
    ELSE
        -- Signal error: a request is already pending or a friendship exists
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A request already exists or user are already friends';
    END IF;
END$$

DELIMITER ;

-- Procedure for Accepting a Friend Request
drop procedure if exists AcceptFriendRequest;

DELIMITER $$

CREATE PROCEDURE AcceptFriendRequest(
    IN p_requester VARCHAR(255),
    IN p_requestee VARCHAR(255)
)
BEGIN
    -- Check if there is a pending request from requester to requestee
    IF EXISTS (SELECT 1 FROM friend_requests 
               WHERE requester = p_requester AND requestee = p_requestee AND status = 'pending') THEN
        -- Update the friend request to accepted
        UPDATE friend_requests SET status = 'accepted'
        WHERE requester = p_requester AND requestee = p_requestee;
    ELSE
        -- Signal error: no valid pending friend request
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No pending friend request to accept';
    END IF;
END$$

DELIMITER ;
drop procedure if exists DeclineFriendRequest;

DELIMITER $$
CREATE PROCEDURE DeclineFriendRequest(
	IN p_requester VARCHAR(255),
	IN p_requestee VARCHAR(255)
)
BEGIN 
	DELETE FROM friend_requests 
    WHERE requester = p_requester 
    AND requestee = p_requestee ;
END $$
    
DELIMITER ;
    
drop procedure if exists AddingSongToPlaylist;
DELIMITER $$
CREATE PROCEDURE AddingSongToPlaylist( 
    IN p_sid INT,
    IN p_playlist_id INT
)
BEGIN 
    -- Check if the song already exists in the playlist
    IF NOT EXISTS (
        SELECT * FROM playlist_contains_song
        WHERE sid = p_sid AND playlist_id = p_playlist_id
    ) THEN
        -- Check if the playlist exists
        IF EXISTS (
            SELECT * FROM playlist
            WHERE playlist_id = p_playlist_id
        ) THEN
            -- Insert the song into the playlist
            INSERT INTO playlist_contains_song (playlist_id, sid)
            VALUES (p_playlist_id, p_sid);
        ELSE
            -- Signal an error if the playlist does not exist
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Playlist does not exist';
        END IF;
    ELSE
        -- Signal an error if the song is already in the playlist
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Song already in playlist';
    END IF;
END$$

DELIMITER ;


/* This one works via enum
 Procedure for following/unfollowing artist */
drop procedure if exists FollowUnfollowArtist;
DELIMITER $$
CREATE PROCEDURE FollowUnfollowArtist(
    IN p_username VARCHAR(255),
    IN p_stage_name VARCHAR(255),
    IN p_action ENUM('follow', 'unfollow')
)
BEGIN
    /* Handling the follow action */
    IF p_action = 'follow' THEN
        /* Check if the users already follows the artist */
        IF NOT EXISTS (
            SELECT * FROM user_follows_artist 
            WHERE username = p_username AND stage_name = p_stage_name
        ) THEN
            /* Insert follow record */
            INSERT INTO user_follows_artist (username, stage_name)
            VALUES (p_username, p_stage_name);
		ELSE 
         /* Signal error: already following */
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Already following artist';
        END IF;
	ELSE 
		IF EXISTS (
            SELECT * FROM user_follows_artist 
            WHERE username = p_username AND stage_name = p_stage_name
        ) THEN
			DELETE FROM user_follows_artist
			WHERE username = p_username AND stage_name = p_stage_name;
		ELSE 
			/* Signal error: Not following and cannot unfollow */
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You are not following this artist';
		END IF; 
	END IF; 
END$$
DELIMITER ;

/* procedure for album */
drop procedure if exists AddAlbum;
DELIMITER $$
CREATE PROCEDURE AddAlbum(
    IN p_album_name VARCHAR(200),
    IN p_album_image_link VARCHAR(600),
    IN p_is_explicit boolean,
    IN p_stage_name VARCHAR(255),
    IN song_ids TEXT
)
BEGIN
    DECLARE album_exists INT;
	/* Insert the new album */
	INSERT INTO album (album_name, album_image_link)
	VALUES (p_album_name, p_album_image_link);

	/* If an artist's name is provided, link the album to the artist */
	IF p_stage_name IS NOT NULL AND p_stage_name <> '' THEN
		INSERT INTO artist_creates_album (album_id, stage_name)
		VALUES (LAST_INSERT_ID(), p_stage_name);
		
	END IF;
	IF song_ids IS NOT NULL AND song_ids <> '' THEN
		UPDATE song SET album_id = LAST_INSERT_ID()
		WHERE FIND_IN_SET(sid, song_ids) > 0 ;
	ELSE 
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'song ids cannot be empty';
	END IF; 
END
$$
DELIMITER ;

/* Procedure for Sending a Friend Request */
drop procedure if exists SendFriendRequest;
DELIMITER $$

CREATE PROCEDURE SendFriendRequest(
    IN p_requester VARCHAR(255),
    IN p_requestee VARCHAR(255)
)
BEGIN
    DECLARE existing_count INT;

    /* Check if there's already a request or a friendship */
    SELECT COUNT(*) INTO existing_count FROM friend_requests 
    WHERE (requester = p_requester AND requestee = p_requestee)
       OR (requester = p_requestee AND requestee = p_requester);


    IF existing_count = 0 THEN
        /* Insert new friend request */
        INSERT INTO friend_requests (requester, requestee, status)
        VALUES (p_requester, p_requestee, 'pending');
    ELSE
        /* Signal error: a request is already pending or a friendship exists */
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A request already exists or users are already friends';
    END IF;
END$$

DELIMITER ;

/* Procedure for Accepting a Friend Request */
drop procedure if exists AcceptFriendRequest;

DELIMITER $$

CREATE PROCEDURE AcceptFriendRequest(
    IN p_requester VARCHAR(255),
    IN p_requestee VARCHAR(255)
)
BEGIN
    /* Check if there is a pending request from requester to requestee */
    IF EXISTS (SELECT 1 FROM friend_requests 
               WHERE requester = p_requester AND requestee = p_requestee AND status = 'pending') THEN
        /* Update the friend request to accepted */
        UPDATE friend_requests SET status = 'accepted'
        WHERE requester = p_requester AND requestee = p_requestee;
    ELSE
        /* Signal error: no valid pending friend request */
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No pending friend request to accept';
    END IF;
END$$

DELIMITER ;

drop procedure if exists DeclineFriendRequest;

DELIMITER $$
CREATE PROCEDURE DeclineFriendRequest(
	IN p_requester VARCHAR(255),
	IN p_requestee VARCHAR(255)
)
BEGIN 
	DELETE FROM friend_requests 
    WHERE requester = p_requester 
    AND requestee = p_requestee ;
END $$
    
DELIMITER ;
    
drop procedure if exists AddingSongToPlaylist;
DELIMITER $$
CREATE PROCEDURE AddingSongToPlaylist( 
    IN p_sid INT,
    IN p_playlist_id INT
)
BEGIN 
    /* Check if the song already exists in the playlist */
    IF NOT EXISTS (
        SELECT * FROM playlist_contains_song
        WHERE sid = p_sid AND playlist_id = p_playlist_id
    ) THEN
        /* Check if the playlist exists */
        IF EXISTS (
            SELECT * FROM playlist
            WHERE playlist_id = p_playlist_id
        ) THEN
            /* Insert the song into the playlist */
            INSERT INTO playlist_contains_song (playlist_id, sid)
            VALUES (p_playlist_id, p_sid);
        ELSE
            /* Signal an error if the playlist does not exist */
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Playlist does not exist';
        END IF;
    ELSE
        /* Signal an error if the song is already in the playlist */
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Song already in playlist';
    END IF;
END$$

DELIMITER ;

drop procedure if exists fetch_filtered_songs;
DELIMITER $$
CREATE PROCEDURE fetch_filtered_songs(
	IN p_query TEXT,
    IN p_items int,
    IN p_offset int
)
BEGIN 
    SELECT
        song.*,
        artist.*,
        album.*
        FROM artist_creates_song
        JOIN song ON artist_creates_song.sid = song.sid
        JOIN artist on artist_creates_song.artist_id = artist.artist_id
        JOIN album on album.album_id = song.album_id
        WHERE
          artist.stage_name LIKE p_query OR
          song.song_name LIKE p_query
      ORDER BY song.date_added DESC
      LIMIT p_items OFFSET p_offset;
END$$
DELIMITER ;

drop procedure if exists is_user_following;
DELIMITER $$
CREATE PROCEDURE is_user_following(
	IN p_username TEXT,
    IN p_artist_id int
)
BEGIN 
	IF (SELECT COUNT(*) FROM user_follows_artist where username = p_username and artist_id = p_artist_id)
    THEN SELECT true;
    ELSE SELECT false;
    END IF;
END$$
DELIMITER ;

-- functions

SELECT
song.*,
artist.*,
album.*
FROM artist_creates_song
JOIN song ON artist_creates_song.sid = song.sid
JOIN artist on artist_creates_song.artist_id = artist.artist_id
JOIN album on album.album_id = song.album_id
WHERE
  artist.stage_name LIKE '%h%' OR
  song.song_name LIKE '%h%'
ORDER BY song.date_added DESC
LIMIT 6 OFFSET 0;

call fetch_filtered_songs('%h%', 6, 0);

/* Insert data into the genre table */
INSERT INTO genre (genre_name) VALUES
('Rock'),
('Pop'),
('Hip Hop'),
('Country'),
('Electronic');

/* Insert data into the artist table */
INSERT INTO artist (stage_name, follower_count) VALUES
('The Beatles', 25000000),
('Taylor Swift', 92300000),
('Kendrick Lamar', 18400000),
('Luke Combs', 3200000),
('Daft Punk', 10500000);

/* Insert data into the producer table */
INSERT INTO producer (email_address, producer_name, company_name) VALUES
('producer1@email.com', 'John Doe', 'Acme Records'),
('producer2@email.com', 'Jane Smith', 'Beats Inc.'),
('producer3@email.com', 'Michael Johnson', 'Rhythm Studios');

/* Insert data into the users table */
INSERT INTO user (username, email_address, password, profile_image, artist_id) VALUES
('user1', 'user1@email.com', 'password1', 'https://example.com/user1.jpg', 1),
('user2', 'user2@email.com', 'password2', 'https://example.com/user2.jpg', 2),
('user3', 'user3@email.com', 'password3', 'https://example.com/user3.jpg', 3),
('user4', 'user@nextmail.com', '$2b$10$JEywJDlKlgy5ggzVLi6ZLetbrNzGZJp0.DKww4Qx1R0XqvmklAlm6', 'https://example.com/user3.jpg', 3);

/* Insert data into the album table */
INSERT INTO album (album_name, album_image_link) VALUES
('Abbey Road', 'https://example.com/abbeyroad.jpg'),
('Folklore', 'https://example.com/folklore.jpg'),
('Good Kid, M.A.A.D City', 'https://example.com/gkmc.jpg');

/* Insert data into the song table */
INSERT INTO song (song_name, length, date_added, cover_image_link, streaming_link, album_id, producer_email) VALUES
('Hey Jude', 432, '1968-08-26', 'https://example.com/heyjude.jpg', 'https://music.example.com/heyjude', 1, 'producer1@email.com'),
('Cardigan', 237, '2020-07-24', 'https://example.com/cardigan.jpg', 'https://music.example.com/cardigan', 2, 'producer2@email.com'),
('Swimming Pools (Drank)', 320, '2012-10-22', 'https://example.com/swimmingpools.jpg', 'https://music.example.com/swimmingpools', 3, 'producer3@email.com');

/* Insert data into the artist_creates_song table */
INSERT INTO artist_creates_song (artist_id, sid) VALUES
(1, 1),
(2, 2),
(3, 3);

/* Insert data into the playlist table */
INSERT INTO playlist (playlist_name, cover_image_url, like_count, is_public, creator) VALUES
('My Playlist', 'https://example.com/myplaylist.jpg', 100, true, 'user1'),
('Top Hits', 'https://example.com/tophits.jpg', 500, false, 'user2'),
('Private Playlist', 'https://example.com/privateplaylist.jpg', 50, true, 'user3');

/* Insert data into the playlist_contains_song table */
INSERT INTO playlist_contains_song (playlist_id, sid) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 3);

/* Insert data into the song_is_genre table */
INSERT INTO song_is_genre (genre_name, sid) VALUES
('Rock', 1),
('Pop', 2),
('Hip Hop', 3);

/* Insert data into the user_follows_artist table */
INSERT INTO user_follows_artist (username, artist_id) VALUES
('user1', 3),
('user2', 1),
('user3', 2);

/* Insert data into the artist_creates_album table */
INSERT INTO artist_creates_album (artist_id, album_id) VALUES
(1, 1),
(2, 2),
(3, 3);

/* Insert data into the user_likes_playlist table */
INSERT INTO user_likes_playlist (username, playlist_id) VALUES
('user1', 1),
('user2', 2),
('user3', 3);

/* Insert data into the producer_produces_song table */
INSERT INTO producer_produces_song (producer_email, song_id) VALUES
('producer1@email.com', 1),
('producer2@email.com', 2),
('producer3@email.com', 3);

select count(*) from song;
select count(*) from artist;
select count(*) from album;
select count(*) from playlist;