import pprint
from time import sleep
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pymysql


# lets connect to server first
username = input("Enter username: ")
pword = input("Enter password: ")
name = input("Enter database name: ")
try:
    connection = pymysql.connect(
        host="localhost",
        user=username,
        password=pword,
        database=name,
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )

except pymysql.Error as e:
    code, msg = e.args
    print("Cannot connect to the database", code, msg)
    exit()


c1 = connection.cursor()
query = "SELECT COUNT(*) from song;"
c1.execute(query)
response = c1.fetchall()
pprint.pprint(response)

SPOTIPY_CLIENT_ID = "436431542850435aa168bb965cb2fbd6"
SPOTIPY_CLIENT_SECRET = "e53c786fe05c4088bacb426db2ed5d51"

auth_manager = SpotifyClientCredentials(
    client_id=SPOTIPY_CLIENT_ID, client_secret=SPOTIPY_CLIENT_SECRET
)
sp = spotipy.Spotify(auth_manager=auth_manager)
sleep(1)
playlists = sp.user_playlists("spotify")
first = True
visited_songs = set()
visited_artists = set()
visited_albums = set()

first_q = "call AddUser('ADMIN_000001', 'ADMIN-EMAIL@GMAIL.COM', 'password', 'https://pbs.twimg.com/media/GLOrE46WIAAtt8E?format=jpg&name=large', 'ADMINS');"
# take note of:
# add_song(p_artist_id, p_song_name, ...) -- adds a new song to the database and maps it to the specified artist
# AddAlbum(p_album_name, p_album_image_link, p_is_explicit, p_stage_name, song_ids) -- adds a new album and optionally links it to an artist and existing songs
# AddingSongToPlaylist(p_sid, p_playlist_id) -- adds a song to the specified playlist if it doesn't already exist in that playlist
artist_to_dbid = {}
artist_incr = 100
while playlists:
    artist_list = []

    def flush_artist_list():
        artists = sp.artists(artist_list)
        artist_list.clear()
        for artist in artists["artists"]:
            a_name = artist["name"].replace('"', "").replace("'", "")
            a_followers = artist["followers"]["total"]
            artist_q = f"insert into artist values ('{a_name}', {a_followers});"
            try:
                c1.execute(artist_q)
                response = c1.fetchall()
            except pymysql.Error as e:
                print(artist_q)
                # raise e

    for i, playlist in enumerate(playlists["items"]):
        print("%4d %s" % (1 + i + playlists["offset"], playlist["name"]))
        # first we actually add the playlist
        """ 
        """
        sleep(1)
        playlistdata = sp.playlist(playlist["id"])
        p_name = playlistdata["name"].replace('"', "").replace("'", "")
        p_image = playlistdata["images"][0]["url"]
        p_followers = playlistdata["followers"]["total"]
        playlist_q = f"insert into playlist (playlist_name, cover_image_url, like_count, is_public, creator) values ('{p_name}', '{p_image}', {p_followers}, true, 'ADMIN_000001')"
        try:
            c1.execute(playlist_q)
            response = c1.fetchall()
        except pymysql.Error as e:
            print(playlist_q)
            raise e
            continue

        sleep(1)
        songs = sp.playlist_tracks(playlist["id"])
        query = "insert into song (song_name, length, date_added, cover_image_link, streaming_link) VALUES"

        while songs:

            for song in songs["items"]:
                s = song["track"]
                # pprint.pprint(s)
                if s:

                    # album too why not
                    album_id = s["album"]["id"]
                    if album_id not in visited_albums:
                        visited_albums.add(album_id)
                        album = s["album"]
                        if album["images"]:
                            a_name = album["name"].replace('"', "").replace("'", "")
                            a_image = ["images"][0]
                            album_q = f"insert into album (album_name, album_image_link) values ('{a_name}', '{a_image}');"
                            try:
                                c1.execute(album_q)
                                response = c1.fetchall()
                            except pymysql.Error as e:
                                print(album_q)
                                # raise e

                    if s["id"] not in visited_songs:
                        if s["album"]["images"]:
                            if s["external_urls"]["spotify"]:
                                s_name = s["name"].replace('"', "").replace("'", "")
                                s_time = s["duration_ms"] // 1000
                                s_image = s["album"]["images"][0]["url"]
                                s_url = s["external_urls"]["spotify"]
                                query += f"\n ('{s_name}', {s_time}, '2024-04-13', '{s_image}', '{s_url}'),"
                        visited_songs.add(s["id"])
                # we will check if there are enough artists to justify grabbing them
                if len(artist_list) > 10:
                    flush_artist_list()

            if songs["next"]:
                sleep(1)
                songs = sp.next(songs)
            else:
                songs = None
        query = query[:-1] + ";"
        try:
            c1.execute(query)
            response = c1.fetchall()
        except pymysql.Error as e:
            print(query)
    sleep(1)
    flush_artist_list()

    break  # we don't need more than 50 playlists
    if playlists["next"]:
        playlists = sp.next(playlists)
    else:
        playlists = None

c2 = connection.cursor()
query = "SELECT COUNT(*) from song;"
c2.execute(query)
response = c2.fetchall()
pprint.pprint(response)
