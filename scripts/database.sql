drop table if exists artist_creates_song;
drop table if exists producer_produces_song;
drop table if exists song_is_genre;
drop table if exists users_follows_artist;
drop table if exists artist_creates_album;
DROP TABLE IF EXISTS users_likes_playlist;
drop table if exists playlist_contains_song;
drop table if exists song;
drop table if exists album;
drop table if exists genre;
drop table if exists playlist;
drop table if exists friend_requests;
DROP TABLE IF EXISTS users;
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

CREATE TABLE users (
    usersname VARCHAR(255) PRIMARY KEY,
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
    foreign key (creator) references users(usersname) on update cascade on delete set null
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

create table users_follows_artist (
	primary key(usersname, artist_id),
    artist_id int not null,
    usersname varchar(255) not null,
    foreign key (usersname) 
		references users(usersname)
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

CREATE TABLE users_likes_playlist (
	usersname VARCHAR(255),
	playlist_id INT,
	PRIMARY KEY(usersname, playlist_id),
	CONSTRAINT users_Like FOREIGN KEY (usersname) REFERENCES users(usersname)
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
    FOREIGN KEY (requester) REFERENCES users(username) ON DELETE CASCADE,
    FOREIGN KEY (requestee) REFERENCES users(username) ON DELETE CASCADE
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
    IN p_usersname VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_profile_image VARCHAR(600),
    IN p_stage_name VARCHAR(255)
)
BEGIN
    /* Check if usersname or email already exists */
    IF (SELECT COUNT(*) FROM userss WHERE usersname = p_usersname OR email_address = p_email) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username or Email already exists';
    ELSE
		INSERT INTO artist (stage_name) values (p_stage_name);
        INSERT INTO userss (usersname, email_address, password, artist_id, profile_image)
        VALUES (p_usersname, p_email, p_password, last_insert_id(), p_profile_image);
    END IF;
END$$
DELIMITER ;

/* deletes a userss (and corresponding artist) */
drop procedure if exists DeleteUser;
DELIMITER $$
CREATE PROCEDURE DeleteUser(
    IN p_usersname VARCHAR(255)
)
BEGIN
	declare u_a_id INT;
    /* Check if userss exists */
    IF (SELECT COUNT(*) FROM userss WHERE usersname = p_usersname) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'userss does not exist';
    ELSE
		select userss.artist_id into u_a_id from userss where userss.usersname = p_usersname;
        DELETE FROM artist where artist.artist_id = u_a_id;
        DELETE FROM userss WHERE usersname = p_usersname;
    END IF;
END$$
DELIMITER ;

/* marks that a userss is following an artist */
DROP PROCEDURE IF EXISTS follow_artist;
DELIMITER //
CREATE PROCEDURE follow_artist(
	p_artist_id INT,
    p_usersname VARCHAR(255) 
)
BEGIN
	IF 0 = (SELECT COUNT(*) from users_follows_artist where users_follows_artist.artist_id = p_artist_id and users_follows_artist.usersname = p_usersname)
    then
		insert into users_follows_artist values (p_artist_id, p_usersname);
        update artist set artist.follower_count = artist.follower_count + 1;
    end if;
END //
DELIMITER ;

/* marks that a user is no longer following an artist */
DROP PROCEDURE IF EXISTS unfollow_artist;
DELIMITER //
CREATE PROCEDURE unfollow_artist(
	p_artist_id INT,
    p_usersname VARCHAR(255) 
)
BEGIN
	IF 0 <> (SELECT COUNT(*) from users_follows_artist where users_follows_artist.artist_id = p_artist_id and users_follows_artist.usersname = p_usersname)
    then
		delete from users_follows_artist where users_follows_artist.artist_id = p_artist_id and users_follows_artist.usersname = p_usersname;
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A request already exists or users are already friends';
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
    IN p_usersname VARCHAR(255),
    IN p_stage_name VARCHAR(255),
    IN p_action ENUM('follow', 'unfollow')
)
BEGIN
    /* Handling the follow action */
    IF p_action = 'follow' THEN
        /* Check if the userss already follows the artist */
        IF NOT EXISTS (
            SELECT * FROM users_follows_artist 
            WHERE usersname = p_usersname AND stage_name = p_stage_name
        ) THEN
            /* Insert follow record */
            INSERT INTO users_follows_artist (usersname, stage_name)
            VALUES (p_usersname, p_stage_name);
		ELSE 
         /* Signal error: already following */
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Already following artist';
        END IF;
	ELSE 
		IF EXISTS (
            SELECT * FROM users_follows_artist 
            WHERE usersname = p_usersname AND stage_name = p_stage_name
        ) THEN
			DELETE FROM users_follows_artist
			WHERE usersname = p_usersname AND stage_name = p_stage_name;
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A request already exists or userss are already friends';
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

/* Insert data into the userss table */
INSERT INTO users (usersname, email_address, password, profile_image, artist_id) VALUES
('users1', 'users1@email.com', 'password1', 'https://example.com/users1.jpg', 1),
('users2', 'users2@email.com', 'password2', 'https://example.com/users2.jpg', 2),
('users3', 'users3@email.com', 'password3', 'https://example.com/users3.jpg', 3)
('user3', 'users@nextmail.com', '$2b$10$JEywJDlKlgy5ggzVLi6ZLetbrNzGZJp0.DKww4Qx1R0XqvmklAlm6', 'https://example.com/user3.jpg', 3);

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
('My Playlist', 'https://example.com/myplaylist.jpg', 100, true, 'users1'),
('Top Hits', 'https://example.com/tophits.jpg', 500, false, 'users2'),
('Private Playlist', 'https://example.com/privateplaylist.jpg', 50, true, 'users3');

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

/* Insert data into the users_follows_artist table */
INSERT INTO users_follows_artist (usersname, artist_id) VALUES
('users1', 3),
('users2', 1),
('users3', 2);

/* Insert data into the artist_creates_album table */
INSERT INTO artist_creates_album (artist_id, album_id) VALUES
(1, 1),
(2, 2),
(3, 3);

/* Insert data into the users_likes_playlist table */
INSERT INTO users_likes_playlist (usersname, playlist_id) VALUES
('users1', 1),
('users2', 2),
('users3', 3);

/* Insert data into the producer_produces_song table */
INSERT INTO producer_produces_song (producer_email, song_id) VALUES
('producer1@email.com', 1),
('producer2@email.com', 2),
('producer3@email.com', 3);