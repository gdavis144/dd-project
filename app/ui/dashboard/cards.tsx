import {
  BanknotesIcon,
  ClockIcon,
  UserGroupIcon,
  InboxIcon,
} from '@heroicons/react/24/outline';
import { lusitana } from '@/app/ui/fonts';
import { fetchUserPlaylists } from '@/app/lib/data';
import Image from 'next/image';

const iconMap = {
  collected: BanknotesIcon,
  customers: UserGroupIcon,
  pending: ClockIcon,
  invoices: InboxIcon,
};

export default async function CardWrapper() {
  // const {
  //   // numberOfSongs,
  //  title
  // creator
  // } = await fetchUserPlaylists();

  return (
    <>
      <Card title={"Playlist name"} songCount={4} creator={"User 1"} />
      {/* <Card title="Pending" value={totalPendingInvoices} type="pending" />
      <Card title="Total Invoices" value={numberOfSongs} type="invoices" /> */}
    </>
  );
}

export function Card({
  title,
  songCount,
  image,
  creator
}: {
  title: string;
  songCount: number;
  image?: string;
  creator: string
}) {
  return (
    <div className="rounded-xl bg-gray-50 p-2 shadow-sm">
      <div className="flex p-4">
        {/* {image ? <Image className="h-5 w-5 text-gray-700" alt='' /> : null} */}
        <h3 className="ml-2 text-sm font-medium">{creator}</h3>
      </div>
      <p
        className={`${lusitana.className}
          truncate rounded-xl bg-white px-4 py-8 text-center text-2xl`}
      >
        {title}
      </p>
    </div>
  );
}
