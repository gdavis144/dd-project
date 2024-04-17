import {
  BanknotesIcon,
  ClockIcon,
  UserGroupIcon,
  InboxIcon,
} from '@heroicons/react/24/outline';
import { lusitana } from '@/app/ui/fonts';
import { fetchAlbumsByUser, fetchUserPlaylists, fetchAlbumSongCount } from '@/app/lib/data';
import Image from 'next/image';
import Link from 'next/link';
import clsx from 'clsx';
import { Album, Playlist } from '@/app/lib/definitions';

const iconMap = {
  collected: BanknotesIcon,
  customers: UserGroupIcon,
  pending: ClockIcon,
  invoices: InboxIcon,
};

type CardData = {
  title: string,
  creator: string,
  id: number,
};

export default async function CardWrapper({
  type,
}: {
  type: 'albums' | 'playlists';
}) {
  // const {
  //   // numberOfSongs,
  //  title
  // creator
  // } = await fetchUserPlaylists();

  let title,
    creator: string = '';
  let songCount,
    id: number = 0;

  let recent: CardData[] = [];

  if (type == 'albums') {
    const lastfourplaylists = await fetchAlbumsByUser() as unknown as Album[] || [];
    lastfourplaylists.forEach((album) => {
      recent.push({
        title: album.album_name,
        creator: "User",
        id: album.album_id,
      });
    });
  } else {
    const lastfourplaylists = await fetchUserPlaylists() as unknown as Playlist[] || [];
    lastfourplaylists.forEach((playlist) => {
      recent.push({
        title: playlist.playlist_name,
        creator: playlist.creator,
        id: playlist.playlist_id,
      });
    });
  }

  return (
    <>
    {recent.map((card : CardData) => {
      return (
        <Card
          key={card.id}
          title={card.title}
          id={card.id}
          creator={card.creator}
          type={type}
        ></Card>
      );
    })}
    </>
  );
}

export function Card({
  type,
  id,
  title,
  image,
  creator,
}: {
  type: 'albums' | 'playlists';
  id: number;
  title: string;
  image?: string;
  creator: string;
}) {
  return (
    <Link
      className={clsx(
        'rounded-xl bg-blue-300 p-2 shadow-sm hover:bg-blue-100',
        {
          'bg-pink-300 hover:bg-pink-100': type == 'albums',
        },
      )}
      href={`${type}/${id}`}
    >
      <div className="flex p-4 justify-between">
        {/* {image ? <Image className="h-5 w-5 text-gray-700" alt='' /> : null} */}
        <h2 className="mx-2 text-sm font-medium">
          Created by @{creator}
        </h2>
      </div>
      <p
        className={`${lusitana.className}
          truncate rounded-xl bg-white px-4 py-8 text-center text-2xl`}
      >
        {title}
      </p>
    </Link>
  );
}
