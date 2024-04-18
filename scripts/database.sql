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
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS producer;


create table album (
    album_id int auto_increment primary key,
    album_name varchar(200) not null,
    album_image_link varchar(600),
    is_explicit boolean not null default false
);

create table genre (
    genre_name VARCHAR(24) PRIMARY KEY
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
    playlist_name VARCHAR(24) not null,
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
    genre_name varchar(24) not null,
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



drop procedure if exists add_song;
DELIMITER $$
CREATE PROCEDURE add_song(
	p_artist_id VARCHAR(255),
    p_song_name VARCHAR(200),
    p_length INT,
    p_date_added DATE,
    p_cover_image_link VARCHAR(600),
    p_streaming_link VARCHAR(600),
    p_album_id INT
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
			album_id)
		VALUES (
			p_song_name,
			p_length,
			p_date_added,
			p_cover_image_link,
			p_streaming_link,
			p_album_id
		);
        SELECT LAST_INSERT_ID() INTO song_id;
        INSERT INTO artist_creates_song(artist_id, sid) VALUES(p_artist_id, song_id);
	END IF;
END$$
DELIMITER ;

drop procedure if exists get_artist_from_user;
DELIMITER $$
	create procedure get_artist_from_user( IN username varchar(255))
    BEGIN
		SELECT artist.* from artist join user on user.artist_id = artist.artist_id where user.username = username;
    END$$
DELIMITER ;


-- add songs to playlist
DROP PROCEDURE IF EXISTS create_playlist_from_songs;
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
/*CHANGED*/
drop procedure if exists DeleteSong;
DELIMITER $$
CREATE PROCEDURE DeleteSong(
    IN p_sid INT
    )
BEGIN
    DELETE FROM song WHERE sid = p_sid;
END$$
DELIMITER ;

/*CHANGED*/
drop function if exists get_album_song_count;
DELIMITER $$
create function get_album_song_count(p_album_id int) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
	DECLARE song_count int;
    
	SELECT count(sid) as song_count from song where song.album_id = p_album_id into song_count;
    RETURN song_count;
END$$
DELIMITER ;
Select get_album_song_count(1);

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
    IF (SELECT COUNT(*) FROM users WHERE username = p_username OR email_address = p_email) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username or Email already exists';
    ELSE
		INSERT INTO artist (stage_name) values (p_stage_name);
        INSERT INTO users (username, email_address, password, artist_id, profile_image)
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
    IF (SELECT COUNT(*) FROM users WHERE username = p_username) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'users does not exist';
    ELSE
		select users.artist_id into u_a_id from users where users.username = p_username;
        DELETE FROM artist where artist.artist_id = u_a_id;
        DELETE FROM users WHERE username = p_username;
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

/* gets albums for this user */
drop procedure if exists get_user_albums;
DELIMITER $$
CREATE PROCEDURE get_user_albums(
    IN p_username VARCHAR(255)
)
BEGIN
    SELECT album.* FROM user join artist on user.artist_id = artist.artist_id 
		join artist_creates_album on artist_creates_album.artist_id = artist.artist_id
        join album on album.album_id = artist_creates_album.album_id;
END$$
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

/* gets albums for this user */
drop procedure if exists get_user_albums;
DELIMITER $$
CREATE PROCEDURE get_user_albums(
    IN p_username VARCHAR(255)
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

drop procedure if exists fetch_filtered_playlists;
DELIMITER $$
CREATE PROCEDURE fetch_filtered_playlists(
	IN p_query text,
    IN p_items int,
    IN p_offset int
)
BEGIN 
    SELECT
        user.*,
        playlist.*
        FROM playlist
        JOIN user on playlist.creator = user.username
        WHERE
          playlist.playlist_name LIKE p_query OR
          user.username LIKE p_query
      ORDER BY playlist.like_count DESC
      LIMIT p_items OFFSET p_offset;
BEGIN
    SELECT album.* FROM user join artist on user.artist_id = artist.artist_id 
		join artist_creates_album on artist_creates_album.artist_id = artist.artist_id
        join album on album.album_id = artist_creates_album.album_id;
END$$
DELIMITER ;

drop procedure if exists fetch_filtered_playlist_songs;
DELIMITER $$
CREATE PROCEDURE fetch_filtered_playlist_songs(
	IN p_playlist_id int,
    IN p_items int,
    IN p_offset int
)
BEGIN 
    SELECT
        song.*,
        artist.*
        FROM artist_creates_song
        JOIN song ON artist_creates_song.sid = song.sid
        JOIN artist on artist_creates_song.artist_id = artist.artist_id
        JOIN playlist_contains_song ON song.sid = playlist_contains_song.sid
        WHERE
        playlist_contains_song.playlist_id = p_playlist_id
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
('Cardigan', 237, '2020-07-24', 'https://example.com/cardigan.jpg', 'https://music.example.com/cardigan', 1, 'producer2@email.com'),
('Swimming Pools (Drank)', 320, '2012-10-22', 'https://example.com/swimmingpools.jpg', 'https://music.example.com/swimmingpools', 3, 'producer3@email.com');

/* Insert data into the artist_creates_song table */
INSERT INTO artist_creates_song (artist_id, sid) VALUES
(1, 1),
(2, 2),
(3, 3);

/* Insert data into the playlist table */
INSERT INTO playlist (playlist_name, cover_image_url, like_count, is_public, creator) VALUES
('My Playlist', 'https://example.com/myplaylist.jpg', 100, true, 'user1'),
('Top Hits', 'https://example.com/tophits.jpg', 500, false, 'user1'),
('Private Playlist', 'https://example.com/privateplaylist.jpg', 50, true, 'user1');

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