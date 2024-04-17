import { sql } from '@vercel/postgres';
import { unstable_noStore as noStore } from 'next/cache';
import {
  CustomerField,
  CustomersTableType,
  SongForm,
  Song,
  LatestSongRaw,
  User,
  Revenue,
  Album,
  Playlist,
} from './definitions';
import { formatCurrency } from './utils';
import * as mysql from 'mysql2';

export async function executeProcedure(
  procedureCall: string,
): Promise<mysql.QueryResult> {
  const conn = mysql.createConnection({
    host: process.env.HOST,
    user: process.env.USER,
    password: process.env.PASSWORD,
    database: 'music',
  });

  try {
    await conn.promise().connect();
    const data = await conn.promise().execute(procedureCall);
    conn.end();
    return data[0];
  } catch (err: any) {
    console.log('Cannot connect, Error: ' + err.message);
    conn.end();
    return [];
  }
}

export async function fetchRevenue() {
  // Add noStore() here to prevent the response from being cached.
  // This is equivalent to in fetch(..., {cache: 'no-store'}).
  noStore();

  try {
    const data = await sql<Revenue>`SELECT * FROM revenue`;
    return data.rows;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch revenue data.');
  }
}

export async function fetchLatestSongs() {
  noStore();
  try {
    const data = (await executeProcedure(`CALL get_songs();`)) as Song[];
    return data[0];
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch the latest songs.');
  }
}

export async function fetchAlbumsByUser() {
  noStore();
  try {
    const data = (await executeProcedure(`CALL get_user_albums('${process.env.CURRENT_USER}')`)) as Album[];
    return data[0] as unknown as Album[];
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch albums for the user.');
  }
}

export async function fetchAlbumSongCount(album_id: number) {
  noStore();
  try {
    const data = (await executeProcedure(`Select get_album_song_count(${album_id}) as song_count;`)) as Album[];
    return data[0];
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch songs for the album.');
  }
}

export async function fetchArtistById(artist_id: number) {
  noStore();
  try {
    const data = (await executeProcedure(
      `SELECT * from artist left join user on artist.artist_id = user.artist_id where artist.artist_id = ${artist_id}`,
    ));
    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch artist.');
  }
}

export async function fetchArtistIdByUsername(username: string) {
  noStore();
  try {
    const data = (await executeProcedure(
      `SELECT user.artist_id from user where username = '${username}';`,
    ));
    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch artist id.');
  }
}

export async function fetchArtistSongs(artist_id: number) {
  noStore();
  try {
    const data = (await executeProcedure(
      `SELECT * from artist_creates_song left join song on artist_creates_song.sid = song.sid where artist_creates_song.artist_id = ${artist_id}`,
    ));
    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch artist.');
  }
}

export async function fetchUserPlaylists() {
  noStore();
    try {
      const data = await executeProcedure(`SELECT playlist.* FROM playlist WHERE playlist.creator = '${process.env.CURRENT_USER}';`);;
      return data as unknown as Playlist[];
    } catch (error) {
      console.error('Database Error:', error);
      throw new Error('Failed to fetch playlist for the user.');
    }
}

const ITEMS_PER_PAGE = 6;
export async function fetchFilteredSongs(query: string, currentPage: number) {
  noStore();
  const offset = (currentPage - 1) * ITEMS_PER_PAGE;

  try {
    const q = `
      SELECT
        song.*,
        artist.*,
        album.*
        FROM artist_creates_song
        JOIN song ON artist_creates_song.sid = song.sid
        JOIN artist on artist_creates_song.artist_id = artist.artist_id
        JOIN album on album.album_id = song.album_id
        WHERE
          artist.stage_name LIKE '${`%${query}%`}' OR
          song.song_name LIKE '${`%${query}%`}'
      ORDER BY song.date_added DESC
      LIMIT ${ITEMS_PER_PAGE} OFFSET ${offset}
    `;

    const data = await executeProcedure(q);

    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch songs.');
  }
}

export async function fetchFilteredPlaylists(query: string, currentPage: number) {
  noStore();
  const offset = (currentPage - 1) * ITEMS_PER_PAGE;

  try {
    const q = `
      SELECT
        user.*,
        playlist.*
        FROM playlist
        JOIN user on playlist.creator = user.username
        WHERE
          playlist.playlist_name LIKE '${`%${query}%`}' OR
          user.username LIKE '${`%${query}%`}'
      ORDER BY playlist.like_count DESC
      LIMIT ${ITEMS_PER_PAGE} OFFSET ${offset}
    `;

    const data = await executeProcedure(q);

    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch playlists.');
  }
}

export async function fetchPlaylistSongs(playlist_id: number) {
  try {
    const songs = await executeProcedure(`SELECT song.* FROM song
    JOIN playlist_contains_song ON song.sid = playlist_contains_song.sid WHERE playlist_contains_song.playlist_id=${playlist_id};`);
    return songs[0];
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw new Error('Failed to fetch user.');
  }
}

export async function fetchPlaylistById(playlist_id: number) {
  try {
    const playlist = await executeProcedure(`SELECT * FROM playlist WHERE playlist_id=${playlist_id};`);
    return playlist[0];
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw new Error('Failed to fetch user.');
  }
}

export async function fetchIsFollowing(follower_id: string, artist_id: number) {
  try {
    const bool = await executeProcedure(`call is_user_following('${follower_id}', ${artist_id});`);
    console.log(bool);
    return bool[0];
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw new Error('Failed to fetch user.');
  }
}

export async function fetchFilteredPlaylistSongs(playlist_id: number, currentPage: number) {
  noStore();
  const offset = (currentPage - 1) * ITEMS_PER_PAGE;

  try {
    const q = `
      SELECT
        song.*,
        artist.*
        FROM artist_creates_song
        JOIN song ON artist_creates_song.sid = song.sid
        JOIN artist on artist_creates_song.artist_id = artist.artist_id
        JOIN playlist_contains_song ON song.sid = playlist_contains_song.sid
        WHERE
        playlist_contains_song.playlist_id = ${playlist_id}
      ORDER BY song.date_added DESC
      LIMIT ${ITEMS_PER_PAGE} OFFSET ${offset}
    `;

    const data = await executeProcedure(q);

    return data;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch songs.');
  }
}

export async function fetchSongsPagesPlaylist(playlist_id: number) {
  noStore();
  try {
    const result = executeProcedure(`SELECT
    song.*,
    artist.*
    FROM artist_creates_song
    JOIN song ON artist_creates_song.sid = song.sid
    JOIN artist on artist_creates_song.artist_id = artist.artist_id
    JOIN playlist_contains_song ON song.sid = playlist_contains_song.sid
    WHERE
    playlist_contains_song.playlist_id = ${playlist_id};`);
    const data = result.length;
    const totalPages = Math.ceil(Number(data) / ITEMS_PER_PAGE);
    return totalPages;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch total number of song pages.');
  }
}

export async function fetchSongsPages(query: string) {
  noStore();
  try {
    const data = await executeProcedure(`SELECT
      song.*,
      artist.*,
      album.*
      FROM artist_creates_song
      JOIN song ON artist_creates_song.sid = song.sid
      JOIN artist on artist_creates_song.artist_id = artist.artist_id
      JOIN album on album.album_id = song.album_id
      WHERE
        artist.stage_name LIKE '${`%${query}%`}' OR
        song.song_name LIKE '${`%${query}%`}';`);
    const data_num = data.length;
    const totalPages = Math.ceil(Number(data_num) / ITEMS_PER_PAGE);
    return totalPages;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch total number of song pages.');
  }
}

export async function fetchPlaylistPages(query: string) {
  noStore();
  try {
    const result = await executeProcedure(`SELECT
    user.*,
    playlist.*
    FROM playlist
    JOIN user on playlist.creator = user.username
    WHERE
      playlist.playlist_name LIKE '${`%${query}%`}' OR
      user.username LIKE '${`%${query}%`}'`);
    const data = result.length;
    const totalPages = Math.ceil(Number(data) / ITEMS_PER_PAGE);
    return totalPages;
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch total number of playlist pages.');
  }
}

export async function fetchInvoiceById(id: string) {
  noStore();
  try {
    const data = await sql<SongForm>`
      SELECT
        invoices.id,
        invoices.customer_id,
        invoices.amount,
        invoices.status
      FROM invoices
      WHERE invoices.id = ${id};
    `;

    const invoice = data.rows.map((invoice) => ({
      ...invoice,
      // Convert amount from cents to dollars
      amount: invoice.amount / 100,
    }));

    return invoice[0];
  } catch (error) {
    console.error('Database Error:', error);
    throw new Error('Failed to fetch invoice.');
  }
}

export async function fetchCustomers() {
  try {
    const data = await sql<CustomerField>`
      SELECT
        id,
        name
      FROM customers
      ORDER BY name ASC
    `;

    const customers = data.rows;
    return customers;
  } catch (err) {
    console.error('Database Error:', err);
    throw new Error('Failed to fetch all customers.');
  }
}

export async function fetchFilteredCustomers(query: string) {
  try {
    const data = await sql<CustomersTableType>`
		SELECT
		  customers.id,
		  customers.name,
		  customers.email,
		  customers.image_url,
		  COUNT(invoices.id) AS total_invoices,
		  SUM(CASE WHEN invoices.status = 'pending' THEN invoices.amount ELSE 0 END) AS total_pending,
		  SUM(CASE WHEN invoices.status = 'paid' THEN invoices.amount ELSE 0 END) AS total_paid
		FROM customers
		LEFT JOIN invoices ON customers.id = invoices.customer_id
		WHERE
		  customers.name ILIKE ${`%${query}%`} OR
        customers.email ILIKE ${`%${query}%`}
		GROUP BY customers.id, customers.name, customers.email, customers.image_url
		ORDER BY customers.name ASC
	  `;

    const customers = data.rows.map((customer) => ({
      ...customer,
      total_pending: formatCurrency(customer.total_pending),
      total_paid: formatCurrency(customer.total_paid),
    }));

    return customers;
  } catch (err) {
    console.error('Database Error:', err);
    throw new Error('Failed to fetch customer table.');
  }
}

export async function getUser(email: string) {
  try {
    const user = await sql`SELECT * FROM users WHERE email=${email}`;
    return user.rows[0] as User;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw new Error('Failed to fetch user.');
  }
}
