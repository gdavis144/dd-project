import {
  BanknotesIcon,
  ClockIcon,
  UserGroupIcon,
  InboxIcon,
} from '@heroicons/react/24/outline';
import { lusitana } from '@/app/ui/fonts';
import { fetchUserPlaylists } from '@/app/lib/data';
import Image from 'next/image';
import Link from 'next/link';
import clsx from 'clsx';

const iconMap = {
  collected: BanknotesIcon,
  customers: UserGroupIcon,
  pending: ClockIcon,
  invoices: InboxIcon,
};

export default async function CardWrapper({type}: {type: 'albums' | 'playlists'}) {
  // const {
  //   // numberOfSongs,
  //  title
  // creator
  // } = await fetchUserPlaylists();

  let title, creator: string = '';
  let songCount, id: number = 0;



  if (type == 'albums') {
    [title, creator, songCount, id] = ["Album name", "User 1", 4, 1];
  } else {
    [title, creator, songCount, id] = ["Playlist Name", "User 2", 10, 2];
  }

  return (
    <>
      <Card type={type} id={id} title={title} songCount={songCount} creator={creator} />
      <Card type={type} id={id} title={title} songCount={songCount} creator={creator} />
      <Card type={type} id={id} title={title} songCount={songCount} creator={creator} />
      <Card type={type} id={id} title={title} songCount={songCount} creator={creator} />
    </>
  );
}

export function Card({
  type,
  id,
  title,
  songCount,
  image,
  creator
}: {
  type: 'albums' | 'playlists';
  id: number;
  title: string;
  songCount: number;
  image?: string;
  creator: string
}) {
  return (
    <Link className={clsx("rounded-xl bg-blue-300 hover:bg-yellow-200 p-2 shadow-sm",
      {
        "bg-pink-300": type == 'albums'
      })
    } href={`${type}/${id}`}>
      <div className="flex p-4">
        {/* {image ? <Image className="h-5 w-5 text-gray-700" alt='' /> : null} */}
        <h2 className="ml-2 text-sm font-medium">{creator} | {songCount} songs</h2>
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
