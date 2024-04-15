create database if not exists music;
use music;

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

# need to make subclass
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
    profile_image VARCHAR(600),      #image url    
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

-- PROCEDURES

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


-- Insert data into the genre table
INSERT INTO genre (genre_name) VALUES
('Rock'),
('Pop'),
('Hip Hop'),
('Country'),
('Electronic');

-- Insert data into the artist table
INSERT INTO artist (stage_name, follower_count) VALUES
('The Beatles', 25000000),
('Taylor Swift', 92300000),
('Kendrick Lamar', 18400000),
('Luke Combs', 3200000),
('Daft Punk', 10500000);

-- Insert data into the producer table
INSERT INTO producer (email_address, producer_name, company_name) VALUES
('producer1@email.com', 'John Doe', 'Acme Records'),
('producer2@email.com', 'Jane Smith', 'Beats Inc.'),
('producer3@email.com', 'Michael Johnson', 'Rhythm Studios');

-- Insert data into the user table
INSERT INTO user (username, email_address, password, profile_image, artist_id) VALUES
('user1', 'user1@email.com', 'password1', 'https://example.com/user1.jpg', 1),
('user2', 'user2@email.com', 'password2', 'https://example.com/user2.jpg', 2),
('user3', 'user3@email.com', 'password3', 'https://example.com/user3.jpg', 3);

-- Insert data into the album table
INSERT INTO album (album_name, album_image_link) VALUES
('Abbey Road', 'https://example.com/abbeyroad.jpg'),
('Folklore', 'https://example.com/folklore.jpg'),
('Good Kid, M.A.A.D City', 'https://example.com/gkmc.jpg');

-- Insert data into the song table
INSERT INTO song (song_name, length, date_added, cover_image_link, streaming_link, album_id, producer_email) VALUES
('Hey Jude', 432, '1968-08-26', 'https://example.com/heyjude.jpg', 'https://music.example.com/heyjude', 1, 'producer1@email.com'),
('Cardigan', 237, '2020-07-24', 'https://example.com/cardigan.jpg', 'https://music.example.com/cardigan', 2, 'producer2@email.com'),
('Swimming Pools (Drank)', 320, '2012-10-22', 'https://example.com/swimmingpools.jpg', 'https://music.example.com/swimmingpools', 3, 'producer3@email.com');

-- Insert data into the artist_creates_song table
INSERT INTO artist_creates_song (artist_id, sid) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Insert data into the playlist table
INSERT INTO playlist (playlist_name, cover_image_url, like_count, is_public, creator) VALUES
('My Playlist', 'https://example.com/myplaylist.jpg', 100, true, 'user1'),
('Top Hits', 'https://example.com/tophits.jpg', 500, false, 'user2'),
('Private Playlist', 'https://example.com/privateplaylist.jpg', 50, true, 'user3');

-- Insert data into the playlist_contains_song table
INSERT INTO playlist_contains_song (playlist_id, sid) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 3);

-- Insert data into the song_is_genre table
INSERT INTO song_is_genre (genre_name, sid) VALUES
('Rock', 1),
('Pop', 2),
('Hip Hop', 3);

-- Insert data into the user_follows_artist table
INSERT INTO user_follows_artist (username, artist_id) VALUES
('user1', 3),
('user2', 1),
('user3', 2);

-- Insert data into the artist_creates_album table
INSERT INTO artist_creates_album (artist_id, album_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Insert data into the user_likes_playlist table
INSERT INTO user_likes_playlist (username, playlist_id) VALUES
('user1', 1),
('user2', 2),
('user3', 3);

-- Insert data into the producer_produces_song table
INSERT INTO producer_produces_song (producer_email, song_id) VALUES
('producer1@email.com', 1),
('producer2@email.com', 2),
('producer3@email.com', 3);