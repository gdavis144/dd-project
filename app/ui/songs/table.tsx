import Image from 'next/image';
import { DeleteSong, PlaySong } from '@/app/ui/songs/buttons';
import InvoiceStatus from '@/app/ui/songs/status';
import { formatDateToLocal, formatCurrency } from '@/app/lib/utils';
import { fetchFilteredSongs } from '@/app/lib/data';
import { TimeFromLength } from '../dashboard/latest-songs';
import Link from 'next/link';

export default async function SongsTable({
  query,
  currentPage,
}: {
  query: string;
  currentPage: number;
}) {
  const songs = await fetchFilteredSongs(query, currentPage);

  return (
    <div className="mt-6 flow-root">
      <div className="inline-block min-w-full align-middle">
        <div className="rounded-lg bg-gray-50 p-2 md:pt-0">
          <div className="md:hidden">
            {songs?.map((song) => (
              <div
                key={song.sid}
                className="mb-2 w-full rounded-md bg-white p-4"
              >
                <div className="flex items-center justify-between border-b pb-4">
                  <div>
                    <div className="mb-2 flex items-center">
                      {/* <Image
                        src={song.cover_image_link}
                        className="mr-2 rounded-full"
                        width={28}
                        height={28}
                        alt={`${}'s profile picture`}
                      /> */}
                      <p>{song.song_name}</p>
                    </div>
                    <p className="text-sm text-gray-500">{song.stage_name}</p>
                  </div>
                  {/* <InvoiceStatus status={invoice.status} /> */}
                </div>
                <div className="flex w-full items-center justify-between pt-4">
                  <div>
                    {/* <p className="text-xl font-medium">
                      {formatCurrency(invoice.amount)}
                    </p> */}
                    <p>{formatDateToLocal(song.date_added)}</p>
                  </div>
                  <div className="flex justify-end gap-2">
                    <PlaySong link={song.streaming_link} />
                    <DeleteSong id={song.sid} />
                  </div>
                </div>
              </div>
            ))}
          </div>
          <table className="hidden min-w-full text-gray-900 md:table">
            <thead className="rounded-lg text-left text-sm font-normal">
              <tr>
                <th scope="col" className="px-4 py-5 font-medium sm:pl-6">
                  Song
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Artist
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Album
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Date Added
                </th>
                <th scope="col" className="px-3 py-5 font-medium">
                  Length
                </th>
                <th scope="col" className="relative py-3 pl-6 pr-3">
                  <span className="sr-only">Edit</span>
                </th>
              </tr>
            </thead>
            <tbody className="bg-white">
              {songs?.map((song) => (
                <tr
                  key={song.sid}
                  className="w-full border-b py-3 text-sm last-of-type:border-none [&:first-child>td:first-child]:rounded-tl-lg [&:first-child>td:last-child]:rounded-tr-lg [&:last-child>td:first-child]:rounded-bl-lg [&:last-child>td:last-child]:rounded-br-lg"
                >
                  <td className="whitespace-nowrap py-3 pl-6 pr-3">
                    <div className="flex items-center gap-3">
                      {/* <Image
                        src={invoice.image_url}
                        className="rounded-full"
                        width={28}
                        height={28}
                        alt={`${invoice.name}'s profile picture`}
                      /> */}
                      <p>{song.song_name}</p>
                    </div>
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                  <Link className="hover:bg-blue-100" key={song.sid} href={`/dashboard/users/${song.artist_id}`}>
                    {song.stage_name}
                    </Link>
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {/* {formatCurrency(invoice.amount)} */}
                    {song.album_name}
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {formatDateToLocal(song.date_added)}
                  </td>
                  <td className="whitespace-nowrap px-3 py-3">
                    {TimeFromLength(song.length)}
                  </td>
                  <td className="whitespace-nowrap py-3 pl-6 pr-3">
                    <div className="flex justify-end gap-3">
                      <PlaySong link={song.streaming_link} />
                      <DeleteSong id={song.sid} />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
