import { ArrowPathIcon } from '@heroicons/react/24/outline';
import clsx from 'clsx';
import Image from 'next/image';
import { lusitana } from '@/app/ui/fonts';
import { Song } from '@/app/lib/definitions';
import { fetchLatestSongs } from '@/app/lib/data';

export default async function LatestSongs() {
  const latestSongs = await fetchLatestSongs();
  return (
    <div className="flex w-full flex-col md:col-span-4">
      <h2 className={`${lusitana.className} mb-4 text-xl md:text-2xl`}>
        Latest Songs
      </h2>
      <div className="flex grow flex-col justify-between rounded-xl bg-gray-50 p-4">

        <div className="bg-white px-6">
          {latestSongs.map((song : Song) => {
            // console.log(song.song_name);
            return (
              <div
                key={song.sid}
                className={clsx(
                  'flex flex-row items-center justify-between py-4',
                  // {
                  //   'border-t': i !== 0,
                  // },
                )}
              >
                <div className="flex items-center">
                  {/* <Image
                    src={song.cover_image_link}
                    alt={`${song.song_name}'s cover image`}
                    className="mr-4 rounded-full"
                    width={32}
                    height={32}
                  /> */}
                  <div className="min-w-0">
                    <p className="truncate text-sm font-semibold md:text-base">
                      {song.song_name}
                    </p>
                    <p className="hidden text-sm text-gray-500 sm:block">
                      {/* {song.date_added} */}
                    </p>
                  </div>
                </div>
                <p
                  className={`${lusitana.className} truncate text-sm font-medium md:text-base`}
                >
                  {Math.floor(song.length / 60)}:{song.length % 60}
                </p>
              </div>
            );
          })}
        </div>
        <div className="flex items-center pb-2 pt-6">
          <ArrowPathIcon className="h-5 w-5 text-gray-500" />
          <h3 className="ml-2 text-sm text-gray-500 ">Updated just now</h3>
        </div>
      </div>
    </div>
  );
}
