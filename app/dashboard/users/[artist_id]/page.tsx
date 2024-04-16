import React, { Suspense } from 'react';
import { fetchArtistById, fetchArtistSongs } from '@/app/lib/data';
import { Artist, Song } from '@/app/lib/definitions';
import { notFound } from 'next/navigation';
import Table from '@/app/ui/songs/short-table';
import Pagination from '@/app/ui/songs/pagination';
import { SongsTableSkeleton } from '@/app/ui/skeletons';
import { fetchSongsPages } from '@/app/lib/data';
import { lusitana } from '@/app/ui/fonts';
import { Button } from '@/app/ui/button';

export default async function Page({
  params,
}: {
  params: { artist_id: string; page?: string };
}) {
  const artist_id = Number(params.artist_id);
  if (Number.isNaN(artist_id)) {
    notFound();
  }
  const [artist, songs] = (await Promise.all([
    fetchArtistById(artist_id),
    fetchArtistSongs(artist_id),
  ])) as [unknown, unknown] as [Artist[], Song[]];

  if (artist.length == 0) {
    notFound();
  }

  const songList = songs.forEach((song) => {
    return <div>{song.song_name}</div>;
  });

  const query = artist[0].stage_name;
  const currentPage = Number(params?.page) || 1;
  const totalPages = await fetchSongsPages(query);
  return (
    <div>
      <div className="mt-4 flex items-center gap-2 md:mt-8">
        <h1 className={`${lusitana.className} mb-4 text-xl md:text-2xl`}>
          {artist[0].stage_name}
        </h1>
        <div>@{artist[0].username}</div>
      </div>
      <div className="mt-4 flex items-center gap-2 md:mt-8">
      <h2 className={`${lusitana.className} text-l mb-4 md:text-2xl`}>
        Followers {artist[0].follower_count}
      </h2>
      </div>
      
      <div>{artist[0].profile_image}</div>
      <Suspense key={query + currentPage} fallback={<SongsTableSkeleton />}>
        <Table query={query} currentPage={currentPage} currentUser={1} />
      </Suspense>
      <div className="mt-5 flex w-full justify-center">
        <Pagination totalPages={totalPages} />
      </div>
    </div>
  );
}
