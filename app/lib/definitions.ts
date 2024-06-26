// This file contains type definitions for your data.
// It describes the shape of the data, and what data type each property should accept.
// For simplicity of teaching, we're manually defining these types.
// However, these types are generated automatically if you're using an ORM such as Prisma.
export type User = {
  id: string;
  name: string;
  email: string;
  password: string;
};

export type Album = {
  album_id: number;
  album_name: string;
  album_image_link: string;
  is_explicit: boolean;
};

export type Playlist = {
  playlist_id: number;
  playlist_name: string;
  creator: string;
  cover_image_url: string;
  like_count: number;
  is_public: boolean;
};

export type Customer = {
  id: string;
  name: string;
  email: string;
  image_url: string;
};

export type Revenue = {
  month: string;
  revenue: number;
};

export type Song = {
  sid: number;
  song_name: string;
  length: number;
  date_added: Date;
  cover_image_link: string;
  streaming_link: string;
  album_id: number;
  producer_email: string;
};

// The database returns a number for amount, but we later format it to a string with the formatCurrency function
export type LatestSongRaw = Omit<Song, 'amount'> & {
  amount: number;
};

export type Artist = {
  artist_id: number;
  stage_name: string;
  follower_count: number;
  username?: string;
  email_address?: string;
  password?: string;
  profile_image?: string;
};

export type CustomersTableType = {
  id: string;
  name: string;
  email: string;
  image_url: string;
  total_invoices: number;
  total_pending: number;
  total_paid: number;
};

export type FormattedCustomersTable = {
  id: string;
  name: string;
  email: string;
  image_url: string;
  total_invoices: number;
  total_pending: string;
  total_paid: string;
};

export type CustomerField = {
  id: string;
  name: string;
};

export type SongForm = {
  sid: number;
  song_name: string;
  length: number;
  cover_image_link?: string;
  streaming_link: string;
};
