import pprint
from time import sleep
from typing import List
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pymysql
from tqdm import tqdm

waiting_time = 1

# lets connect to server first
username = "root"  # input("Enter username: ")
pword = "74274"  # input("Enter password: ")
name = "projdb"  # input("Enter database name: ")
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
sleep(waiting_time)
playlists = sp.user_playlists("spotify")
first = True
visited_songs = set()
visited_artists = set()
visited_albums = set()

first_q = "call AddUser('ADMIN_000001', 'ADMIN-EMAIL@GMAIL.COM', 'password', 'https://pbs.twimg.com/media/GLOrE46WIAAtt8E?format=jpg&name=large', 'ADMINS');"
c1.execute(first_q)

# take note of:
# add_song(p_artist_id, p_song_name, ...) -- adds a new song to the database and maps it to the specified artist
# AddAlbum(p_album_name, p_album_image_link, p_is_explicit, p_stage_name, song_ids) -- adds a new album and optionally links it to an artist and existing songs
# AddingSongToPlaylist(p_sid, p_playlist_id) -- adds a song to the specified playlist if it doesn't already exist in that playlist


# playlist_contains_song(playlist_id: int, sid: int) -- maps songs to the playlists they are included in
# user_follows_artist(username: varchar(255), artist_id: int) -- tracks which users follow which artists

# artist_creates_song(artist_id: int, sid: int) -- maps artists to the songs they created
# artist_creates_album(album_id: int, artist_id: int) -- maps albums to the artists who created them
# song_is_genre(genre_name: varchar(24), sid: int) -- maps songs to their genres
# producer_produces_song(producer_email: varchar(255), song_id: int) -- maps producers to the songs they produced


def remove_quotes(s: str) -> str:
    return s.replace("'", "").replace('"', "")


def wrap_quotes(s: str) -> str:
    return f"'{s}'"


artist_sid_to_usid = {}
artist_list = []
artist_incr = 100

track_sid_to_usid = {}
track_incr = 1000

playlist_incr = 10000

albums_songs = {}

authors_genres = {}


def flush_artists() -> None:
    global artist_incr
    global artist_list
    sleep(waiting_time)
    artists = sp.artists(artist_list)["artists"]
    for artist in artists:
        if not artist:
            continue
        for g in artist["genres"]:
            ags = authors_genres.get(g, [])
            ags.append(str(artist_incr))
            authors_genres[g] = ags
        if artist["followers"]:
            query = f"insert into artist values ({artist_incr}, '{remove_quotes(artist['name'])}', {artist['followers']['total']});"
        else:
            query = f"insert into artist values ({artist_incr}, '{remove_quotes(artist['name'])}', 0);"

        c1.execute(query)
        artist_sid_to_usid[artist["id"]] = str(artist_incr)
        artist_incr += 1
    artist_list.clear()


if playlists:
    for playlist in tqdm(playlists["items"][:40]):
        playlist_track_ids = []

        sleep(waiting_time)
        tracks = sp.playlist_tracks(playlist_id=playlist["id"])["items"]

        for track in tracks:
            # first mark artists to add
            if track["track"]:
                if track["track"]["artists"]:
                    for artist in track["track"]["artists"]:
                        if (
                            artist["id"] not in artist_sid_to_usid
                            and artist["id"] not in artist_list
                        ):
                            artist_list.append(artist["id"])
                            if len(artist_list) > 49:
                                flush_artists()

        # a batch of artists to add to db
        if artist_list:
            flush_artists()

        # go through again to add songs
        for track in tracks:
            # collect info to add each song
            if track["track"]:
                artist_list = []
                if track["track"]["id"] in track_sid_to_usid:
                    playlist_track_ids.append(
                        str(track_sid_to_usid[track["track"]["id"]])
                    )
                    continue
                if track["track"]["artists"]:
                    for artist in track["track"]["artists"]:
                        artist_list.append(str(artist_sid_to_usid[artist["id"]]))
                # mark this song was part of an album
                s_album = albums_songs.get(track["track"]["album"]["id"], [])
                s_album.append(track_incr)
                albums_songs[track["track"]["album"]["id"]] = s_album
                # continue
                if (
                    track["track"]["album"]["images"]
                    and track["track"]["external_urls"]["spotify"]
                ):
                    s_name = track["track"]["name"].replace('"', "").replace("'", "")
                    s_time = track["track"]["duration_ms"] // 1000
                    s_date = "2024-04-14"
                    s_image = track["track"]["album"]["images"][0]["url"]
                    s_url = track["track"]["external_urls"]["spotify"]
                    query = f"call add_song_n_artists('{','.join(artist_list)}', {track_incr}, '{remove_quotes(s_name)}', {s_time}, '{s_date}', '{s_image}', '{s_url}');"
                    # print(query)
                    c1.execute(query)
                    playlist_track_ids.append(str(track_incr))
                    track_sid_to_usid[track["track"]["id"]] = str(track_incr)
                    track_incr += 1
        # collect playlist info
        p_playlist_name = wrap_quotes(remove_quotes(playlist["name"]))
        if playlist["images"][0]["url"]:
            p_cover_image_url = wrap_quotes(playlist["images"][0]["url"])
        else:
            p_cover_image_url = "'www.brokenlink.com'"
        sleep(waiting_time)
        p_like_count = sp.playlist(playlist["id"], "followers")["followers"]["total"]
        p_is_public = "true"
        p_creator = "'ADMIN_000001'"
        p_song_ids = wrap_quotes(",".join(playlist_track_ids))
        playlist_track_ids = []
        query = f"call create_playlist_from_songs({playlist_incr}, {p_playlist_name}, {p_cover_image_url}, {p_like_count}, {p_is_public}, {p_creator}, {p_song_ids});"
        # print(query)
        c1.execute(query)
        playlist_incr += 1
        # break
album_incr = 10
albums_to_get_to = list(albums_songs.keys())
album_queue = []


for i in tqdm(albums_to_get_to, desc="processing albums"):
    album_queue.append(i)
    # print(i)
    if len(album_queue) >= 18 or i == albums_to_get_to[-1]:
        sleep(1)
        # print(album_queue)
        album_info_fetch = sp.albums(album_queue)
        # print("executing batch")
        # pprint.pprint(len(album_info_fetch["albums"]))
        for album_info in album_info_fetch["albums"]:
            p_album_id = album_incr
            p_album_name = wrap_quotes(remove_quotes(album_info["name"]))
            if album_info["images"]:
                p_album_image_link = wrap_quotes(album_info["images"][0]["url"])
            else:
                p_album_image_link = wrap_quotes("www.skill-issue.com")
            p_is_explicit = "true"
            p_artist_ids = []
            for a in album_info["artists"]:
                if a["id"] in artist_sid_to_usid:
                    p_artist_ids.append(artist_sid_to_usid[a["id"]])
            p_artist_ids = wrap_quotes(",".join(p_artist_ids))

            p_song_ids = []
            for t in album_info["tracks"]["items"]:
                if t["id"] in track_sid_to_usid:
                    p_song_ids.append(track_sid_to_usid[t["id"]])
            p_song_ids = wrap_quotes(",".join(p_song_ids))

            query = f"call AddAlbumAndDets({p_album_id}, {p_album_name}, {p_album_image_link}, {p_is_explicit}, {p_artist_ids}, {p_song_ids});"
            # print(query)
            c1.execute(query)
            album_incr += 1
        album_queue.clear()
for i in tqdm(authors_genres.keys()):
    for g in authors_genres[i]:
        mini_q = f"call mark_songs_genre_by_artist({str(g)}, {wrap_quotes(remove_quotes(i))});"
        c1.execute(mini_q)
