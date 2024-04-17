import React, { Suspense } from 'react';
import { fetchPlaylistById, fetchPlaylistSongs, fetchSongsPagesPlaylist } from '@/app/lib/data';
import { Artist, Song } from '@/app/lib/definitions';
import { notFound } from 'next/navigation';
import Table from '@/app/ui/playlists/playlist-songs-table';
import Pagination from '@/app/ui/songs/pagination';
import { SongsTableSkeleton } from '@/app/ui/skeletons';
import { fetchSongsPages } from '@/app/lib/data';
import { lusitana } from '@/app/ui/fonts';
import { Button } from '@/app/ui/button';

export default async function Page({
  params,
}: {
  params: { id: string; page?: string };
}) {
  const playlist_id = Number(params.id);
  if (Number.isNaN(playlist_id)) {
    notFound();
  }
  const [songs] = (await Promise.all([
    fetchPlaylistSongs(playlist_id),
  ])) as [unknown] as [Song[]];

  const playlist = await fetchPlaylistById(playlist_id);

  const currentPage = Number(params?.page) || 1;
  const totalPages = await fetchSongsPagesPlaylist(playlist_id);
  return (
    <div>
      <div className="rounded-xl bg-green-800 py-10 text-white">
        <div className="mb-5 ml-10 mt-4 flex items-end gap-2 rounded-xl bg-green-800 text-white md:mt-8">
          <h1 className={`${lusitana.className} text-[40px]`}>
            {playlist.playlist_name}
          </h1>
        </div>
        

        <div className="ml-10 flex items-center gap-4">
        <div className="mb-4 ml-3">@{playlist.creator}   |</div>
          <h2 className={`${lusitana.className} text-l mb-4 md:text-xl`}>
            {playlist.like_count} likes
          </h2>
        </div>
      </div>
      <h1 className={`${lusitana.className} text-xl mt-10 ml-5`}>Songs</h1>
      <Suspense key={playlist_id + currentPage} fallback={<SongsTableSkeleton />}>
        <Table playlist_id={playlist_id} currentPage={currentPage} />
      </Suspense>
      <div className="mt-5 flex w-full justify-center">
        <Pagination totalPages={totalPages} />
      </div>
    </div>
  );
}
