import React, { Suspense } from 'react';
import { fetchArtistById, fetchArtistSongs, fetchIsFollowing } from '@/app/lib/data';
import { Artist, Song } from '@/app/lib/definitions';
import { notFound } from 'next/navigation';
import Table from '@/app/ui/songs/table';
import Pagination from '@/app/ui/songs/pagination';
import { SongsTableSkeleton } from '@/app/ui/skeletons';
import { fetchSongsPages } from '@/app/lib/data';
import { lusitana } from '@/app/ui/fonts';
import { Button } from '@/app/ui/button';
import { FollowArtist, UnfollowArtist } from '@/app/ui/songs/buttons';

export default async function Page({
  params,
}: {
  params: { artist_id: string; page?: string };
}) {
  const artist_id = Number(params.artist_id);
  if (Number.isNaN(artist_id)) {
    notFound();
  }
  const artist = await fetchArtistById(artist_id) as unknown as Artist[];

  if (artist.length == 0) {
    notFound();
  }

  const query = artist[0].stage_name;
  const currentPage = Number(params?.page) || 1;
  const totalPages = await fetchSongsPages(query);
  const user = process.env.CURRENT_USER ? process.env.CURRENT_USER : '';
  const is_following = await fetchIsFollowing(user, artist_id);

  return (
    <div>
      <div className="rounded-xl bg-green-800 py-10 text-white">
        <div className="mb-5 ml-10 mt-4 flex items-end gap-2 rounded-xl bg-green-800 text-white md:mt-8">
          <h1 className={`${lusitana.className} text-[40px]`}>
            {artist[0].stage_name}
          </h1>
          <div className="mb-4 ml-3">@{artist[0].username}</div>
        </div>

        <div className="ml-10 flex items-center gap-2">
          <h2 className={`${lusitana.className} text-l mb-4 md:text-xl`}>
            {artist[0].follower_count} Followers
          </h2>
          <div className='mb-4 ml-3'>
          {is_following ? 
          <UnfollowArtist follower_id={user} artist_id={artist_id}></UnfollowArtist>
          : <FollowArtist follower_id={user} artist_id={artist_id}></FollowArtist>}
          </div>
        </div>
      </div>
      <h1 className={`${lusitana.className} text-xl mt-10 ml-5`}>Songs</h1>
      <Suspense key={query + currentPage} fallback={<SongsTableSkeleton />}>
        <Table query={query} currentPage={currentPage} />
      </Suspense>
      <div className="mt-5 flex w-full justify-center">
        <Pagination totalPages={totalPages} />
      </div>
    </div>
  );
}
